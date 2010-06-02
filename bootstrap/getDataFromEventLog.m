function [rigState ampState lensState surgBregma surgAnchor currAnchor currPositn penetParams isNewDay] = getDataFromEventLog(eventLogPath,searchDepth)

rigState = [NaN NaN NaN];
ampState = {'','','','','',NaN};
lensState = [NaN NaN NaN NaN];
surgBregma = [NaN NaN NaN];
surgAnchor = [NaN NaN NaN];
currAnchor = [NaN NaN NaN];
currPositn = [NaN NaN NaN];
isNewDay = false;
penetParams = [];

doRigState = true;
doAmpState = true;
doLensState = true;
doSurgBregma = true;
doSurgAnchor = true;
doCurrAnchor = true;
doCurrPositn = true;
doPenetParams = true;

if exist(eventLogPath,'dir')
    pathList = dir(eventLogPath);
    pathList = pathList(~ismember({pathList.name},{'.','..'}));
    if ~exist('searchDepth','var')||isempty(searchDepth) % searchDepth tells you how far to look to get the data. Incase ther is nothing, it should send back an empty.
        searchDepth = min([2,length(pathList)]);
    elseif searchDepth>length(pathList)
        warning('cannot search to requested depth. not enough log files. resetting searchDepth to highest poss number');
        searchDepth = length(pathList)
    else
        error('searchDepth has to be numeric and positive.please ensure');
    end
    [logDates order] = sort(cell2mat({pathList.datenum}),'descend');
else
    doRigState = false;
    doAmpState = false;
    doLensState = false;
    doSurgBregma = false;
    doSurgAnchor = false;
    doCurrAnchor = false;
    doCurrPositn = false;
    doPenetParams = false;
    searchDepth = 0;
end




for currSearchDepth = 1:searchDepth
    eventLogPathForDay = fullfile(eventLogPath,pathList(order(currSearchDepth)).name,'');
    
    pathListForDay = dir(eventLogPathForDay);
    pathListForDay = pathListForDay(~ismember({pathListForDay.name},{'.','..'}));
    
    % some days have muliple logs. that is not supposed to be the case.
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
        % if the previous day does not contain any of the states we need,
        % that is immediately set to false. can we think of a scenario
        % where the previous day will not have some of these fields but
        % will have others?
        if ~isfield(events_data,'rigState') 
            doRigState = false;
        end
        if ~isfield(events_data,'ampState') 
            doAmpState = false;
        end
        if ~isfield(events_data,'lensState') 
            doLensState = false;
        end
        if ~isfield(events_data,'surgeryBregma') 
            doSurgBregma = false;
        end
        if ~isfield(events_data,'surgeryAnchor') 
            doSurgAnchor = false;
        end
        if ~isfield(events_data,'currentAnchor') 
            doCurrAnchor = false;
        end
        if ~isfield(events_data,'position') 
            doCurrPositn = false;
        end
        if ~isfield(events_data,'penetrationParams') 
            doPenetParams = false;
        end
        
        if doRigState
            if (~isempty(events_data(i).rigState))&(all(~isnan(events_data(i).rigState)))
                rigState = events_data(i).rigState;
                doRigState = false;
            end
        end
        
        if doAmpState
            if ~isempty(events_data(i).ampState)
                isAnyAmpStateEmpty = any(cellfun(@isempty,events_data(i).ampState));
                isAnyAmpStateNan = any(cell2mat(cellfun(@isnan,events_data(i).ampState,'UniformOutput',false)));
                if ~isAnyAmpStateEmpty && ~isAnyAmpStateNan
                    ampState = events_data(i).ampState;
                    doAmpState = false;
                end
            end
        end
        
        if doLensState
            if (~isempty(events_data(i).lensState))&(all(~isnan(events_data(i).lensState)))
                lensState = events_data(i).lensState;
                doLensState = false;
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
            doLoop = doRigState || doAmpState || doLensState || doSurgBregma || doSurgAnchor || doCurrAnchor || doCurrPositn || doPenetParams;
        else
            doLoop = false;
        end
    end
    
    if floor(datenum(now))~=floor(logDates(1))
        isNewDay = true;
    end
end


end