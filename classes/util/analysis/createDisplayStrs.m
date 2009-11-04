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
fixedTab='    ';
textWrapLength=70;
numberIndentSpaces=100;
switch mode
    case 'full'
        for i=length(toShow):-1:1
            switch toShow(i).eventType
                case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                        'electrode bend','clapping','rat obs','anesth check'}
                    % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                    str=sprintf('%s\t%d\t',datestr(toShow(i).time,'HH:MM'),toShow(i).eventNumber);
                    if toShow(i).penetrationNum~=lastP
                        appnd=sprintf('Pen#%d\t',toShow(i).penetrationNum);
                        newP=true;
                        str=[str appnd];
                    else
                        appnd=sprintf('\t');
                        str=[str appnd];
                    end
                    % AP and ML (if differ from last)
                    thisPosition=getPositionInBregmaCoordinates(toShow,i);
                    for j=1:3
                        if isfield(toShow(i),'position') && (thisPosition(j)~=lastPosition(j) || newP) && ~isnan(thisPosition(j))
                            %appnd = sprintf('%.2f\t%.2f\t',toShow(i).position(j));
                            %appnd = sprintf('%.2f\t%.2f\t',thisPosition(j));
                            appnd=sprintf('%.2f (%.2f)\t',thisPosition(j),toShow(i).position(j));
                        else
                            appnd = sprintf('\t');
                        end
                        str=[str appnd];
                    end

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
            if ~isempty(toShow(i).eventType)  % why do we need this... might be an error witrh stopped cell
                switch toShow(i).eventType
                    case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                            'electrode bend','clapping','rat obs','anesth check'}
                        % all of these have MP,AP,Z,penetration# fields and need to have the penetration index handling
                        str=sprintf('%s%strial %d%s',datestr(toShow(i).time,'HH:MM'),fixedTab,lastTrialNum,fixedTab);
                        if toShow(i).penetrationNum~=lastP
                            appnd=sprintf('Pen#%d\t',toShow(i).penetrationNum);
                            newP=true;
                            str=[str appnd];
                        else
                            appnd=sprintf('\t');
                            str=[str appnd];
                        end
                        % AP and ML (if differ from last)
                        thisPosition=getPositionInBregmaCoordinates(toShow,i);
                        for j=1:2
                            if isfield(toShow(i),'position') && (thisPosition(j)~=lastPosition(j) || newP) && ~isnan(thisPosition(j))
                                %appnd = sprintf('%.2f\t%.2f\t',toShow(i).position(j));
                                appnd = sprintf('%.2f  %.2f  ',thisPosition(j));
                            else
                                appnd = sprintf('          ');
                            end
                            str=[str appnd];
                        end
                        % Z and type-specific comment
                        if ~isnan(thisPosition(3))
                            appnd=sprintf('%.2f (%.2f)\t',thisPosition(3),toShow(i).position(3));
                        end
                        str=[str appnd];
                        
                        %%%%start main text
                        mainText=[];
                        if ~strcmp(toShow(i).eventType,'comment')
                            appnd=sprintf('%s%s',toShow(i).eventType,fixedTab);
                            mainText=[mainText appnd];
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
                                appnd=sprintf('%s:%s, ',fn{j},val);
                                
                                mainText=[mainText appnd];
                            end
                        end
                        appnd=sprintf('%s',toShow(i).comment);
                        mainText=[mainText appnd];
                        %%% end main text
                        
                        [junk wrappedTextCells]=wrapText(mainText,str,textWrapLength,numberIndentSpaces);
                        % update lastP
                        lastP=toShow(i).penetrationNum;
                        lastPosition=thisPosition;
                        newP=false;
                        for i=length(wrappedTextCells):-1:1
                            dispStrs{end+1}=wrappedTextCells{i}; % always add a new str to display
                        end
                    case {'trial start','trial end'}
                        if strcmp(toShow(i).eventType,'trial start')
                            if strcmp(toShow(i).eventParams.stimManagerClass,lastStimClass)
                                % same stim still
                                str=sprintf('%s%str%d-%d%s%s',datestr(firstStartTimeOfInterval,'HH:MM'),fixedTab,firstTrialNumOfInterval,...
                                    toShow(i).eventParams.trialNumber,fixedTab,toShow(i).eventParams.stimManagerClass);
                                dispStrs{lastTrialIntervalInd}=str;
                            else
                                % new stim class
                                firstTrialNumOfInterval=toShow(i).eventParams.trialNumber;
                                firstStartTimeOfInterval=toShow(i).time;
                                str=sprintf('%s%str%d-%d%s%s',datestr(toShow(i).time,'HH:MM'),fixedTab,firstTrialNumOfInterval,...
                                    toShow(i).eventParams.trialNumber,fixedTab,toShow(i).eventParams.stimManagerClass);
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
                        str=sprintf('%s%strial %d%s%s',datestr(toShow(i).time,'HH:MM'),fixedTab,lastTrialNum,fixedTab,toShow(i).eventType);
                        dispStrs{end+1}=str;
                    otherwise
                        toShow(i)
                        error('unrecognized event type');
                end
            end
        end
        dispStrs=fliplr(dispStrs);
    case 'grouper'
        for i=length(toShow):-1:1
            % unable to comprehend why toshow is not a string! HACKING AWAY
            if ~ischar(toShow(i).eventType)
                toShow(i)
                toShow(i).eventType
                warning('eventType is empty. Resetting it with a warning')
                toShow(i).eventType = 'WARNING:empty event';
            end
            
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
                case {'WARNING:empty event'}
                    % this is a hack to deal with empty eventType. deal
                    % with this later.
                    str=sprintf('%g --- %d  %s',labels(i),toShow(i).eventNumber,toShow(i).eventType);
                otherwise
                    toShow(i)
                    error('unrecognized event type');
            end
            dispStrs{end+1}=str;
        end
    otherwise
        error('unsupported mode for now');
end

function [wrapedText textInCell]=wrapText(mainText,startLineString,textWrapLength,numberIndentSpaces);
%returns wrapedText which can be used with fprintf, but actually we need it
%in a cell without /n's, so we pass it out in a cell for each line

if length(mainText)<textWrapLength
    done=1;
    wrapedText=mainText;
    textInCell{1}=[startLineString mainText];
else
    done=0;
    lineNumber=0;
    lineBreak=0;
    wrapedText=[];
end

spaces=[''];
for i=1:numberIndentSpaces
    spaces=[spaces ' '];
end

while ~done
    lineNumber=lineNumber+1;
    lineStart=lineBreak+1;
    
    if lineStart+textWrapLength>length(mainText)
        % the line needs no more breaking, at the end
        wrapedText=[wrapedText mainText(lineStart:end)];
        textInCell{lineNumber}=[spaces mainText(lineStart:end)];
        
        %fprintf(wrapedText)
        %disp('finish!')
        done=1;
        break
    else  % find a place to break the line
        spaceLocations=strfind(mainText,' ');
        lineBreak=lineStart+textWrapLength;  % default if we can't find an appropriate space candidate
        if ~isempty(spaceLocations)
            candidate=max(spaceLocations(spaceLocations<lineStart+textWrapLength));
        end
        if ~isempty(candidate)
            lineBreak=candidate;
        end
    end
    
    wrapedText=[wrapedText mainText(lineStart:lineBreak) '\n' spaces];
    if lineNumber==1
        textInCell{lineNumber}=[startLineString mainText(lineStart:lineBreak)];
    else
        textInCell{lineNumber}=[spaces mainText(lineStart:lineBreak)];
    end
    %     if lineNumber>4
    %         keyboard
    %     end
end


