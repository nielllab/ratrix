function quit = waitForCommandsAndSendAck(datanet)
% this function keeps that data machine listening for commands from the stim computer and responds to each command with an ack
quit = false;
constants = getConstants(datanet);
message = [];
MAXSIZE=1024*1024;
CMDSIZE=1;

if strmatch(datanet.type, 'stim')
    error('must be called on datanet of type ''data''');
end

% 2/2/09 - start the event GUI now - we have to do it locally so that the data is within the scope of this daemon
% so that datanet can request a trial's worth of events
events_data=[];
eventsToSendIndex=1;
% ========================================================================================
% size of the GUI - parameters
oneRowHeight=25;
margin=10;
fieldWidth=100;
fWidth=2*margin+9*fieldWidth;
fHeight=margin+15*oneRowHeight+margin;

% ========================================================================================
% the GUI
f = figure('Visible','off','MenuBar','none','Name','neural GUI',...
    'NumberTitle','off','Resize','off','Units','pixels','Position',[50 50 fWidth fHeight],...
    'CloseRequestFcn',@cleanup);
    function cleanup(source,eventdata)
        % return event here
        %         events = guidata(f);
        %         events_data
        closereq;
        return;
    end % end cleanup function

    function updateDisplay()
        %         numToShow=str2double(get(numEventsToShow,'String'));
        %         numToShow=min(numToShow,length(events_data));
        numToShow=length(events_data);
        toShow=events_data(end-numToShow+1:end);
        dispStr='';
        lastP=0;
        lastPosition=[0 0 0];
        newP=true;
        for i=length(toShow):-1:1
            %         for i=1:length(toShow)
            % if this was a new penetration, get duration of previous
            if toShow(i).penetrationNum~=lastP
                if lastP~=0
                    % get the duration between the last event of lastP and the first event of lastP
                    % or should it be (now - firstEventOfLastP)?
                    lastPduration=events_data(find([events_data.penetrationNum]==lastP,1,'first')).time - ...
                        events_data(find([events_data.penetrationNum]==toShow(i).penetrationNum,1,'first')).time;
                    %                     lastP
                    [events_data.penetrationNum]
                    %                     i
                    %                     toShow
                    %                     find([events_data.penetrationNum]==lastP)
                    %                 lastPduration=events_data(find([events_data.penetrationNum]==lastP,1,'last')).time - ...
                    %                     events_data(find([events_data.penetrationNum]==lastP,1,'first')).time;
                    durStr=sprintf('%sh %smin', datestr(lastPduration,'HH'), datestr(lastPduration,'MM'));
                    appnd = sprintf('\nlast penetration duration: %s\n',durStr);
                    dispStr=[dispStr appnd];
                end
                % write new penetration #, anchor, and top
                appnd = sprintf('Penetration #%d:\n\tAP\tML\tZ\nAnchor\t%.2f\t%.2f\t%.2f\nTop\t%.2f\t%.2f\t%.2f\n', toShow(i).penetrationNum,...
                    toShow(i).surgeryAnchor, toShow(i).surgeryBregma);
                dispStr=[dispStr appnd];
                newP=true;
            end
            % write this event
            appnd = sprintf('%s\t',datestr(toShow(i).time,'HH:MM'));
            dispStr=[dispStr appnd];
            % display AP and ML coordinates if they are diff from last, or if new penetration
            for j=1:2
                if toShow(i).position(j)~=lastPosition(j) || newP
                    appnd = sprintf('%.2f\t',toShow(i).position(j));
                else
                    appnd = sprintf('\t');
                end
                dispStr=[dispStr appnd];
            end
            % display Z coord and comment
            appnd = sprintf('%.2f\t%s\n',toShow(i).position(3),toShow(i).comment);
            dispStr=[dispStr appnd];
            % update lastP
            lastP=toShow(i).penetrationNum;
            lastPosition=toShow(i).position;
            newP=false;
        end

        % now update the recentEventsDisplay
        set(recentEventsDisplay,'String',dispStr);
    end % end updateDisplay function


% ========================================================================================
% draw text labels for surgery anchor
APHeader = uicontrol(f,'Style','text','String','AP','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
MLHeader = uicontrol(f,'Style','text','String','ML','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+2*fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
ZHeader = uicontrol(f,'Style','text','String','Z','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+3*fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorLabel = uicontrol(f,'Style','text','String','Anchor','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaLabel = uicontrol(f,'Style','text','String','Bregma','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);

% ========================================================================================
% surgery anchor and bregma text fields
surgeryAnchorAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);

% checkbox to enable surgery field input
enableSurgeryFields = uicontrol(f,'Style','checkbox',...
    'String','unlock surgery fields','Enable','on','Visible','on',...
    'Value',0,'Units','pixels','Position',[2*margin+4*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth+margin*3 oneRowHeight],...
    'CallBack',@enableSurgeryEntry);
    function enableSurgeryEntry(source,eventdata)
        if get(enableSurgeryFields,'Value')==1
            set(surgeryAnchorAPField,'Enable','on');
            set(surgeryAnchorMLField,'Enable','on');
            set(surgeryAnchorZField,'Enable','on');
            set(surgeryBregmaAPField,'Enable','on');
            set(surgeryBregmaMLField,'Enable','on');
            set(surgeryBregmaZField,'Enable','on');
        else
            set(surgeryAnchorAPField,'Enable','off');
            set(surgeryAnchorMLField,'Enable','off');
            set(surgeryAnchorZField,'Enable','off');
            set(surgeryBregmaAPField,'Enable','off');
            set(surgeryBregmaMLField,'Enable','off');
            set(surgeryBregmaZField,'Enable','off');
        end
    end % end enableSurgeryEntry function

% ========================================================================================
% draw text labels for surgery anchor
APHeader = uicontrol(f,'Style','text','String','AP','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
MLHeader = uicontrol(f,'Style','text','String','ML','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+2*fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
ZHeader = uicontrol(f,'Style','text','String','Z','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+3*fieldWidth fHeight-oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryAnchorLabel = uicontrol(f,'Style','text','String','Surgery Anchor','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-2*oneRowHeight-margin fieldWidth oneRowHeight]);
surgeryBregmaLabel = uicontrol(f,'Style','text','String','Surgery Bregma','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-3*oneRowHeight-margin fieldWidth oneRowHeight]);

% ========================================================================================
% current anchor label
currentAnchorLabel = uicontrol(f,'Style','text','String','Current Anchor','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-4*oneRowHeight-2*margin fieldWidth oneRowHeight]);
% current anchor text field
currentAnchorAPField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+1*fieldWidth fHeight-4*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentAnchorMLField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+2*fieldWidth fHeight-4*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentAnchorZField = uicontrol(f,'Style','edit','String','nan','Units','pixels',...
    'Enable','off','Position',[1*margin+3*fieldWidth fHeight-4*oneRowHeight-2*margin fieldWidth oneRowHeight]);

% checkbox to enable current anchor field input
enableCurrentAnchorField = uicontrol(f,'Style','checkbox',...
    'String','unlock current anchor','Enable','on','Visible','on',...
    'Value',0,'Units','pixels','Position',[2*margin+4*fieldWidth fHeight-4*oneRowHeight-2*margin fieldWidth+margin*3 oneRowHeight],...
    'CallBack',@enableCurrentAnchorEntry);
    function enableCurrentAnchorEntry(source,eventdata)
        if get(enableCurrentAnchorField,'Value')==1
            set(currentAnchorAPField,'Enable','on');
            set(currentAnchorMLField,'Enable','on');
            set(currentAnchorZField,'Enable','on');
        else
            set(currentAnchorAPField,'Enable','off');
            set(currentAnchorMLField,'Enable','off');
            set(currentAnchorZField,'Enable','off');
        end
    end % end enableCurrentAnchorEntry function

% ========================================================================================
% number of recent events to show
numEventsToShow = uicontrol(f,'Style','edit','String','10','Visible','off','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','center', ...
    'Position',[3*margin+6*fieldWidth fHeight-oneRowHeight-margin fieldWidth/2 oneRowHeight]);
numEventsToShowLabel = uicontrol(f,'Style','text','String','recent events to show','Visible','off','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','left', ...
    'Position',[3*margin+6.5*fieldWidth fHeight-oneRowHeight-margin fieldWidth+2*margin oneRowHeight]);

% ========================================================================================
% current event label, fields, and "submit" button
currentEventLabel = uicontrol(f,'Style','text','String','Current','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center', ...
    'Position',[margin+0*fieldWidth fHeight-5*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentAPField = uicontrol(f,'Style','edit','Units','pixels','String','nan',...
    'Enable','on','Position',[1*margin+1*fieldWidth fHeight-5*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentMLField = uicontrol(f,'Style','edit','Units','pixels','String','nan',...
    'Enable','on','Position',[1*margin+2*fieldWidth fHeight-5*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentZField = uicontrol(f,'Style','edit','Units','pixels','String','nan',...
    'Enable','on','Position',[1*margin+3*fieldWidth fHeight-5*oneRowHeight-2*margin fieldWidth oneRowHeight]);
currentComment = uicontrol(f,'Style','edit','Units','pixels','String','',...
    'Enable','on','Position',[1*margin+4*fieldWidth fHeight-5*oneRowHeight-2*margin fieldWidth*4 oneRowHeight]);

currentEventSubmit = uicontrol(f,'Style','pushbutton','String','enter','Visible','on','Units','pixels',...
    'FontWeight','bold','HorizontalAlignment','center','CallBack',@logEvent, ...
    'Position',[2*margin+8*fieldWidth fHeight-5*oneRowHeight-2*margin fieldWidth oneRowHeight]);
    function logEvent(source,eventdata)
        % make a new entry in events
        events_data(end+1).time=now;
        events_data(end).surgeryAnchor=[str2double(get(surgeryAnchorAPField,'String')) str2double(get(surgeryAnchorMLField,'String')) str2double(get(surgeryAnchorZField,'String'))];
        events_data(end).surgeryBregma=[str2double(get(surgeryBregmaAPField,'String')) str2double(get(surgeryBregmaMLField,'String')) str2double(get(surgeryBregmaZField,'String'))];
        events_data(end).currentAnchor=[str2double(get(currentAnchorAPField,'String')) str2double(get(currentAnchorMLField,'String')) str2double(get(currentAnchorZField,'String'))];
        events_data(end).position=[str2double(get(currentAPField,'String')) str2double(get(currentMLField,'String')) str2double(get(currentZField,'String'))];
        % update pNum if necessary (if AP or ML differ from last)
        if length(events_data)>=2 && any(events_data(end-1).position(1:2)~=events_data(end).position(1:2))
            events_data(end).penetrationNum=events_data(end-1).penetrationNum+1;
        elseif length(events_data)==1 % first time
            events_data(end).penetrationNum=1;
        else
            events_data(end).penetrationNum=events_data(end-1).penetrationNum;
        end
        events_data(end).comment=get(currentComment,'String');

        %         dispStr=sprintf('logged %s %s %s at pNum=%d',get(currentAPField,'String'),get(currentMLField,'String'),get(currentZField,'String'), events_data(end).penetrationNum);
        %         disp(dispStr);
        updateDisplay();
        % flush the comments buffer
        set(currentComment,'String','');
    end % end logEvent function

% ========================================================================================
% display box
recentEventsDisplay = uicontrol(f,'Style','edit','String','recent events','Visible','on','Units','pixels',...
    'FontWeight','normal','HorizontalAlignment','left','Max',2,'Min',0, ...
    'Position',[margin+0*fieldWidth fHeight-14*oneRowHeight-1*margin fieldWidth*8-margin oneRowHeight*8]);

% ========================================================================================
% turn on the GUI
set(f,'Visible','on');

% ========================================================================================
% DATANET STUFF
% open a socket connection
datanet.sockcon = pnet('tcpsocket', datanet.port);
% first connection - keep trying to get a connection using tcplisten
datacon = -1;
while datacon == -1
    datacon=pnet(datanet.sockcon,'tcplisten');
end


% local variables that can be set by commands
% parameters.refreshRate - in hz
% parameters.resolution - [width height]
parameters=[];

% now we have a connection from client
pnet(datacon,'setreadtimeout', 5); % set timeout to (hopefully) affect pnet_getvar
pnet(datacon,'setwritetimeout', 5);
specificCommand=[];

% ========================================================================================
% ENTERING LISTENER LOOP
while ~quit
    success = false;
    received = pnet(datacon,'read',CMDSIZE,'double','noblock');

    if ~isempty(received) % if we received something, decide what to do with the command
        size(received)
        received
        if ~isempty(specificCommand) && received~=specificCommand
            error('received a faulty command %d when waiting for the specific command %d', received, specificCommand);
        end
        switch received % decide what to do based on what command was received
            case constants.startConnectionCommands.S_START_DATA_LISTENER_CMD
                success = true;
                fprintf('we got a command to start the data listener\n');
                message = constants.startConnectionCommands.D_LISTENER_STARTED;



            case constants.stimToDataCommands.S_SET_AI_PARAMETERS_CMD
                params = pnet_getvar(datacon);
                datanet.ai_parameters = params;
                success = true;
                message = constants.dataToStimResponses.D_AI_PARAMETERS_SET;
            case constants.stimToDataCommands.S_SET_LOCAL_PARAMETERS_CMD
                parameters = pnet_getvar(datacon);
                success = true;
                message = constants.dataToStimResponses.D_LOCAL_PARAMETERS_SET;
            case constants.stimToDataCommands.S_START_RECORDING_CMD
                success = true;
                % do something here to start recording (turn on NIDAQ)
                % START NIDAQ HERE
                % =================================================================================================
                % get parameters from datanet object field ai_parameters, or use defaults
                ai_parameters = datanet.ai_parameters;
                if isfield(ai_parameters, 'numChans')
                    numChans = ai_parameters.numChans;
                else
                    numChans = 3;
                end
                if isfield(ai_parameters, 'sampRate')
                    sampRate = ai_parameters.sampRate;
                else
                    sampRate = 40000;
                end
                if isfield(ai_parameters, 'inputRanges')
                    inputRanges = ai_parameters.inputRanges;
                else
                    inputRanges = repmat([-1 6],numChans,1);
                end
                if isfield(ai_parameters, 'recordingFile')
                    recordingFile = ai_parameters.recordingFile;
                else
                    recordingFile = [];
                end
                % start NIDAQ
                sprintf('starting NIDAQ with %d channels %d sampRate',numChans,sampRate)
                inputRanges

                [ai chans recordingFile]=openNidaqForAnalogRecording(numChans,sampRate,inputRanges,recordingFile);
                ai
                set(ai)
                get(ai)
                get(ai,'Channel')
                daqhwinfo(ai)
                chans
                set(chans(1))
                get(chans(1))
                start(ai);
                % =================================================================================================
                fprintf('we got a command to start recording and sent ack\n');
                message = constants.dataToStimResponses.D_RECORDING_STARTED;
            case constants.stimToDataCommands.S_TIMESTAMP_CMD
                success = true;
                % do something here to store local timestamp
                % INSERT TIMESTAMP HERE
                % =================================================================================================
                % get a single sample using getdata (okay to extract from engine b/c streamed to disk)
                flushdata(ai);
                % start a matlab-based local timestamp to also keep track of roughly how long a trial records for
                matlabTimeStamp = GetSecs();
                % =================================================================================================
                fprintf('we got a command to store a local timestamp\n');
                message = constants.dataToStimResponses.D_TIMESTAMPED;
                [timestampData,timestamp] = getdata(ai,1);
            case constants.stimToDataCommands.S_SAVE_DATA_CMD
                % we got a S_SAVE_DATA_CMD - try to read filename now
                filename=pnet(datacon,'read',MAXSIZE,'char','noblock');
                while isempty(filename)
                    success=false;
                    filename=pnet(datacon,'read',MAXSIZE,'char','noblock');
                end
                success = true;
                % got a filename - save to it

                % do something here to get data from NIDAQ using local timestamp variable
                % GET DATA HERE
                % =================================================================================================
                samplingRate = get(ai,'SampleRate');
                estimatedElapsedTime = GetSecs() - matlabTimeStamp; % estimated time of recording to retrieve
                estimatedNumberOfSamples = (estimatedElapsedTime+1)*samplingRate; % estimated number of samples to get - add a 1sec buffer
                if estimatedNumberOfSamples > get(ai,'SamplesAvailable')
                    estimatedNumberOfSamples
                    newnum=get(ai,'SamplesAvailable')
                    warning('we requested more samples from the nidaq than available - resetting to max available!!');
                    estimatedNumberOfSamples=newnum;
                end
                [neuralData, neuralDataTimes] = getdata(ai, estimatedNumberOfSamples);
                firstNeuralDataTime = neuralDataTimes(1);
                % now go through and throw out trialData that is past our timestamp
                neuralData(find(neuralDataTimes<timestamp), :) = [];
                neuralDataTimes(find(neuralDataTimes<timestamp)) = [];
                % CHANGE MESSAGE TO BE neuralDataTimes, not a random data
               
                % =================================================================================================
                fullFilename = fullfile(datanet.storepath, 'neuralRecords', filename);
                %                 trialData=[10 11 12];
                %                 times = [1 2 3 4 5 6 7];
                save(fullFilename, 'neuralData', 'neuralDataTimes', 'samplingRate', 'matlabTimeStamp',...
                    'firstNeuralDataTime', 'parameters');
                fprintf('we got a command to send a trial''s worth of data\n');
                message = constants.dataToStimResponses.D_DATA_SAVED;
            case constants.stimToDataCommands.S_SEND_EVENT_DATA_CMD
                % get events from events_data
                success=true;
                neuralEvents=events_data(eventsToSendIndex:end);
                eventsToSendIndex=length(events_data)+1;
                specificCommand=constants.stimToDataCommands.S_ACK_EVENT_DATA_CMD;
                pnet_putvar(datacon,neuralEvents);
                message = constants.dataToStimResponses.D_EVENT_DATA_SENT;
            case constants.stimToDataCommands.S_STOP_RECORDING_CMD
                success = true;
                % do something here to stop recording (turn off NIDAQ)
                % STOP NIDAQ HERE
                % =================================================================================================
                stop(ai);
                delete(ai)
                clear ai
                % =================================================================================================
                fprintf('we got a command to stop recording\n');
                message = constants.dataToStimResponses.D_RECORDING_STOPPED;
            case constants.stimToDataCommands.S_SHUTDOWN_CMD
                success = true;
                fprintf('we got a command to shutdown\n');
                quit = true;
                message = constants.dataToStimResponses.D_SHUTDOWN;
            case constants.stimToDataCommands.S_SET_STOREPATH_CMD
                path=pnet(datacon,'read',MAXSIZE,'char','noblock');
                while isempty(path)
                    success=false;
                    path=pnet(datacon,'read',MAXSIZE,'char','noblock');
                end
                success=true;
                datanet.storepath = path;
                % 11/5/08 - move directory creation here (create dirs when we set the path)
                %                 mkdir(path);
                mkdir(fullfile(path, 'eyeRecords'));
                mkdir(fullfile(path, 'neuralRecords'));
                mkdir(fullfile(path, 'stimRecords'));
                fprintf('we got a command to set the storepath to %s\n', path);
                message = constants.dataToStimResponses.D_STOREPATH_SET;
            case constants.stimToDataCommands.S_ACK_EVENT_DATA_CMD
                success=true;
                fprintf('we received an event data ack from stim, resetting specificCommand to []\n');
                specificCommand=[];
                message = constants.dataToStimResponses.D_EVENT_DATA_ACK_RECVD;
            otherwise
                success = false;
                received
                fprintf('we got an unrecognized command\n');
        end
    else % if nothing received, try pnet_getvar
        % failed to receive valid command using read - try using pnet_getvar
        %             received = pnet_getvar(serv);
        %         if ~isempty(received) % IGNORE THIS PART FOR NOW - PNET_GETVAR disconnects remote host for some reason
        %             success = true;
        %             message = constants.dataToStimResponses.D_RECEIVED_VAR;
        %             % just echo received for now
        %             received
        %             fprintf('we got something through pnet_getvar\n');
        %         end
    end


    % now send appropriate message to the stim computer (ack or fail)
    if success
        pnet(datacon,'write',message);
    elseif ~success % dont write anything when fails
        %             pnet(con,'write',-1);
    else
        error('if neither successful nor unsuccessful then what is this?')
    end
    % send ack to stim computer if successful
    %%%% THIS IS WHERE BEHAVIOR WILL BE DIFFERENT FOR DIFFERENT RECEIVED COMMANDS
    % if we received a S_START_RECORDING_CMD, then run local calls to start recording, then send ack
    % if we received a S_SAVE_DATA_CMD, then just send data (tell stim to listen)
    % etc etc
end


end % end function