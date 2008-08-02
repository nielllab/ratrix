function flag = changeEyepuffStatus(subIDs, rackNum, dateVec, airPuffMS, recompile)

% function flag = changeEyepuffStatus(subIDs, rackNum, dateVec, airPuffMS, recompile)
% 
% Change airpuff duration for each of the subIDs for each of the days in 
% dateVec. This is a hack way of changing the airpuff duration when the airpuff
% is temporarily not working or if it is being refilled. Do not use as a
% routine. 
% The default behaviour of this function:
% if no subIDs, subIDs = = {'267','268','269','270'}
% if no rackNum, rackNum = 2
% if no dateVec, dateVec = now
% of no airpuffMS, airpuffMS = 0;
% if no recompile, recompile = 0
% 
% Always use for rats on the same rack
flag = 0;
if ~exist('subIDs','var') | isempty(subIDs)
    warning('subjects are not provided. will assign subIDs 267, 268');
    subIDs = {'267','268'}
end

if ~exist('rackNum','var') | isempty(rackNum)
    rackNum = 2; % trivial - just to get the path
end

if ~exist('dateVec','var') | isempty(dateVec)
    datevec = floor(now);
end

if ~exist('airPuffMS','var') | isempty(airPuffMS)
    airPuffMS = 0;
end

if ~exist('recompile','var') | isempty(recompile)
    recompile = 0;
end

subjectStorePath = getSubDirForRack(rackNum)

for rat = subIDs
    display(['rat: ' char(rat)]);
    pause(0);
    
    d = dir(fullfile(subjectStorePath,char(rat)));
    d = d(~ismember({d.name},{'.','..'}));
    
    changePuffMS = 0;
    if length(d) == 0
        display(['rat not found in rack ' int2str(rackNum)]);
    else
        changePuffMS = 1;
    end
    
    if changePuffMS
        for date = dateVec
            date
            d = dir(fullfile(subjectStorePath,char(rat),['trialRecords_*_' datestr(date,'yyyymmdd') '*.mat']));
            for trialRecName = {d.name}
                trialRecName
                load(fullfile(subjectStorePath,char(rat),char(trialRecName)));
                for j = 1:length(trialRecords)
                    trialRecords(j).proposedMsPuff = airPuffMS;
                end
                save(fullfile(subjectStorePath,char(rat),char(trialRecName)),'trialRecords');
                clear('trialRecords');
            end
        end
    end
    
    if recompile & changePuffMS
        warning('right now doing nothing...the server is down. later, simply call compileTrialRecords with necessary info');
    end
end
flag = 1;
end

