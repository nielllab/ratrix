% edf 09.19.06: adapted from http://psychtoolbox.org/eyelinktoolbox/EyelinkToolbox.pdf
% and
% http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html
% (also available in local install at Psychtoolbox\ProgrammingTips.html)

% edf 10.09.06: adapted from eyelinkWinDemo.m to include sound and graphics
% for training fixation

% see also
% Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkDemos\Short demos\EyelinkExample.m

% note: el=EyelinkInitDefaults() sets el.keysCached to 0 on windows.
%       this causes EyelinkDoTrackerSetup() and EyelinkDoDriftCorrect() to
%       fail, because they call EyelinkGetKey(), which depends on cached key id's.
%       updating the eyelink toolbox to use the new KbName('UnifyKeyNames')
%       should fix this.
%   update: fixed by frans/mario

% THE FOLLOWING IS NO LONGER TRUE
% necessary for windows:
% copy EyelinkToolbox144\EyelinkToolbox\EyelinkBasic\eyelink.dll
% (from http://www.psychtoolbox.org/eyelinktoolbox/downloads/EyelinkToolbox144.zip)
% to Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkBasic\Eyelink.dll
% (note capitalizing Eyelink.dll is important)
% the rest of the eyelink toolbox is included in ptb 1.0.6 openGL beta
% UPDATE: fixed by frans/mario

% see ptb forum thread http://tech.groups.yahoo.com/group/psychtoolbox/message/4993

% note eyelink functions are documented in
% C:\Program Files\SR Research\EyeLink\Docs\*.pdf

function [out cache]=fixationSoundDemo
format long g
clear all
clear classes
close all
%clc

warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath('C:\eflister\Ratrix\Server\'));
addpath(genpath('C:\eflister\eyelink\getExtendedEyelinkData\'));
addpath(genpath('C:\pmeier\eyelink\'));
addpath(genpath('C:\pmeier\ratrixObjects\'));
rmpath C:\eflister\Ratrix\Server\classes\protocols\stimManagers\HandleParam
rmpath C:\eflister\Ratrix\Server\classes\protocols\stimManagers\HandleParam\CVS
warning('on','MATLAB:dispatcher:nameConflict')

KbName('UnifyKeyNames') %enables cross-platform key id's

%really old:
%libName='edfEyelink';
%libLoc=['C:\eflister\eyelink\edfEyelink\' libName];
%loadlibrary(libLoc,libLoc,'includepath','C:\Program Files\SR Research\EyeLink\Includes\eyelink\','mfilename', libName)
%loadlibrary(libLoc,libLoc,'mfilename', libName)

libName=[];
useLoadLibrary=0;
if useLoadLibrary
    libName='eyelinkExtraData';
    libLoc=['C:\eflister\eyelink\eyelinkExtraData\' libName];
    loadlibrary(libLoc,libLoc,'mfilename', libName)
    libfunctions(libName,'-full')
end

doDisplay=1; %use ptb
createFile=1; %record eyetracking data on the remote (eyetracking) computer and suck over the file when done
mouseInsteadOfGaze=0; %control gaze cursor using mouse instead of gaze (for testing, in case calibration isn't worked out yet)
textOut=1; %write reports from tracker to stdout

useEyelinkToolboxExtendedFunc=1; %1 for eyelink, 0 for edf's mex file

edfFile='demo.edf'; %name of remote data file to create
screenNum = 2; % use main screen

fixationX = .5; %normalized coords
fixationY = .5;
fixationSize=.001;
fixatedThreshold=.005;

timestep=0;
maxTimestep=10000;
%cache= something

initEyePos=[];
st=0;

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if (Eyelink('initialize') ~= 0)
    error('could not init connection to Eyelink')
    return;
end;

try
    % STEP 2
    % Open a graphics window on the main screen
    % using the PsychToolbox's SCREEN function.

    priority = MaxPriority('KbCheck');
    oldPriority = Priority();

    [scrWidth, scrHeight]=Screen('WindowSize', screenNum);
    white=255;
    if doDisplay
        AssertOpenGL
        window = Screen('OpenWindow', screenNum, 0, [], 32, 2);
        HideCursor;
        Priority(priority);
        ifi = Screen('GetFlipInterval', window, 200);
        Priority(oldPriority);

        white=WhiteIndex(window);
        black=BlackIndex(window);

        [scrWidth, scrHeight]=Screen('WindowSize', window);

        dotHeight = 7;
        dotWidth = 7;
    end

    %    xRange = [0 scrWidth]; %range of gaze estimates over display, which probably come in terms of the ptb stim display
    %    yRange = [0 scrHeight];

    %xRange = [-8000 0];
    %yRange = [-7000 10000];

    % STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    if doDisplay
        el=EyelinkInitDefaults(window);
    else
        el=EyelinkInitDefaults();
    end

    % make sure that we get gaze data from the Eyelink

    status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,HMARKER');
    if status~=0
        error('link_sample_data error, status: ',status)
    end

    status=Eyelink('command','inputword_is_window = ON');
    if status~=0
        error('inputword_is_window error, status: ',status)
    end

    % open file to record data to (just an example, not required)
    if createFile
        status=Eyelink('openfile',edfFile);
        if status~=0
            error('openfile error, status: ',status)
        end
    end

    % STEP 4
    if doDisplay && strcmp(el.computer,'MAC')==1 % OSX
        % Calibrate the eye tracker using the standard calibration routines
        EyelinkDoTrackerSetup(el); %fails on win, see header comments

        % do a final check of calibration using driftcorrection
        EyelinkDoDriftCorrect(el); %fails on win, see header comments
    else
        warning('cannot do calibration/drift correction unless on OSX with an open ptb window')
    end

    % STEP 5
    % start recording eye position

    status=Eyelink('startrecording');
    if status~=0
        error('startrecording error, status: ',status)
    end

    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    % mark zero-plot time in data file
    status=Eyelink('message','SYNCTIME');
    if status~=0
        error('message error, status: ',status)
    end

    stopkey=KbName('space');
    fixkey=KbName('f');
    eye_used = -1; %just an initializer to remind us to ask tracker which eye is tracked

    %precache sounds
    numsteps=12;
    fundamental=440;
    testMs=50;

    st=station(int8(1),int8([7,6,8]),int8([3,4,2]),1280,1024,'ptb','parallelPort','C:\eflister\Ratrix\Stations\station1\','B888',int8(2),int8(1),logical(1));
    soundMgr=loadSounds(numsteps,fundamental,testMs,st);
    soundNames=getSoundNames(soundMgr);

    % STEP 6
    % show gaze-dependent display

    Priority(priority);
    if doDisplay
        vbl = Screen('Flip', window); %Initially synchronize with retrace, take base time in vbl
    end

    recordingStartTime=GetSecs();

    status=0;
    while status<=0
        status = Eyelink('newfloatsampleavailable');
    end
    evt = Eyelink('newestfloatsample'); %temp: throw this away

    while 1 % loop till error or space bar is pressed
        timestep=timestep+1;
        % Check recording status, stop display if error
        err=Eyelink('checkrecording');
        if(err~=0)
            error('checkrecording problem, status: ',err)
            break;
        end

        % check for presence of a new sample update
        status = Eyelink('newfloatsampleavailable');
        if  status> 0

            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample

                % get the sample in the form of an event structure

                if useEyelinkToolboxExtendedFunc
                    [evt, raw] = Eyelink('NewestFloatSampleRaw');

                    x = evt.px(eye_used+1); % +1 as we're accessing MATLAB array
                    y = evt.py(eye_used+1);
                    raw_crx = raw.raw_cr(1);
                    raw_cry = raw.raw_cr(2);
                    raw_px = raw.raw_pupil(1);
                    raw_py = raw.raw_pupil(2);
                    goodPupil = evt.pa(eye_used+1)>0;

                else
                    % use edf's mex file
                    if eye_used==1 || eye_used==2
                        evt=getExtendedEyelinkData(int8(eye_used-1));
                        raw=0;

                        x = evt.px
                        y = evt.py
                        raw_crx = evt.raw_cr_x;
                        raw_cry = evt.raw_cr_y;
                        raw_px = evt.raw_pupil_x;
                        raw_py = evt.raw_pupil_y;
                        goodPupil = evt.pa > 0;
                    elseif eye_used ~= -1
                        eye_used
                        error('eye_used must be 1 or 2, no binocular!')
                    end
                end

                if textOut
                    evt
                    raw
                end

                samp.evt=evt;
                samp.raw=raw;
                samp.frameTime=GetSecs();
                samp.g_est_x=el.MISSING_DATA;
                samp.g_est_y=el.MISSING_DATA;
                out(timestep)=samp;
                

                %                 status=Eyelink('newfloatsampleavailable');
                %                 if status > 0
                %                     crx=calllib(libName,'GetCRX',eye_used);
                %                     if crx ~= el.MISSING_DATA
                %                         disp(crx)
                %                     else
                %                         disp([num2str(crx) ' is MISSING_DATA ' num2str(el.MISSING_DATA)])
                %                     end
                %                     %calllib(libName,'GetExtraData',eye_used) %seg fault!
                %                 else
                %                     disp('no new samp available')
                %                 end

                if timestep<=maxTimestep

                elseif timestep==maxTimestep+1
                    disp(sprintf('filled cache, lasted %g secs\n',GetSecs()-recordingStartTime))
                end

                % do we have valid data and is the pupil visible?
                if (x~=el.MISSING_DATA & y~=el.MISSING_DATA & goodPupil) || mouseInsteadOfGaze
                    
                    [g_est_x g_est_y] =getGazeEstimate([evt.px evt.py],[raw_crx raw_cry],1);
                    out(timestep).g_est_x=g_est_x;
                    out(timestep).g_est_y=g_est_y;

                    
                    if mouseInsteadOfGaze
                        if doDisplay
                            [x,y,buttons] = GetMouse(window);
                        else
                            [x,y,buttons] = GetMouse(screenNum);
                        end
                    else
                        %x=x-raw_crx;
                        %y=y-raw_cry; 
                        %x=scrWidth*((x-min(xRange))/range(xRange));
                        %y=scrHeight*((y-min(yRange))/range(yRange));
                        
                        x=g_est_x;
                        y=g_est_y;
                        
                    end

                    if isempty(initEyePos)
                        initEyePos=[x y];
                    end

                    x=x-initEyePos(1) + scrWidth/2;
                    y=y-initEyePos(2) + scrHeight/2;


                    % if data is valid, draw a circle on the screen at current gaze position
                    % using PsychToolbox's SCREEN function

                    minAmt=.5;
                    fixLoc=[scrWidth scrHeight].*[fixationX fixationY];
                    maxNorm=max([norm(fixLoc-[0 scrHeight]) norm(fixLoc-[scrWidth 0]) norm(fixLoc-[0 0]) norm(fixLoc-[scrWidth scrHeight])]); %theorem: the farthest possible point is always a corner
                    %amt = whiteIndex(window)*max(1+ norm([x y]-fixLoc)*(minAmt-1)/maxNorm, minAmt);
                    %[maxNorm norm([x y]-fixLoc) ((norm([x y]-fixLoc)*(1-minAmt)/maxNorm)+minAmt)]
                    preAmt = norm([x y]-fixLoc)/maxNorm;
                    amt = ((1-minAmt)*preAmt)+minAmt;
                    fixColor = white*amt;
                    scaleFact=200;
                    nonlin=3;

                    if doDisplay

                        fixRect = [fixationX*scrWidth-scaleFact*(amt^nonlin)*fixationSize*scrWidth/2, ...
                            fixationY*scrHeight-scaleFact*(amt^nonlin)*fixationSize*scrHeight/2, ...
                            fixationX*scrWidth+scaleFact*(amt^nonlin)*fixationSize*scrWidth/2, ...
                            fixationY*scrHeight+scaleFact*(amt^nonlin)*fixationSize*scrHeight/2];

                        gazeRect=[ x-dotWidth/2 y-dotHeight/2 x+dotWidth/2 y+dotHeight/2];
                        penSize=6;

                        Screen('FillOval', window, [0 fixColor fixColor], fixRect);
                        Screen('FrameOval', window, white, gazeRect,penSize,penSize);

                    end
                else
                    % if data is invalid (e.g. during a blink), clear display
                    if doDisplay
                        Screen('FillRect', window,black);
                    end

                    disp('blink! (x or y is missing or pupil size<=0)')
                end

                if doDisplay
                    Screen('DrawingFinished', window);
                    vbl = Screen('Flip', window);%, vbl + 0.5*ifi);
                end

                if (x~=el.MISSING_DATA & y~=el.MISSING_DATA & goodPupil) || mouseInsteadOfGaze
                    if fixatedThreshold < preAmt
                        soundNum=max([1 min([ceil(preAmt*length(soundNames)) length(soundNames)])]);
                        soundMgr=playLoop(soundMgr,soundNames{soundNum},st);
                        setValves(st,[0 0 0]);
                    else
                        soundMgr=playLoop(soundMgr,'',st);
                        setValves(st,[0 1 0]);
                    end
                end

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
                        error('uninterpretable result from eyeavailable: ',eye_used)
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
            %             if mouseInsteadOfGaze
            %                 if doDisplay
            %                     [x,y,buttons] = GetMouse(window);
            %                 else
            %                     [x,y,buttons] = GetMouse(screenNum);
            %                 end
            %             else
            %                 x = evt.px(eye_used+1); % +1 as we're accessing MATLAB array
            %                 y = evt.py(eye_used+1);
            %                 if (x~=el.MISSING_DATA & y~=el.MISSING_DATA & evt.pa(eye_used+1)>0)
            %                     x=scrWidth*((x-min(xRange))/range(xRange));
            %                     y=scrHeight*((y-min(yRange))/range(yRange));
            %                 else
            %                     disp('can''t recenter now cuz blink or missing data')
            %                 end
            %             end
            initEyePos=[x y]
        end
    end % main loop

    % wait a while to record a few more samples
    WaitSecs(0.1);

    % STEP 7
    % finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    cleanup(createFile, oldPriority, edfFile,st,libName);

    %    arrayfun(@(x)( x.px(1) ),s)

    if maxTimestep>0
        cache.frameTime = [out.frameTime];
        cache.g_est_x = [out.g_est_x];
        cache.g_est_y = [out.g_est_y];

        if useEyelinkToolboxExtendedFunc

            evts=[out.evt];
            cache.time      =   arrayfun(@(x)( x.time           ), evts );
            cache.type      =   arrayfun(@(x)( x.type           ), evts );
            cache.flags     =   arrayfun(@(x)( x.flags          ), evts );
            cache.px        =   arrayfun(@(x)( x.px(eye_used)   ), evts );
            cache.py        =   arrayfun(@(x)( x.py(eye_used)   ), evts );
            cache.hx        =   arrayfun(@(x)( x.hx(eye_used)   ), evts );
            cache.hy        =   arrayfun(@(x)( x.hy(eye_used)   ), evts );
            cache.pa        =   arrayfun(@(x)( x.pa(eye_used)   ), evts );
            cache.gx        =   arrayfun(@(x)( x.gx(eye_used)   ), evts );
            cache.gy        =   arrayfun(@(x)( x.gy(eye_used)   ), evts );
            cache.rx        =   arrayfun(@(x)( x.rx             ), evts );
            cache.ry        =   arrayfun(@(x)( x.ry             ), evts );
            cache.status    =   arrayfun(@(x)( x.status         ), evts );
            cache.input     =   arrayfun(@(x)( x.input          ), evts );
            cache.buttons   =   arrayfun(@(x)( x.buttons        ), evts );
            cache.htype     =   arrayfun(@(x)( x.htype          ), evts );

            raws=[out.raw];
            cache.raw_pupil_x       =   arrayfun(@(x)( x.raw_pupil(1)       ), raws );
            cache.raw_pupil_y       =   arrayfun(@(x)( x.raw_pupil(2)       ), raws );
            cache.raw_cr_x          =   arrayfun(@(x)( x.raw_cr(1)          ), raws );
            cache.raw_cr_y          =   arrayfun(@(x)( x.raw_cr(2)          ), raws );
            cache.raw_pupil_area    =   arrayfun(@(x)( x.pupil_area         ), raws );
            cache.raw_cr_area       =   arrayfun(@(x)( x.cr_area            ), raws );
            cache.pupil_dimension_w =   arrayfun(@(x)( x.pupil_dimension(1)	), raws );
            cache.pupil_dimension_h	=   arrayfun(@(x)( x.pupil_dimension(2)	), raws );
            cache.cr_dimension_w    =   arrayfun(@(x)( x.cr_dimension(1)	), raws );
            cache.cr_dimension_h	=   arrayfun(@(x)( x.cr_dimension(2)	), raws );
            cache.window_position_x	=   arrayfun(@(x)( x.window_position(1)	), raws );
            cache.window_position_y	=   arrayfun(@(x)( x.window_position(2)	), raws );
            cache.pupil_cr_x        =   arrayfun(@(x)( x.pupil_cr(1)        ), raws );
            cache.pupil_cr_y        =   arrayfun(@(x)( x.pupil_cr(2)        ), raws );
                
        else
            evts=[out.evt];
            cache.time      =   arrayfun(@(x)( x.time           ), evts );
            cache.type      =   arrayfun(@(x)( x.type           ), evts );
            cache.flags     =   arrayfun(@(x)( x.flags          ), evts );
            cache.px        =   arrayfun(@(x)( x.px             ), evts );
            cache.py        =   arrayfun(@(x)( x.py             ), evts );
            cache.hx        =   arrayfun(@(x)( x.hx             ), evts );
            cache.hy        =   arrayfun(@(x)( x.hy             ), evts );
            cache.pa        =   arrayfun(@(x)( x.pa             ), evts );
            cache.gx        =   arrayfun(@(x)( x.gx             ), evts );
            cache.gy        =   arrayfun(@(x)( x.gy             ), evts );
            cache.rx        =   arrayfun(@(x)( x.rx             ), evts );
            cache.ry        =   arrayfun(@(x)( x.ry             ), evts );
            cache.status    =   arrayfun(@(x)( x.status         ), evts );
            cache.input     =   arrayfun(@(x)( x.input          ), evts );
            cache.buttons   =   arrayfun(@(x)( x.buttons        ), evts );
            cache.htype     =   arrayfun(@(x)( x.htype          ), evts );

            cache.raw_pupil_x       =   arrayfun(@(x)( x.raw_pupil_x        ), evts );
            cache.raw_pupil_y       =   arrayfun(@(x)( x.raw_pupil_y        ), evts );
            cache.raw_cr_x          =   arrayfun(@(x)( x.raw_cr_x           ), evts );
            cache.raw_cr_y          =   arrayfun(@(x)( x.raw_cr_y           ), evts );
            cache.raw_pupil_area    =   arrayfun(@(x)( x.pupil_area         ), evts );
            cache.raw_cr_area       =   arrayfun(@(x)( x.cr_area            ), evts );
            cache.pupil_dimension_w =   arrayfun(@(x)( x.pupil_dimension_w	), evts );
            cache.pupil_dimension_h	=   arrayfun(@(x)( x.pupil_dimension_h	), evts );
            cache.cr_dimension_w    =   arrayfun(@(x)( x.cr_dimension_w     ), evts );
            cache.cr_dimension_h	=   arrayfun(@(x)( x.cr_dimension_h     ), evts );
            cache.window_position_x	=   arrayfun(@(x)( x.window_position_x	), evts );
            cache.window_position_y	=   arrayfun(@(x)( x.window_position_y	), evts );
            cache.pupil_cr_x        =   arrayfun(@(x)( x.pupil_cr_x         ), evts );
            cache.pupil_cr_y        =   arrayfun(@(x)( x.pupil_cr_y         ), evts );
        end


        subplot(2,1,1)

        g_est_x=cache.px-cache.raw_cr_x;
        g_est_y=cache.py-cache.raw_cr_y;

        g_ext_x(cache.px==el.MISSING_DATA | cache.raw_cr_x==el.MISSING_DATA)=el.MISSING_DATA;
        g_ext_y(cache.py==el.MISSING_DATA | cache.raw_cr_y==el.MISSING_DATA)=el.MISSING_DATA;

        plot([normalize(g_est_x,el);...
            normalize(g_est_y,el)]');
        legend(['gaze est x ' strRange(g_est_x,el)],['gaze est y ' strRange(g_est_y,el)]);
        subplot(2,1,2)
        scatter(g_est_x,g_est_y)
    end
catch

    ers=lasterror
    ers.message
    ers.stack.file
    ers.stack.name
    ers.stack.line
    cleanup(createFile, oldPriority, edfFile,st,libName);
    rethrow(lasterror)
end

function str=strRange(v,el)
v(v==el.MISSING_DATA)=mean(v);
if min(v)==max(v)
    str = ['(' num2str(v(1)) ')'];
else
    str = ['(' num2str(min(v)) ' - ' num2str(max(v)) ')'];
end

function n=normalize(v,el)
v(v==el.MISSING_DATA)=mean(v);
if max(v)~=min(v)
    n=v-min(v);
    n=n/max(n);
else
    n=0*v;
end

function cleanup(createFile, oldPriority, edfFile,station,libName)
if isobject(station)
    setValves(station,[0 0 0]);
end
chk=Eyelink('checkrecording');
if chk~=0
    disp('problem: wasn''t recording but should have been')
end
Eyelink('stoprecording');
Screen('CloseAll');
ShowCursor;
Priority(oldPriority);
if createFile
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
end
Eyelink('shutdown');
if ~isempty(libName)
    unloadlibrary(libName)
end

function soundMgr=loadSounds(numsteps,fundamental,testMs,station)

freqs=fundamental*2.^([0:numsteps]/numsteps);

for i=1:length(freqs)
    sndName=['fixTone' num2str(i)];
    sndClips{i}=soundClip(sndName,'allOctaves',freqs(i),20000);
end

soundMgr =soundManager(sndClips);

[soundMgr garbage]=cacheSounds(soundMgr);
soundNames=getSoundNames(soundMgr);

for i=1:length(soundNames)
    soundMgr=playSound(soundMgr,soundNames{i},testMs/1000,station);
    WaitSecs(testMs/1000);
end