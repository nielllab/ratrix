function [rigState surgBregma surgAnchor currAnchor currPositn penetParams isNewDay] = getDataFromEventLog(eventLogPath,searchDepth)

rigState = [NaN NaN NaN];
surgBregma = [NaN NaN NaN];
surgAnchor = [NaN NaN NaN];
currAnchor = [NaN NaN NaN];
currPositn = [NaN NaN NaN];
isNewDay = false;
penetParams = [];

doRigState = true;
doSurgBregma = true;
doSurgAnchor = true;
doCurrAnchor = true;
doCurrPositn = true;
doPenetParams = true;

pathList = dir(eventLogPath); 
pathList = pathList(~ismember({pathList.name},{'.','..'}));

[logDates order] = sort(cell2mat({pathList.datenum}),'descend');

if ~exist('searchDepth','var')||isempty(searchDepth)
    searchDepth = 2;
elseif searchDepth>length(pathList)
    warning('cannot search to requested depth. not enough log files. resetting searchDepth to highest poss number');
    searchDepth = length(pathList)
else
    error('searchDepth has to be numeric and positive.please ensure');
end

for currSearchDepth = 1:searchDepth
    eventLogPathForDay = fullfile(eventLogPath,pathList(order(currSearchDepth)).name,'');
    
    pathListForDay = dir(eventLogPathForDay);
    pathListForDay = pathListForDay(~ismember({pathListForDay.name},{'.','..'}));
    
    if (length(pathListForDay)>1)
        warning('multiple event logs for this day! choosing the latest log file.');
        logFileNum = cell2mat({pathListForDay.datenum})==max(cell2mat({pathListForDay.datenum}));
        logFileName = pathListForDay(logFileNum).name;
    else
        logFileName = pathListForDay.name;
    end
    
    load(fullfile(eventLogPathForDay,logFileName));
    logLength = length(events_data);
    i = logLength;
    doLoop = true;
    
    while doLoop
        if ~isfield(events_data,'rigState') % hack since we are adding rigState to the event log
            doRigState = false;
        end
        
        if doRigState
            if (~isempty(events_data(i).rigState))&(all(~isnan(events_data(i).rigState)))
                rigState = events_data(i).rigState;
                doRigState = false;
            end
        end
        
        if doSurgBregma
            if (~isempty(events_data(i).surgeryBregma))&(all(~isnan(events_data(i).surgeryBregma)))
                surgBregma = events_data(i).surgeryBregma;
                doSurgBregma = false;
            end
        end
        
        if doSurgAnchor
            if (~isempty(events_data(i).surgeryAnchor))&(all(~isnan(events_data(i).surgeryAnchor)))
                surgAnchor = events_data(i).surgeryAnchor;
                doSurgAnchor = false;
            end
        end
        
        if doCurrAnchor
            if (~isempty(events_data(i).currentAnchor))&(all(~isnan(events_data(i).currentAnchor)))
                currAnchor = events_data(i).currentAnchor;
                doCurrAnchor = false;
            end
        end
        
        if doCurrPositn
            if (~isempty(events_data(i).position))&(all(~isnan(events_data(i).position)))
                currPositn = events_data(i).position;
                doCurrPositn = false;
            end
        end
        
        if doPenetParams
            if(~isempty(events_data(i).penetrationParams))
                penetParams = events_data(i).penetrationParams;
                doPenetParams = false;
            end
        end
        
        if i>1
            i = i-1;
            doLoop = doSurgBregma || doSurgAnchor || doCurrAnchor || doCurrPositn || doPenetParams;
        else
            doLoop = false;
        end
    end
    
    if floor(datenum(now))~=floor(logDates(1))
        isNewDay = true;
    end
end


end