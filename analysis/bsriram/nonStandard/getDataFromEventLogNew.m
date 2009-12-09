function out = getDataFromEventLog(eventLogPath,searchDepth)

out.rigState = [NaN NaN NaN];
out.ampState = {'','','','','',NaN};
out.lensState = [NaN NaN NaN NaN];
out.surgBregma = [NaN NaN NaN];
out.surgAnchor = [NaN NaN NaN];
out.currAnchor = [NaN NaN NaN];
out.currPositn = [NaN NaN NaN];
out.penetParams = [];
out.isNewDay = false;


dataLogComponents = {'rigState','lensState','surgeryBregma','surgeryAnchor','currentAnchor','position','penetrationParams','ampState'};
doDataLogComponents = {'doRigState','doLensState','doSurgBregma','doSurgAnchor','doCurrAnchor','doCurrPositn','doPenetParams','doAmpState'};
dataLogOutput = {'rigState','lensState','surgBregma','surgAnchor','currAnchor','currPositn','penetParams','ampState'};

for compNum = 1:length(doDataLogComponents)
    eval([doDataLogComponents{compNum} '= true;']);
end

if exist(eventLogPath,'dir')
    pathList = dir(eventLogPath);
    pathList = pathList(~ismember({pathList.name},{'.','..'}));
    if ~exist('searchDepth','var')||isempty(searchDepth)
        searchDepth = min([2,length(pathList)]);
    elseif searchDepth>length(pathList)
        warning('cannot search to requested depth. not enough log files. resetting searchDepth to highest poss number');
        searchDepth = length(pathList);
    else
        error('searchDepth has to be numeric and positive.please ensure');
    end
    [logDates order] = sort(cell2mat({pathList.datenum}),'descend');
else
    for compNum = 1:length(doDataLogComponents)
        eval([doDataLogComponents{compNum} '= false;']);
    end
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
        for compNum = 1:length(dataLogComponents)
            if ~isfield(events_data,dataLogComponents{compNum})
                eval([doDataLogComponents{compNum} '= false;']);
            end
        end
        
        for compNum = 1:length(dataLogComponents)
            if ~any(strcmp(dataLogComponents{compNum},{'ampState','penetrationParams'})) % input all non-standard analyses here
                eval(['doCurrent = ' doDataLogComponents{compNum} ';']);
                if doCurrent
                    if (~isempty(events_data(i).(dataLogComponents{compNum})))&&(all(~isnan(events_data(i).(dataLogComponents{compNum}))))
                        out.(dataLogOutput{compNum}) = events_data(i).(dataLogComponents{compNum});
                        eval([doDataLogComponents{compNum} '= false;']);
                    end
                end
            else
                % continue
            end
        end
        
        % Separately handle all non-standard data-extraction events.
        if doAmpState
            if iscell(events_data(i).ampState)
                isAnyAmpStateEmpty = any(cellfun(@isempty,events_data(i).ampState));
                isAnyAmpStateNan = any(cell2mat(cellfun(@isnan,events_data(i).ampState,'UniformOutput',false)));
                if ~isAnyAmpStateEmpty && ~isAnyAmpStateNan
                    ampState = events_data(i).ampState;
                    doAmpState = false;
                end
            end
        end
        
        if doPenetParams
            if ~isempty(events_data(i).penetrationParams)
                penetParams = events_data(i).penetrationParams;
                doPenetParams = false;
            end            
        end
        
        if i>1
            i = i-1;
            evalStr = 'doLoop = ';
            for compNum = 1:length(doDataLogComponents)
                evalStr = [evalStr doDataLogComponents{compNum} '||'];
            end
            evalStr = [evalStr 'false;'];
            eval(evalStr);
        else
            doLoop = false;
        end
    end
    
    if floor(now)~=floor(logDates(1))
        out.isNewDay = true;
    end
end


end