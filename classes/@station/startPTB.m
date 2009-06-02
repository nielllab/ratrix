function s=startPTB(s,imagingTasks)

clear Screen;
Screen('Screens');
try
    
    if ~exist('imagingTasks','var') || isempty('imagingTasks')
        imagingTasks=[]; % default mode does not require any tasks for the imaging pipeline
    end
        
    AssertOpenGL;
    %Screen('Preference','Backgrounding',0);  %mac only?
    HideCursor;
    
    Screen('Preference', 'SkipSyncTests', 0);
    
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
    
    preScreen=GetSecs();
    if isempty(imagingTasks)
        s.window = Screen('OpenWindow',s.screenNum,0);%,[],32,2);  %%color, rect, depth, buffers (none can be changed in basic version)
    else
        PsychImaging('PrepareConfiguration');
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible'); %enable general support of such tasks
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
    end
    disp(sprintf('took %g to call screen(openwindow)',GetSecs()-preScreen))
    
    res=Screen('Resolution', s.screenNum);
    
    s.ifi = Screen('GetFlipInterval',s.window);%,200); %numSamples
    
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