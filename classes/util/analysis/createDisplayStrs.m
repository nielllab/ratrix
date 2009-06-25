function dispStrs = createDisplayStrs(events_data,labels,mode)

numToShow=length(events_data);
toShow=events_data(end-numToShow+1:end);
dispStrs={};
lastP=0;
lastPosition=[0 0 0];
firstTrialNumOfInterval=1;
firstStartTimeOfInterval=[];
lastTrialNum=1;
lastStimClass='unknown';
lastEventType=[];
lastTrialIntervalInd=[];
newP=true;
switch mode
    case 'full'
        for i=length(toShow):-1:1
            switch toShow(i).eventType
                case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                        'electrode bend','clapping','rat obs','anesth check'}
                    % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                    str=sprintf('%s\t%d\t',datestr(toShow(i).time,'HH:MM'),toShow(i).eventNumber);
                    if toShow(i).penetrationNum~=lastP
                        appnd=sprintf('Pene#:%d\t',toShow(i).penetrationNum);
                        newP=true;
                        str=[str appnd];
                    else
                        appnd=sprintf('\t');
                        str=[str appnd];
                    end
                    % AP and ML (if differ from last)
                    for j=1:2
                        if isfield(toShow(i),'position') && (toShow(i).position(j)~=lastPosition(j) || newP)
                            appnd = sprintf('%.2f\t%.2f\t',toShow(i).position(j));
                        else
                            appnd = sprintf('\t');
                        end
                        str=[str appnd];
                    end
                    % Z and type-specific comment
                    appnd = sprintf('%.2f\t',toShow(i).position(3));
                    str=[str appnd];
                    if ~strcmp(toShow(i).eventType,'comment')
                        appnd=sprintf('%s\t',toShow(i).eventType);
                        str=[str appnd];
                    end
                    if ~isempty(toShow(i).eventParams)
                        fn=fields(toShow(i).eventParams);
                    else
                        fn=[];
                    end
                    for j=1:length(fn)
                        val=toShow(i).eventParams.(fn{j});
                        if ~isnan(val)
                            if isnumeric(val)
                                val=num2str(val);
                            end
                            appnd=sprintf('%s:%s\t',fn{j},val);
                            str=[str appnd];
                        end
                    end
                    appnd=sprintf('%s',toShow(i).comment);
                    str=[str appnd];
                    % update lastP
                    lastP=toShow(i).penetrationNum;
                    lastPosition=toShow(i).position;
                    newP=false;
                case {'trial start','trial end','cell start','cell stop'}
                    % these only have an eventType, time, and eventNumber
                    str=sprintf('%s\t%d\t%s',datestr(toShow(i).time,'HH:MM'),toShow(i).eventNumber,toShow(i).eventType);
                    if strcmp(toShow(i).eventType,'trial start') % also have trialNumber
                        str=sprintf('%s #%d',str,toShow(i).eventParams.trialNumber);
                    end
                otherwise
                    toShow(i)
                    error('unrecognized event type');
            end
            dispStrs{end+1}=str;
        end

    case 'condensed'
        for i=1:length(toShow)
            switch toShow(i).eventType
                case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                        'electrode bend','clapping','rat obs','anesth check'}
                    % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                    str=sprintf('%s\ttrial %d:\t',datestr(toShow(i).time,'HH:MM'),lastTrialNum);
                    if toShow(i).penetrationNum~=lastP
                        appnd=sprintf('Pene#:%d\t',toShow(i).penetrationNum);
                        newP=true;
                        str=[str appnd];
                    else
                        appnd=sprintf('\t');
                        str=[str appnd];
                    end
                    % AP and ML (if differ from last)
                    for j=1:2
                        if isfield(toShow(i),'position') && (toShow(i).position(j)~=lastPosition(j) || newP)
                            appnd = sprintf('%.2f\t%.2f\t',toShow(i).position(j));
                        else
                            appnd = sprintf('\t');
                        end
                        str=[str appnd];
                    end
                    % Z and type-specific comment
                    appnd = sprintf('%.2f\t',toShow(i).position(3));
                    str=[str appnd];
                    if ~strcmp(toShow(i).eventType,'comment')
                        appnd=sprintf('%s\t',toShow(i).eventType);
                        str=[str appnd];
                    end
                    if ~isempty(toShow(i).eventParams)
                        fn=fields(toShow(i).eventParams);
                    else
                        fn=[];
                    end
                    for j=1:length(fn)
                        val=toShow(i).eventParams.(fn{j});
                        if ~isnan(val)
                            if isnumeric(val)
                                val=num2str(val);
                            end
                            appnd=sprintf('%s:%s\t',fn{j},val);
                            str=[str appnd];
                        end
                    end
                    appnd=sprintf('%s',toShow(i).comment);
                    str=[str appnd];
                    % update lastP
                    lastP=toShow(i).penetrationNum;
                    lastPosition=toShow(i).position;
                    newP=false;
                    dispStrs{end+1}=str; % always add a new str to display
                case {'trial start','trial end'}
                    if strcmp(toShow(i).eventType,'trial start')
                        if strcmp(toShow(i).eventParams.stimManagerClass,lastStimClass)
                            % same stim still
                            str=sprintf('%s\ttrial %d-%d:\t%s',datestr(firstStartTimeOfInterval,'HH:MM'),firstTrialNumOfInterval,...
                                toShow(i).eventParams.trialNumber,toShow(i).eventParams.stimManagerClass);
                            dispStrs{lastTrialIntervalInd}=str;
                        else
                            % new stim class
                            firstTrialNumOfInterval=toShow(i).eventParams.trialNumber;
                            firstStartTimeOfInterval=toShow(i).time;
                            str=sprintf('%s\ttrial %d-%d:\t%s',datestr(toShow(i).time,'HH:MM'),firstTrialNumOfInterval,...
                                toShow(i).eventParams.trialNumber,toShow(i).eventParams.stimManagerClass);
                            if lastTrialNum~=0 % dont display the first 'interval' of unknown
                                dispStrs{end+1}=str;
                            end
                            lastTrialIntervalInd=length(dispStrs);
                        end
                        lastTrialNum=toShow(i).eventParams.trialNumber;
                        lastStimClass=toShow(i).eventParams.stimManagerClass;
                    end
                case {'cell start','cell stop'}
                    % these only have an eventType, time, eventNumber, and trialNumber
                    str=sprintf('%s\ttrial %d:\t%s',datestr(toShow(i).time,'HH:MM'),lastTrialNum,toShow(i).eventType);
                    dispStrs{end+1}=str;
                otherwise
                    toShow(i)
                    error('unrecognized event type');
            end
        end
        dispStrs=fliplr(dispStrs);
    case 'grouper'
        for i=length(toShow):-1:1
            switch toShow(i).eventType
                case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                        'electrode bend','clapping','rat obs','anesth check'}
                    % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                    str=sprintf('%g --- %d  %s  ',labels(i),toShow(i).eventNumber,datestr(toShow(i).time,'HH:MM'));
                    appnd=sprintf('%s  %s',toShow(i).eventType,toShow(i).comment);
                    str=[str appnd];
                case {'trial start','trial end','cell start','cell stop'}
                    % these only have an eventType, time, and eventNumber
                    str=sprintf('%g --- %d  %s  %s',labels(i),toShow(i).eventNumber,datestr(toShow(i).time,'HH:MM'),toShow(i).eventType);
                    if strcmp(toShow(i).eventType,'trial start') % also have trialNumber
                        str=sprintf('%s #%d',str,toShow(i).eventParams.trialNumber);
                    end
                otherwise
                    toShow(i)
                    error('unrecognized event type');
            end
            dispStrs{end+1}=str;
        end
    otherwise
        error('unsupported mode for now');
end