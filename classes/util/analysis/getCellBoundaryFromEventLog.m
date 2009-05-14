function cellBoundary = getCellBoundaryFromEventLog(subjectID,eventParams,neuralRecordsLocation)
% gets cell boundaries from a physiology event log (a struct of events)
% INPUTS:
%   subjectID - what subject to get cell boundary for
%   eventParam - a cell array containing all the information we need to load the correct set of events
%   neuralRecordsLocation - the directory of neural records containing this cell
%   which (optional) - which cell within the struct to get (choose from 'first','last',or Nth)
%       - Nth is an integer specifying which cell to get (ex getCellBoundaryFromEventLog(..,5) gets the 5th cell
%       - if N exceeds to number of cells in the event log, then the last (most recent) cell is retrieved
%       - default is 'last'
% OUTPUTS:
%   cellBoundary - a cell boundary in the form of [startTrial startChunk startSysTime endTrial endChunk endSysTime]

% some things to consider:
% - these cell boundaries determine the boundaries for neural/stim records, which are timestamped with the trial start times
%   from the client (based on trialRecords.date, which uses the client matlab's 'now' command). so, in recording the cell boundaries 
%   in the physiologyServer UI, can we reliably use the server machine's 'now' command and assume the times are equal? or should
%   a 'new cell' event on the server send a command to the client asking for a timestamp from the client matlab?

% error check args
if ~isdir(neuralRecordsLocation)
    error('neuralRecordsLocation must be a valid directory');
end
specific=Inf;
% process eventParams
%       {'04.21.2009','all','first'} means get the cell boundaries from the phys log for 4/21/09 (and use the first cell)
%       {'04.21.2009',[4 200],'last'} means get the last cell from 4/21/09 within events 4-200 (of that day)
%       {'04.21.2009','0040 - 0530',2} means get the 2nd cell from 4/21/09 within the time range 12:40am-530am (time range is military time)
date=eventParams{1};
physLogPath=fullfile('\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\physiology',subjectID,date);
dirStr=fullfile(physLogPath,'physiologyEvents*');
d=dir(dirStr);
if length(d)==1
    physLogFilename=fullfile(physLogPath,d(1).name);
else
    error('no phys log found!');
end
load(physLogFilename);
events=events_data;
clear events_data;
% now filter events based on eventParams{2}
if ischar(eventParams{2})
    if strcmp(eventParams{2},'all')
        % do nothing, keep all events
    else
        [match tokens]=regexp(eventParams{2},'(\d{4})\s*-\s*(\d{4})','match','tokens');
        if ~isempty(match)
            startTime=datenum(sprintf('%s-%s',date,tokens{1}{1}),'mm.dd.yyyy-HHMM');
            stopTime=datenum(sprintf('%s-%s',date,tokens{1}{2}),'mm.dd.yyyy-HHMM');
            % filter events that fall within startTime/stopTime
            goods=find([events.time]>=startTime&[events.time]<=stopTime);
            events=events(goods);
        else
            error('failed to parse time range');
        end
    end
elseif isvector(eventParams{2}) && length(eventParams{2})==2
    start=min(max(1,eventParams{2}(1)),length(events));
    stop=max(1,min(length(events),eventParams{2}(2)));
    events=events(start:stop);
else
    error('invalid eventParams{2}');
end
which = eventParams{3};
if ischar(which) && (strcmp(which,'first') || strcmp(which,'last'))
    % pass
elseif isinteger(which)
    % also pass
    specific=which;
    which='specific';
else
    error('which must be either ''first'', ''last'', or an integer');
end


% first get cell boundary in terms of a start/stop matlab time
cellStartInds=find(strcmp({events.eventType},'cell start'));
cellStopInds=find(strcmp({events.eventType},'cell stop'));
if length(cellStartInds)>length(cellStopInds)+1
    error('mismatch between cell start and stop events (too many cell starts!)');
end
if isempty(cellStartInds)
    cellBoundary=[]; % return empty if no 'cell start' events found!
    return;
end

switch which
    case 'first'
        startTime=events(cellStartInds(1)).time;
        if length(cellStopInds)>=1 % if there is a stop time
            stopTime=events(cellStopInds(1)).time;
        else
            stopTime=Inf;
        end
    case {'last','specific'}
        ind=min(length(cellStartInds),specific); %specific is Inf if 'last' mode, so this will just be the last cell start
        startTime=events(cellStartInds(ind)).time;
        if length(cellStopInds)==length(cellStartInds)
            stopTime=events(cellStopInds(ind)).time;
        else
            stopTime=Inf;
        end
    otherwise
        error('unknown which');
end

% then convert this time boundary to a trial/chunk boundary by doing the following:
%   1) look in neuralRecordsLocation to find all trials within the time range (based on neuralRecords start times),
%       and pad with an additional trial at the start
%   2) then look at the first and last trials to get a more fine-grained chunk boundary!

% NOTE - we will just loop through all neuralRecord files in the directory, instead of only looking through enough files
%   to match a start/stop time. this is because we would need to sort the filenames by timestamp to do this,
%   which would already defeat the purpose of reducing compute time.

d=dir(neuralRecordsLocation);
goodFiles = [];

% first sort the neuralRecords by trial number
for i=1:length(d)
    [matches tokens] = regexpi(d(i).name, 'neuralRecords_(\d+)-(.*)\.mat', 'match', 'tokens');
    if length(matches) ~= 1
        %         warning('not a neuralRecord file name');
    else
        goodFiles(end+1).trialNum = str2double(tokens{1}{1});
        goodFiles(end).timestamp = tokens{1}{2};
        goodFiles(end).time = datenumFor30(goodFiles(end).timestamp);
    end
end
[sorted order]=sort([goodFiles.trialNum]);
goodFiles=goodFiles(order);

goods=find([goodFiles.time]<=stopTime&[goodFiles.time]>=startTime);
% try to pad with an additional trial at the start if it exists
if goods(1)~=1
    goods=[goods(1)-1 goods];
end
startTrial=goods(1); % or min(goods) if we dont presort
stopTrial=goods(end); % or max(goods) if we dont presort
% for now, dont do the fine-grained chunk filtering (it takes too long)
% neuralRecord=fullfile(neuralRecordsLocation,sprintf('neuralRecords_%d-%s.mat',goodFiles(startTrial).trialNum,goodFiles(startTrial).timestamp));
% startChunk=findChunksInTimerange(neuralRecord,[startTime stopTime]);

% convert startTrial and stopTrial to trialNums instead of indices into goodFiles
startTrial=goodFiles(startTrial).trialNum;
stopTrial=goodFiles(stopTrial).trialNum;
startChunk=1;
stopChunk=Inf;

cellBoundary=[startTrial startChunk startTime stopTrial stopChunk stopTime];

end % end function

function goodChunks = findChunksInTimerange(neuralRecord,timerange)
goodChunks=[];

end % end function