function dispStrs = createDisplayStrs(events_data,labels,mode)

numToShow=length(events_data);
toShow=events_data(end-numToShow+1:end);
dispStrs={};
lastP=0;
lastPosition=[0 0 0];
firstTrialNumOfInterval=1;
firstStartTimeOfInterval=[];
lastTrialNum=1;
lastTrialType='unknown'; % we used to display stim class, but now use stepName
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
    case 'stims'
        strEvents='';
        lastTrialTime=0;
        cellCount=0;
        for i=1:length(toShow)
            if ~isempty(toShow(i).eventType)  % why do we need this... might be an error witrh stopped cell
                  switch toShow(i).eventType
                     case {'comment'}
                        str=toShow(i).comment;
                        strEvents=[strEvents '; ' str];
                    case {'comment','top of fluid','top of brain','ctx cell','hipp cell','deadzone','theta chatter','visual hash','visual cell',...
                            'electrode bend','clapping','rat obs','anesth check'}
                        str=toShow(i).eventType;
                        if ~strcmp(toShow(i).comment,'')
                            str=[str ', ' toShow(i).comment];
                        end
                        strEvents=[strEvents '; ' str];
                    case {'trial end'}
                        %do nothing
                    case {'trial start'}

                        if strcmp(toShow(i).eventType,'trial start')
                            if isfield(toShow(i).eventParams,'stepName')
                                trialType=toShow(i).eventParams.stepName;
                            else
                                %old records don't have stepName listed
                                %and instead display by stim manager class
                                trialType=toShow(i).eventParams.stimManagerClass;
                            end
                            if strcmp(trialType,lastTrialType)
                                % same step still 
                                str=sprintf('%s%s[%d %d]%s%s',datestr(firstStartTimeOfInterval,'HH:MM'),fixedTab,firstTrialNumOfInterval,...
                                    toShow(i).eventParams.trialNumber,fixedTab,trialType);
                                dispStrs{lastTrialIntervalInd}=str;
                            else
                                % new stim class
                                firstTrialNumOfInterval=toShow(i).eventParams.trialNumber;
                                firstStartTimeOfInterval=toShow(i).time;
                                str=sprintf('%s%s[%d %d]%s%s',datestr(toShow(i).time,'HH:MM'),fixedTab,firstTrialNumOfInterval,...
                                    toShow(i).eventParams.trialNumber,fixedTab,trialType);
                                
                                %(toShow(i).time-lastTrialTime)*(24*60*60)
                                if 0%(toShow(i).time-lastTrialTime)*(24*60*60)<15 % 15 seconds is deemed short
                                    %str=[str fixedTab 'short'];
                                    %BLANK IT OUT
                                    %toShow(i).eventParams.trialNumber
                                    str=['shortTrial'];% char(32*ones(1,length(str)-10))]; % a bunch of spaces
                                    dispStrs{end+1}=str;
                                else
                                    if lastTrialNum~=0 % dont display the first 'interval' of unknown
                                        %dispStrs{end+1}=str;
                                        numberIndentSpaces=40;
                                        textWrapLength=110;
                                        [junk wrappedTextCells]=wrapText([str strEvents],'',textWrapLength,numberIndentSpaces);
                                        for ii=1:length(wrappedTextCells)%:-1:1
                                            dispStrs{end+1}=wrappedTextCells{ii}; % always add a new str to display
                                        end
                                        strEvents='';
                                    end
                                end
                                lastTrialIntervalInd=length(dispStrs);
                            end
                            lastTrialNum=toShow(i).eventParams.trialNumber;
                            lastTrialTime=toShow(i).time;
                            lastTrialType=trialType;
                        end
                      case {'cell start'}
                          %str=toShow(i).eventType; % consider a cell counter 
                          cellCount=cellCount+1;
                          str=sprintf('*** CELL %d ***',cellCount);
                          dispStrs{end+1}='';
                          dispStrs{end+1}=str;
                      case {'cell stop'}
                          dispStrs{end+1}='';
                      otherwise
                          toShow(i)
                          error('unrecognized event type');
                  end
            end
        end
        removeLines=[];
        for i=1:length(dispStrs)
            if strcmp(dispStrs{i},'shortTrial')
                removeLines=[removeLines i];
            end
        end
        dispStrs(removeLines)=[]; % get rid of the short trials (probably KTs or dup removal)
        %dispStrs=fliplr(dispStrs); % do not flip text to be reverse chronological
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
                        for ii=length(wrappedTextCells):-1:1
                            dispStrs{end+1}=wrappedTextCells{ii}; % always add a new str to display
                        end
                    case {'trial start','trial end'}

                        if strcmp(toShow(i).eventType,'trial start')
                            
                            if isfield(toShow(i).eventParams,'stepName')
                                trialType=toShow(i).eventParams.stepName;
                            else
                                %old records don't have stepName listed
                                %and instead display by stim manager class
                                trialType=toShow(i).eventParams.stimManagerClass;
                            end
                            if strcmp(trialType,lastTrialType)
                                % same step still 
                                str=sprintf('%s%str%d-%d%s%s',datestr(firstStartTimeOfInterval,'HH:MM'),fixedTab,firstTrialNumOfInterval,...
                                    toShow(i).eventParams.trialNumber,fixedTab,trialType);
                                dispStrs{lastTrialIntervalInd}=str;
                            else
                                % new stim class
                                firstTrialNumOfInterval=toShow(i).eventParams.trialNumber;
                                firstStartTimeOfInterval=toShow(i).time;
                                str=sprintf('%s%str%d-%d%s%s',datestr(toShow(i).time,'HH:MM'),fixedTab,firstTrialNumOfInterval,...
                                    toShow(i).eventParams.trialNumber,fixedTab,trialType);
                                if lastTrialNum~=0 % dont display the first 'interval' of unknown
                                    dispStrs{end+1}=str;
                                end
                                lastTrialIntervalInd=length(dispStrs);
                            end
                            lastTrialNum=toShow(i).eventParams.trialNumber;
                            lastTrialType=trialType;
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


