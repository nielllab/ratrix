function s=startPTB(s,imagingTasks,depth)
if ~exist('depth','var') || isempty(depth)
    depth=32;
%  else
%      depth=8; %hardcoded for now cuz depth above comes from requested resolution, which may differ from desired value here
end

clear Screen;
Screen('Preference', 'DefaultVideocaptureEngine', 3); %for recording.  3 -> gstreamer, 0 -> quicktime (may need to set for osx)
% note: on linux, probably need to install plugins for h.264...
%  Video or movie
%   recording with high quality (DivX, H.264) will also require recent versions
%   of additional plugin packages containing support for these formats. These
%   are usually not installed by default due to licensing and patent clauses in
%   place for some territories. You may want to specifically add them to your
%   system depending on your format needs.
%  
%   On Debian 
%  
%       sudo apt-get install gstreamer0.10-plugins-bad-multiverse gstreamer0.10-plugins-ugly-multiverse
%  


Screen('Screens');
try
    
    if ~exist('imagingTasks','var') || isempty('imagingTasks')
        imagingTasks=[]; % default mode does not require any tasks for the imaging pipeline
    end
        
    AssertOpenGL;
    %Screen('Preference','Backgrounding',0);  %mac only?
    HideCursor;
    
    Screen('Preference', 'SkipSyncTests', 0);
    Screen('Preference', 'SkipSyncTests', 1); %edf added 12.19.11 to right mtrix cuz lcd?

    
    Screen('Preference', 'VisualDebugLevel', 6);
    %http://psychtoolbox.org/wikka.php?wakka=FaqWarningPrefs
    %Level 4 is most thorough, level 1 is errors only.
    
    % http://groups.yahoo.com/group/psychtoolbox/message/4292
    % A new Preference setting Screen('Preference', 'VisualDebugLevel',level);
    % allows to customize the visual warning and feedback signals that can show up during Screen('OpenWindow')
    % zero disables all feedback
    % 1 allows errors to be signalled
    % 2 includes warnings
    % 3 includes information
    % 4 shows the blue screen at startup
    % 5 enables the visual flicker test-sheet on multi-display setups
    % By default, level 6 is selected -- all warnings, bells & whistles on.
    
    Screen('Preference', 'SuppressAllWarnings', 0);
    
    Screen('Preference', 'Verbosity', 4);
    %http://psychtoolbox.org/wikka.php?wakka=FaqWarningPrefs
    %0) Disable all output - Same as using the 'SuppressAllWarnings' flag.
    %1) Only output critical errors.
    %2) Output warnings as well.
    %3) Output startup information and a bit of additional information. This is the default.
    %4) Be pretty verbose about information and hints to optimize your code and system.
    %5) Levels 5 and higher enable very verbose debugging output, mostly useful for debugging PTB itself, not generally useful for end-users.
    
    % Screen('Preference', 'Verbosity', 1); %edf's machine is stuck on  Microsofts OpenGL software renderer
    
    dd = 'C:\sessionDiaries';
    [status,message,messageid] = mkdir(dd);
    if status ~= 1
        status
        message
        messageid
        error('couldn''t mkdir')
    end
    dd = fullfile(dd,[datestr(now,30) '.txt']);
    % this could slow us down -- be afraid!
    % also note that bootstrap, in network mode, tries to make its own diary, that will conflict with this
    % also fix this to be cross platform (ideally save in ratrix data dir) 
    diary(dd);
    % see https://groups.yahoo.com/neo/groups/PSYCHTOOLBOX/conversations/messages/19322
    
    ver
    
    rc = PsychGPUControl('SetGPUPerformance', 10);
    if rc ~= 0
        rc
        warning('couldn''t set gpuperformance -- only works on ati gpu')
    else
        fprintf('set gpuperformance to 10\n')
    end
    
    preScreen=GetSecs();
    if isempty(imagingTasks)
        s.window = Screen('OpenWindow',s.screenNum,0,[],depth);%,2);  %%color, rect, depth, buffers (none can be changed in basic version)
    else
        warning('edf says: have you checked that the stopPTB will remove these tasks?  i see no evidence that you clean up after yourself if a later trial doesn''t want these things.  a clear Screen may help, but i want proof.  it''s not stated in ''help psychimaging'' -- worst case, ask mario.  also, i don''t see that you''ve been careful to make sure the pipeline details are recorded in the trial record.')
        %well, i guess it's relatively convincing that you get a unique window pointer out of it, so i'm downgrading to a warning...
        
        PsychImaging('PrepareConfiguration');
        % PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); %enable general support of such tasks
        %6/2/09 - add imagingTasks to the pipeline
        for i=1:length(imagingTasks)
            % add task
            evalStr=sprintf('PsychImaging(''AddTask''');
            for j=1:length(imagingTasks{i})
                if ischar(imagingTasks{i}{j})
                    evalStr=sprintf('%s,''%s''',evalStr,imagingTasks{i}{j});
                elseif isnumeric(imagingTasks{i}{j})
                    evalStr=sprintf('%s,%d',evalStr,imagingTasks{i}{j});
                else
                    error('arguments to PsychImaging must be char or numeric');
                end
            end
            evalStr=[evalStr ');'];
            eval(evalStr);
        end
        s.window = PsychImaging('OpenWindow', s.screenNum, 0); % use psychImaging if tasks are applied
        s.imagingTasks=imagingTasks;
    end
    disp(sprintf('took %g to call screen(openwindow)',GetSecs()-preScreen))
    
    res=Screen('Resolution', s.screenNum);
    
    s.ifi = Screen('GetFlipInterval',s.window);%,200); %numSamples
    
    [~, s.ptbVersion] = PsychtoolboxVersion;
    s.screenVersion = Screen('Version');
    s.skipSyncTests = Screen('Preference', 'SkipSyncTests');
    s.matlabVersion = version;
    [~,s.matlab64,s.win64,~] = getPP;
    s.computer = Screen('Computer');
    s.diary = dd;
    
    if res.hz~=0
        if abs((s.ifi/(1/res.hz))-1)>.1
            s.ifi
            1/res.hz
            error('screen(resolution) reporting framerate off by more than 10%% of measured ifi') %needs to be warning to work with remotedesktop
        end
    else
        if ~ismac
            error('screen(resolution) reporting 0 hz, but not on mac')
        end
        x=Screen('Resolutions',s.screenNum);
        %[x.hz]
        warning('screen(resolution) reporting 0 hz -- calcStims must take this into account (this happens on osx)')
    end
    
    texture=Screen('MakeTexture', s.window, BlackIndex(s.window));
    [resident texidresident] = Screen('PreloadTextures', s.window);
    
    if resident ~= 1
        disp(sprintf('error: blank texture not cached'));
        find(texidresident~=1)
    end
    
    Screen('DrawTexture', s.window, texture,[],Screen('Rect', s.window),[],0);
    Screen('DrawingFinished',s.window,0);
    
    Screen('Flip',s.window);
    
    Screen('Close'); %leaving off second argument closes all textures
    
catch ex                  
    s.ifi=[];
    s.window=[];
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    rethrow(ex);
end