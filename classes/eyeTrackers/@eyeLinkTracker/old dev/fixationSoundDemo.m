% eyetracking demo that plays a continuous tone whose pitch is dependent on distance between gaze and fixation point
% mouse can be used to simulate gaze
% hit f to indicate fixations, space to quit

% edf 09.19.06: adapted from
% http://psychtoolbox.org/eyelinktoolbox/EyelinkToolbox.pdf
% and
% http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html
% (also available in local install at Psychtoolbox\ProgrammingTips.html)

% edf 10.09.06: adapted from eyelinkWinDemo.m to include sound and graphics
% for training fixation

% edf 10.31.09: cleaning up for inclusion in ptb demos

% see also
% Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkDemos\Short demos\EyelinkExample.m

% note eyelink functions are documented in
% C:\Program Files\SR Research\EyeLink\Docs\*.pdf

function [out cache]=fixationSoundDemo
format long g
clear all
clear classes
close all
clc
clear mex

mouseInsteadOfGaze=0; %control gaze cursor using mouse instead of gaze (for testing, in case calibration isn't worked out yet)
useRaw=0; %use raw values from tracker

KbName('UnifyKeyNames') %enables cross-platform key id's
ListenChar(2)

createFile=1; %record eyetracking data on the remote (eyetracking) computer and suck over the file when done
edfFile='demo.edf'; %name of remote data file to create

screenNum = max(Screen('Screens')); % use main screen

fixation=[.5 .5]; %normalized coords
fixationSize=.001;
fixatedThreshold=.005;

timestep=0;
maxTimestep=10000;

initEyePos=[];
fixing=false;

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if (Eyelink('initialize','') ~= 0)
    error('could not init connection to Eyelink')
end;

try
    % STEP 2
    % Open a graphics window on the main screen
    % using the PsychToolbox's SCREEN function.

    AssertOpenGL
    oldPriority = Priority(MaxPriority('KbCheck','GetSecs'));

    window = Screen('OpenWindow', screenNum, 0, [], 32, 2);
    HideCursor;
    ifi = Screen('GetFlipInterval', window, 200);

    white=WhiteIndex(window);
    black=BlackIndex(window);

    [scrWidth, scrHeight]=Screen('WindowSize', window);
    fixLoc=[scrWidth scrHeight].*fixation;
    maxNorm=max([norm(fixLoc-[0 scrHeight]) norm(fixLoc-[scrWidth 0]) norm(fixLoc-[0 0]) norm(fixLoc-[scrWidth scrHeight])]); %farthest possible point is always a corner

    %some parameters determining the nonlinear relationship between gaze error and fixation target size/color and sound pitch
    minAmt=.5;
    scaleFact=200;
    nonlin=3;

    dotHeight = 7;
    dotWidth = 7;
    penSize=6;

    numsteps=12;
    fundamental=55;
    testMs=50;

    soundMgr=loadSounds(numsteps,fundamental,testMs);

    % STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).

    el=EyelinkInitDefaults(window);

    if useRaw
        % make sure that we get raw data fields from the Eyelink

        status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,HMARKER');
        if status~=0
            status %#ok<NOPRT>
            error('link_sample_data error')
        end

        status=Eyelink('command','inputword_is_window = ON');
        if status~=0
            status %#ok<NOPRT>
            error('inputword_is_window error')
        end
    else
        status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT');
        if status~=0
            status %#ok<NOPRT>
            error('link_sample_data error')
        end
    end

    % open file to record data to (just an example, not required)
    if createFile
        status=Eyelink('openfile',edfFile);
        if status~=0
            status %#ok<NOPRT>
            error('openfile error')
        end
    end

    % STEP 4
    if strcmp(el.computer,'MAC')==1 %#ok<AND2> % OSX
        % Calibrate the eye tracker using the standard calibration routines
        EyelinkDoTrackerSetup(el); %fails on win, see header comments

        % do a final check of calibration using driftcorrection
        EyelinkDoDriftCorrect(el); %fails on win, see header comments
    else
        warning('cannot do calibration/drift correction unless on OSX with an open ptb window') %#ok<WNTAG>
    end

    % STEP 5
    % start recording eye position

    status=Eyelink('startrecording');
    if status~=0
        status %#ok<NOPRT>
        error('startrecording error')
    end

    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    % mark zero-plot time in data file
    status=Eyelink('message','SYNCTIME');
    if status~=0
        status %#ok<NOPRT>
        error('message error')
    end

    stopkey=KbName('space');
    fixkey=KbName('f');
    eye_used = -1; %just an initializer to remind us to ask tracker which eye is tracked

    % STEP 6
    % show gaze-dependent display

    vbl = Screen('Flip', window); %Initially synchronize with retrace, take base time in vbl

    recordingStartTime=GetSecs();

    status=0;
    while status<=0
        status = Eyelink('newfloatsampleavailable');
    end
    evt = Eyelink('newestfloatsample'); %#ok<NASGU> %temp: throw this away

    while 1 % loop till error or space bar is pressed

        % Check recording status, stop display if error
        err=Eyelink('checkrecording');
        if(err~=0)
            err %#ok<NOPRT>
            error('checkrecording problem')
        end

        [keyIsDown,secs,keyCode] = KbCheck;
        % if spacebar was pressed stop display
        if keyCode(stopkey)
            break;
        end

        % check for presence of a new sample update
        status = Eyelink('newfloatsampleavailable');
        if  status> 0

            if eye_used ~= -1 % do we know which eye to use yet?
                % if we do, get current gaze position from sample

                % get the sample in the form of a sample structure
                if useRaw
                    [sample, raw] = Eyelink('NewestFloatSampleRaw',eye_used);
                    raw_crx = raw.raw_cr(1);
                    raw_cry = raw.raw_cr(2);
                    raw_px = raw.raw_pupil(1);
                    raw_py = raw.raw_pupil(2);

                    missing=any([raw_crx raw_cry raw_px raw_py]==el.MISSING_DATA);

                    samp.raw=raw;
                else
                    [sample] = Eyelink('NewestFloatSample');
                    missing=any([sample.gx(eye_used+1) sample.gy(eye_used+1)]==el.MISSING_DATA); % +1 as we're accessing MATLAB array
                end

                goodPupil = sample.pa(eye_used+1)>0;

                samp.sample=sample;
                samp.frameTime=GetSecs();
                samp.g_est=el.MISSING_DATA*ones(1,2);

                % do we have valid data and is the pupil visible?
                if (~missing & goodPupil) | mouseInsteadOfGaze %#ok<OR2,AND2>

                    if mouseInsteadOfGaze
                        [samp.g_est(1),samp.g_est(2),buttons] = GetMouse(window); %#ok<NASGU>
                    elseif useRaw
                        samp.g_est =getGazeEstimate([raw_px raw_py],[raw_crx raw_cry]);

                        %x=x-raw_crx;
                        %y=y-raw_cry;
                        %x=scrWidth*((x-min(xRange))/range(xRange));
                        %y=scrHeight*((y-min(yRange))/range(yRange));

                    else
                        [samp.g_est(1) samp.g_est(2)] = deal(sample.gx(eye_used+1),sample.gy(eye_used+1));
                    end

                    if isempty(initEyePos) | (keyCode(fixkey) & ~fixing) %#ok<AND2,OR2>
                        initEyePos=samp.g_est;
                        fixing=true;
                    end
                    if fixing & ~keyCode(fixkey) %#ok<AND2>
                        fixing=false;
                    end

                    scrLoc=(samp.g_est-initEyePos)+fixLoc;
                    samp.g_est=scrLoc;

                    % if data is valid, draw a circle on the screen at current gaze position
                    % and a fixation target whos size and color depends nonlinearly on gaze error
                    % using PsychToolbox's SCREEN function

                    preAmt = norm(scrLoc-fixLoc)/maxNorm;
                    amt = ((1-minAmt)*preAmt)+minAmt;
                    fixColor = round(white*preAmt);

                    fixRect = [...
                        fixation(1)*scrWidth- scaleFact*(amt^nonlin)*fixationSize*scrWidth /2, ...
                        fixation(2)*scrHeight-scaleFact*(amt^nonlin)*fixationSize*scrHeight/2, ...
                        fixation(1)*scrWidth+ scaleFact*(amt^nonlin)*fixationSize*scrWidth /2, ...
                        fixation(2)*scrHeight+scaleFact*(amt^nonlin)*fixationSize*scrHeight/2];

                    gazeRect=[...
                        scrLoc(1)-dotWidth /2, ...
                        scrLoc(2)-dotHeight/2, ...
                        scrLoc(1)+dotWidth /2, ...
                        scrLoc(2)+dotHeight/2];

                    Screen('FillOval', window, [fixColor white-fixColor 0], fixRect);
                    Screen('FrameOval', window, white, gazeRect,penSize,penSize);

                    if fixatedThreshold < preAmt
                        soundNum=max([1 min([ceil(preAmt*numsteps) numsteps])]);
                        soundMgr=playSound(soundMgr,soundNum);
                    else
                        soundMgr=playSound(soundMgr,0);
                    end

                else
                    % if data is invalid (e.g. during a blink), clear display
                    Screen('FillRect', window,black);

                    disp('blink! (pupil or cr are missing or pupil size<=0)')
                end

                Screen('DrawingFinished', window);

                timestep=timestep+1;
                if timestep<=maxTimestep
                    out(timestep)=samp; %should preallocate these
                elseif timestep==maxTimestep+1
                    disp(sprintf('filled cache, lasted %g secs\n',GetSecs()-recordingStartTime))
                end

                when=vbl + 0.5*ifi;
                preFlipTime=GetSecs;

                [vbl junk junk missed] = Screen('Flip', window, when);

                if missed>0
                    fprintf('missed a frame: called flip with %g ms headroom\n',1000*(when-preFlipTime))
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
                        eye_used %#ok<NOPRT>
                        error('uninterpretable result from eyeavailable')
                end
            end
        else
            disp(sprintf('no sample available, status: %d',status))
        end % if sample available
    end % main loop

    % wait a while to record a few more samples
    WaitSecs(0.1);

    % STEP 7
    % finish up: stop recording eye-movements,
    % close graphics window, close data file and shut down tracker
    cleanup(createFile, oldPriority, edfFile);

    if maxTimestep>0
        cache.frameTime = [out.frameTime];

        samples=[out.sample];
        cache.time      =   arrayfun(@(x)( x.time           ), samples );

        if useRaw
            raws=[out.raw];
            cache.raw_pupil_x       =   arrayfun(@(x)( x.raw_pupil(1)       ), raws );
            cache.raw_pupil_y       =   arrayfun(@(x)( x.raw_pupil(2)       ), raws );
            cache.raw_cr_x          =   arrayfun(@(x)( x.raw_cr(1)          ), raws );
            cache.raw_cr_y          =   arrayfun(@(x)( x.raw_cr(2)          ), raws );

            g_est_x=cache.raw_cr_x-cache.raw_pupil_x;
            g_est_y=cache.raw_cr_y-cache.raw_pupil_y;

            g_est_x(cache.raw_pupil_x==el.MISSING_DATA | cache.raw_cr_x==el.MISSING_DATA)=el.MISSING_DATA;
            g_est_y(cache.raw_pupil_y==el.MISSING_DATA | cache.raw_cr_y==el.MISSING_DATA)=el.MISSING_DATA;
        else
            g_est_x = arrayfun(@(x)(x.gx(eye_used+1)),samples);
            g_est_y = arrayfun(@(x)(x.gy(eye_used+1)),samples);
        end

        g_est_x(g_est_x==el.MISSING_DATA)=nan;
        g_est_y(g_est_y==el.MISSING_DATA)=nan;

        subplot(4,1,1)
        plot(cache.time,[g_est_x;g_est_y]');
        legend(['gaze est x ' strRange(g_est_x)],['gaze est y ' strRange(g_est_y)]);
        title('gaze estimates from tracker samples (do not include fixation corrections)')

        subplot(4,1,2)
        scatter(g_est_x,g_est_y,3,cache.time)
        axis ij
        axis equal


        cache.g_est=cell2mat({out.g_est}');
        cache.g_est(cache.g_est==el.MISSING_DATA)=nan;

        subplot(4,1,3)
        plot(cache.g_est)
        title('gaze estimates calculated during loop (do include fixation corrections)')

        subplot(4,1,4)
        scatter(cache.g_est(:,1),cache.g_est(:,2),3,cache.time)
        axis ij
        axis equal
    end
catch ex
    getReport(ex)
    cleanup(createFile, oldPriority, edfFile);
end
end

function str=strRange(v)
if min(v)==max(v)
    str = ['(' num2str(v(1)) ')'];
else
    str = ['(' num2str(min(v)) ' - ' num2str(max(v)) ')'];
end
end

function out =getGazeEstimate(p,cr)
%a crude estimate is just cr-p
out=[cr(:,1)-p(:,1) cr(:,2)-p(:,2)];
end

function cleanup(createFile, oldPriority, edfFile)
FlushEvents('mouseUp','mouseDown','keyDown','autoKey','update');
ListenChar(0)
PsychPortAudio('Close');
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
end

function sndMgr=loadSounds(numsteps,fundamental,testMs)

InitializePsychSound(1);

freqs=fundamental*2.^((0:numsteps-1)/numsteps);

sndMgr.sampleRate = 44100;

latclass=1; %4 is max, higher means less latency + stricter checks.  lowering may reduce system load if having frame drops.  1 seems ok on my systems.
if IsWin
    buffsize=4096; %max is 4096 i think.  the larger this is, the larger the audio latency, but if too small, sound is distorted, and system load increases (could cause frame drops).  1250 is good on my systems.
else
    buffsize=[];
end

sndMgr.ppa = PsychPortAudio('Open',[],[],latclass,sndMgr.sampleRate,2,buffsize);

s=PsychPortAudio('GetStatus',sndMgr.ppa);
s=s.SampleRate;

if s~=sndMgr.sampleRate
    sndMgr.sampleRate %#ok<NOPRT>
    s %#ok<NOPRT>
    error('didn''t get requested sample rate')
end

buff=[];
sndMgr.starts=[];

for i=1:length(freqs)
    clip=soundClip(freqs(i),sndMgr.sampleRate); %#ok<AGROW>

    if size(clip,1)>2
        clip=clip'; %psychportaudio requires channels to be rows
    end
    switch size(clip,1)
        case 1
            clip(2,:) = clip(1,:);
        case 2
            %pass
        otherwise
            error('max 2 channels')
    end
    sndMgr.starts(end+1)=size(buff,2)+1; %#ok<AGROW>
    buff=[buff clip]; %#ok<AGROW>
end
sndMgr.starts(end+1)=size(buff,2); %#ok<NASGU>
sndMgr.playing.num=0;
sndMgr.playing.len=0;

PsychPortAudio('FillBuffer', sndMgr.ppa, buff);
PsychPortAudio('RunMode',sndMgr.ppa, 1);
PsychPortAudio('Verbosity' ,1); %otherwise it types crap out when we start sounds right after calling stop, must think it's still running even after .Active is false

for i=1:length(freqs)
    sndMgr=playSound(sndMgr,i,testMs/1000);
    WaitSecs(testMs/1000);
end
end

function sndMgr=playSound(sndMgr,num,len)
if ~exist('len','var')
    len=[];
end
if isempty(len)
    len=0;
end

if num>0 & num<length(sndMgr.starts) %#ok<AND2>
    if num==sndMgr.playing.num
        if len==0 & sndMgr.playing.len==0 %#ok<AND2>
            %pass
        else
            PsychPortAudio('Start', sndMgr.ppa, len); %is this ok without stopping first?
            sndMgr.playing.len=len;
        end
    else
        if 0~=sndMgr.playing.num
            PsychPortAudio('Stop', sndMgr.ppa,2,0);
        end
        PsychPortAudio('SetLoop', sndMgr.ppa,sndMgr.starts(num),sndMgr.starts(num+1)-1);
        if len>0
            len=len*sndMgr.sampleRate/(sndMgr.starts(num+1)-sndMgr.starts(num));
        elseif len==0
            %pass
        else
            error('len must be >=0')
        end
        PsychPortAudio('Start', sndMgr.ppa, len);
        sndMgr.playing.len=len;
        sndMgr.playing.num=num;
    end
elseif num==0
    PsychPortAudio('Stop', sndMgr.ppa,2,0);
    sndMgr.playing.len=0;
    sndMgr.playing.num=0;
else
    error('num must be 0-%d',length(sndMgr.starts)-1)
end
end

function clip=soundClip(fundamental,sampleRate)

msLength = 500;
numSamples = sampleRate*msLength/1000;
amplitude = 1.0;

if fundamental<=0 %#ok<OR2>
    error('pass in fundamental > 0')
end

clip = sin(fundamental*2*pi*(0:numSamples)/numSamples)>0;
clip=clip-mean(clip);
clip=clip/max(abs(clip))*amplitude;
end