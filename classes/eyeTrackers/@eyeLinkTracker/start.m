function et=start(et,trialNumber)
%starts tracking, starts recording an eyelink data file
%trialNumber is just used to set the fileName for the dataFile
%
%History
%edf 09.19.06 reinagel lab developed first code, using resources:
%   http://psychtoolbox.org/eyelinktoolbox/EyelinkToolbox.pdf
%   http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html
%    (also available in local install at Psychtoolbox\ProgrammingTips.html)
%   Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkDemos\Short demos\EyelinkExample.m
%   discussion thread:  http://tech.groups.yahoo.com/group/psychtoolbox/message/4993
%   old function examples not in ratrix:  fixationSoundDemo.m, eyeTrackerExperiment.m
%   check eyeLink website or CD for: Manuals/EyeLink API Specification.pdf

%pmm 06.28.08 added to ratrix
%  using the code in Pyschtoolbox... for more: "help eyelink"
%  for hardware information http://www.eyelinkinfo.com/index.php

if ~exist('createFile','var') || isempty(createFile)
    createFile=true;
end

% MAYBE ADD ON!
%     % make sure that we get gaze data from the Eyelink
%     status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,HMARKER');
%     if status~=0
%         error('link_sample_data error, status: ',status)
%     end
% 
%     status=Eyelink('command','inputword_is_window = ON');
%     if status~=0
%         error('inputword_is_window error, status: ',status)
%     end
%     
    
    
%OPEN FILE
if createFile
    %toDo replace this to right place, passed in:
    fileName=sprintf('eyeSessionData_%d_%s.edf',trialNumber,datestr(now,30)); %can't be long!
    et=setSessionFileName(et,fileName);
    
    edfFileName=sprintf('lastSess.edf',trialNumber)% must be short name;
    %fileName='test.edf'
    errCode=Eyelink('OpenFile',edfFileName);
    if ~errCode==0
        errCode=errCode
        error('eyeLink couldn''t open file')
    end
end

%START
% file_samples=
% file_events=
% link_samples
% link_events
% [startrecording_error =] Eyelink('StartRecording' [,file_samples, file_events, link_samples, link_events] )
startrecording_error = Eyelink('StartRecording');
if startrecording_error~=0
    startrecording_error=startrecording_error
    error(sprintf('problem starting eyelink recording: %s',startrecording_error))
end

% mark zero-plot time in data file
status=Eyelink('message','SYNCTIME');
if status~=0
    error('message error, status: ',status)
end

%% figure out which eye channel the software is using
%this used to be in initilize.m but failed with -1 because...we have to
%start recording before we can call this function 

    et.eyeUsed = Eyelink('EyeAvailable'); % get eye that's tracked
    
    if isempty(et.eyeUsed)
        error('gotta have an eye')
    end
    
    el=getConstants(et);
    if ~ismember(et.eyeUsed,[el.LEFT_EYE el.RIGHT_EYE])
        error(sprintf('must be left or right, which is 0 or 1: but rather was found to be %d',et.eyeUsed))
    end
    %tracker will always indicate left eye in software, but we always use
    %one camera pointed to the right eye (b/c we record from the left LGN)
    %-pmm 080628
%     switch eye_used
%         case el.BINOCULAR
%             disp('tracker indicates binocular, we''ll use right')
%             eye_used = el.RIGHT_EYE
%         case el.LEFT_EYE
%             disp('tracker indicates left eye')
%         case el.RIGHT_EYE
%             disp('tracker indicates right eye')
%         case -1
%             error('eyeavailable returned -1')
%         otherwise
%             error('uninterpretable result from eyeavailable: ',eye_used)
%     end

%%

% record a few samples before we actually start displaying
%WaitSecs(0.1);  %removed -- why bother waiting?

et=setIsTracking(et,true)