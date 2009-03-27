% i looked into the error:
% CreateMXFEvent : wrong pointer argument
% 
% this happens when
% type = Eyelink('GetNextDataType') returns 63 and then you call
% Eyelink('getfloatdata', type) 
% 
% the attached is a stripped down version of fixationSoundDemo that never encounters this problem.
% 
% my conclusion is that all the pauses in eyeTracker/testEyeData are letting the queue on the client fill to capacity, which is reacting less gracefully than it might.  if i put WaitSecs of more than .18 after my buffer drains, i get the same failure.
% 
% if we look eyelink_get_next_data up in the 'EyeLink Programmers Guide.pdf', the first hit is:
% 
% 13.3.2 Communication by Tracker Messages
% 
% When messages are included in the real-time link data, each message sent to the tracker is sent back through
% the link as well. These messages tend to be sent in bursts every few milliseconds, and each burst may
% contain several messages. EyeLink tracker software is optimized specifically to handle large amounts of
% network traffic, and can usually handle messages as fast asWindows can send them over the link. However,
% Windows (especially Windows 98 and 2000) is not as good at receiving messages back, and if messages
% are sent too rapidly from the main application, the listener application may drop some data. From tests on
% a 1.5 GHz PC running Windows 2000, it appears to be safe to send a burst of up to 5 messages every 8
% milliseconds or so. Dropped data can be detected by the presence of LOST_DATA_EVENT events when
% reading link data with eyelink_get_next_data().
% 
% 
% then, if we look up LOST_DATA_EVENT, we find the following:
% 
% 7.2.2 Event Data
% ...
% #define LOST_DATA_EVENT 0x3F // NEW: Event flags gap in data stream
% 
% The LOST_DATA_EVENT is a newly added event, introduced for version 2.1 and later, and produced
% within the DLL to mark the location of lost data. It is possible that data may be lost, either during recording
% with real-time data enabled, or during playback. This might happen because of a lost link packet or because
% data was not read fast enough (data is stored in a large queue that can hold 2 to 10 seconds of data, and once
% it is full the oldest data is discarded to make room for new data). This event has no data or time associated
% with it.
% 
% 
% note that dec2hex(63) = 0x3F.  other than this new constant, these events match the definitions in EyelinkInitDefaults.m and geteventtype.m.  beats me why this is the only one in hex.
% i interpret that last sentence to mean that one should not try to read this type of event into a structure using getfloatdata, cuz there's nothing in there.  i guess making it hex is their way of distinguishing it as more of a placekeeper than an event that holds data that needs to be unpacked.

function [out cache]=eyelinkTest
format long g
clear all
clear classes
close all
clc

KbName('UnifyKeyNames')

edfFile='demo.edf'; %name of remote data file to create
screenNum = 1; % use main screen

initEyePos=[];

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if (Eyelink('initialize') ~= 0)
    error('could not init connection to Eyelink')
    return;
end;

try
    % STEP 2 - omitting opening ptb window

    oldPriority = Priority(MaxPriority('KbCheck'));

    % STEP 3 - omitting passing ptb window to eyelink
    % perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults();

    % make sure that we get gaze data from the Eyelink
    status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,HMARKER');
    if status~=0
        status
        error('link_sample_data error')
    end

    status=Eyelink('command','inputword_is_window = ON');
    if status~=0
        status
        error('inputword_is_window error')
    end

    % open file to record data to (just an example, not required)
    status=Eyelink('openfile',edfFile);
    if status~=0
        status
        error('openfile error')
    end

    % STEP 4 omitted (mac only)

    [version, versionString]  = Eyelink('GetTrackerVersion')
    'hit key to continue'
    pause

    % STEP 5
    % start recording eye position

    status=Eyelink('startrecording');
    if status~=0
        status
        error('startrecording error')
    end

    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    % mark zero-plot time in data file
    status=Eyelink('message','SYNCTIME');
    if status~=0
        status
        error('message error')
    end

    stopkey=KbName('space');
    fixkey=KbName('f');
    eye_used = -1; %just an initializer to remind us to ask tracker which eye is tracked

    % STEP 6 omitting gaze-dependent display

    recordingStartTime=GetSecs();

    %wait for stuff to show up
    nextDataType = 0;
    while nextDataType==0
        nextDataType = Eyelink('GetNextDataType'); %type of next queue item: SAMPLE_TYPE if sample, 0 if none, else event code
    end
    
    while 1 % loop till error or space bar is pressed

        % Check recording status, stop display if error
        err=Eyelink('checkrecording');
        if(err~=0)
            err
            error('checkrecording problem')
        end

        % check for presence of a new sample update
        status = Eyelink('newfloatsampleavailable');
        if  status> 0

            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample

                % get the sample in the form of an event structure

                items={};
                ndTypes=[];
                numItems=0;
                drained=false;
                while ~drained
                    nextDataType = Eyelink('GetNextDataType'); %type of next queue item: SAMPLE_TYPE if sample, 0 if none, else event code
                    if nextDataType==0
                        drained=true;
                    else
                        numItems=numItems+1;
                        if nextDataType==200
                            ndTypes(end+1)=nextDataType;
                            items{end+1} = Eyelink('GetFloatData', nextDataType);
                        else
                            ndTypes(end+1)=nextDataType
                            items{end+1} = Eyelink('GetFloatData', nextDataType);
                            items{end}
                            %pause
                        end
                    end
                end
                numItems
                ndTypes
                items

            else % if we don't, first find eye that's being tracked
                eye_used = Eyelink('eyeavailable'); % get eye that's tracked

                switch eye_used
                    case el.BINOCULAR
                        disp('tracker indicates binocular, we''ll use right')
                        eye_used = el.RIGHT_EYE;
                    case el.LEFT_EYE
                        disp('tracker indicates left eye')
                    case el.RIGHT_EYE
                        disp('tracker indicates right eye')
                    case -1
                        error('eyeavailable returned -1')
                    otherwise
                        eye_used
                        error('uninterpretable result from eyeavailable')
                end
            end
        else
            disp(sprintf('no sample available, status: %d',status))
        end % if sample available


        % check for keyboard press
        [keyIsDown,secs,keyCode] = KbCheck;
        % if spacebar was pressed stop display
        if keyCode(stopkey)
            break;
        end
        if keyCode(fixkey)
            initEyePos=[x y]
        end
    end % main loop

    % wait a while to record a few more samples
    WaitSecs(0.1);

    % STEP 7
    % finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    cleanup(oldPriority, edfFile);

catch
    ple
    cleanup(oldPriority, edfFile);
end

function cleanup(oldPriority, edfFile)
chk=Eyelink('checkrecording');
if chk~=0
    disp('problem: wasn''t recording but should have been')
end
Eyelink('stoprecording');
ShowCursor;
Priority(oldPriority);
status=Eyelink('closefile');
if status ~=0
    disp(sprintf('closefile error, status: %d',status))
end
status=Eyelink('ReceiveFile',edfFile,pwd,1);
if status~=0
    fprintf('problem: ReceiveFile status: %d\n', status);
end
if 2==exist(edfFile, 'file')
    fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
else
    disp('unknown where data file went')
end
Eyelink('shutdown');