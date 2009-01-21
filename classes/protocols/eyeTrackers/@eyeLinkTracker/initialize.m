function et=initialize(et,subjectID,window)
% this should initialize eyelink and set the data path.  If you can't
%initialize, maybe you have not installed  the eyeLink software
% developers kit.  Here is how to set things up the first time:
%
% download and install lastest sdk from here:
%    https://www.sr-support.com/forums/showthread.php?t=6
%(user: eflister, password: password) %---% to sign up for your own user account at sr research takes about 24 hours
% i installed 1.7.277 on the righthand computer in the small rig room.
%    https://www.sr-support.com/forums/showthread.php?t=172
% has the latest version of the installation guide.  i used 1.4.0.  it says what to do with the ip address.  section 9.1.5 says:
% Select the Use the following IP address radio button. Enter the IP
% address of 100.1.1.2. The last digit of the IP address can increase for other computers on the EyeLink network. Enter the subnet mask of 255.255.255.0. Leave the default gateway and other setting blank.
% psychtoolbox comes with everything else you need.
% fixationSoundDemo demonstrates how to collect the full raw samples.
% loadlibrary and my eyelinkExtraData/getExtendedEyelinkData are not needed, franz's stuff does everything.  my stuff was just an alternative before we knew franz would do it for us.
% works with 2007b at least.  but we haven't verified that franz's method
% for extracting the extended data wasn't broken when sol added the double CR data into the records.
% let's email sol and ask him if the stuff he and suganthan put for us in 1.5.1.104 and 1.5.1.272 all made it into the latest 1.7.277 that we download from https://www.sr-support.com/forums/showthread.php?t=6.  and also how the double CR data is supposed to be accessed.
%
% Here are the error codes that come back on the eyeLink status checks:
%(from 28.3 eyelink.h File Reference in 'EyeLink Programmers Guide.pdf')
% • #define OK_RESULT 0
% • #define NO_REPLY 1000
% • #define LINK_TERMINATED_RESULT -100
% • #define ABORT_RESULT 27
% • #define UNEXPECTED_EOL_RESULT -1
% • #define SYNTAX_ERROR_RESULT -2
% • #define BAD_VALUE_RESULT -3
% • #define EXTRA_CHARACTERS_RESULT -4
% • #define current_msec() current_time()
% • #define LINK_INITIALIZE_FAILED -200
% • #define CONNECT_TIMEOUT_FAILED -201
% • #define WRONG_LINK_VERSION -202
% • #define TRACKER_BUSY -203
% • #define IN_DISCONNECT_MODE 16384
% • #define IN_UNKNOWN_MODE 0
% • #define IN_IDLE_MODE 1
% • #define IN_SETUP_MODE 2
% • #define IN_RECORD_MODE 4
% • #define IN_TARGET_MODE 8
% • #define IN_DRIFTCORR_MODE 16
% • #define IN_IMAGE_MODE 32
% • #define IN_USER_MENU 64
% • #define IN_PLAYBACK_MODE 256

if Eyelink('Initialize')==0
    %good
else
    error('couldn''t initialize eyeLink, see "help eyeLinkTracker/Initialize"')
end

%%  make sure that we get gaze data from the Eyelink
    status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,HMARKER');
    if status~=0
        error('link_sample_data error, status: ',status)
    end

%     turned off for a test
    status=Eyelink('command','inputword_is_window = ON');
    if status~=0
        error('inputword_is_window error, status: ',status)
    end

    
%% MAYBE ADD ON!
if 0
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    if doDisplay
        el=EyelinkInitDefaults(window);
    else
        el=EyelinkInitDefaults();
    end
end


%% set the path for the data

%subjectID=getID(subject);
%b=getBoxFromID(getBoxIDForStationID(r,s.id));
%eyeDataPath=fullfile(getBoxPathForSubjectID(b,subjectID,r),?subjectID?,'') %store by subject or by box?

% eyeDataPath= fullfile(fileParts(fileParts(getRatrixPath)),'ratrixData','eyeData',subjectID); 
eyeDataPath = fullfile('\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\Fan\datanet', subjectID, 'eyeRecords'); % 10/23/08 - to be replaced by oracle lookup
mkdir(eyeDataPath);
et=setEyeDataPath(et,eyeDataPath);