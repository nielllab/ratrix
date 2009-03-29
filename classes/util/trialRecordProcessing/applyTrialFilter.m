function [files lowestTrialNum highestTrialNum] = applyTrialFilter(goodRecs,filter)
% This function carries out daterange or lastNTrials filtering on a struct array of candidate trials
% INPUTS:
%   goodRecs - a struct with fields 'dateStart','dateStop','trialStart', and 'trialStop'
%       - dateStart is the starting timestamp
%       - dateStop is the ending timestamp
%       - trialStart is the starting trialNum
%       - trialStop is the ending trialNum
%   filter - either {'dateRange',[startVec endVec]}, {'lastNTrials',numTrials}, or {'all'}
% OUTPUTS:
%   files - elements of goodRecs that pass the given filter

lowestTrialNum=[];
highestTrialNum=[];

if iscell(filter)
    filterType=filter{1};
else
    error('filter must be a cell array');
end

switch(filterType)
    case 'dateRange'
        if length(filter) ~= 2 || length(filter{2}) ~= 2
            error('Invalid filter parameters for dateRange')
        end
        dateRange = datenum(filter{2});
        dateRange = sort(dateRange);
        dateStart = dateRange(1);
        dateStop = dateRange(end);
        files = [];
        for i=1:length(goodRecs)
            if datenumFor30(goodRecs(i).dateStart)<=dateStop && datenumFor30(goodRecs(i).dateStop)>=dateStart
                if isempty(files)
                    files = goodRecs(i);
                else
                    files(end+1)=goodRecs(i);
                end
            end
        end

    case 'lastNTrials'
        if length(filter) ~= 2 || ~iswholenumber(filter{2}) || ~isscalar(filter{2}) || filter{2} < 0
            error('Invalid filter parameters for lastNTrials')
        end
        lastNTrials = filter{2};
        files = [];
        [garbage sortIndices]=sort([goodRecs.trialStart],2,'descend');
        goodRecs = goodRecs(sortIndices);
        highestTrialNum = goodRecs(1).trialStop;
        lowestTrialNum = highestTrialNum-lastNTrials;
        for i=1:length(goodRecs)
            if highestTrialNum-goodRecs(i).trialStop>=lastNTrials
                break;
            end
            if isempty(files)
                files = goodRecs(i);
            else
                files(end+1)=goodRecs(i);
            end
        end

    case 'all'
        files = goodRecs;
    otherwise
        error('Unsupported filter type')
end

end % end function