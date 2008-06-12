function [window ifi]=startPTB(s)

doPrudentChecks = 1;        %set this bit to measure refresh empirically for more accurate timing (annoying blue flashes ensue)
%                           %as well as not altering the preferences VisualDebugLevel and SkipSyncTests
%                           %during real experiment, set to 1, but
%                           development is faster with 0

screenPtr = s.screenNum;              %0 for main screen (only one implemented for windows)
%                           % info for new ptb update:
%                           %Screen 0 - the full Windows desktop area. Useful for stereo presentations in stereomode=4 ...
%                           %Screen 1 - the display area of the monitor with the Windows-internal name \\.\DISPLAY1 ...
%                           %Screen 2 - the display area of the monitor with the Windows-internal name \\.\DISPLAY2 ...

if s.screenNum > -1
    clear Screen;
    Screen('Screens');
    try
        AssertOpenGL;
        %Screen('Preference','Backgrounding',0);  %mac only?
        % HideCursor;

        if ~doPrudentChecks
            oldEnableFlag=Screen('Preference', 'SkipSyncTests', 1);
            oldLevel=Screen('Preference', 'VisualDebugLevel', 1);

            % http://groups.yahoo.com/group/psychtoolbox/message/4292
            % > - A new Preference setting Screen('Preference', 'VisualDebugLevel',
            % > level); allows to customize the visual warning and feedback signals
            % > that can show up during Screen('OpenWindow'): A level of zero
            % > disables all feedback, a level of 1 allows errors to be signalled,
            % > a level of 2 includes warnings, a level of 3 includes information.
            % > Level 4 shows the blue screen at startup and level 5 enables the
            % > visual flicker test-sheet on multi-display setups. By default,
            % > level 6 is selected -- all warnings, bells & whistles on.
        end

        preScreen=GetSecs();
        window = Screen('OpenWindow',screenPtr,0);%,[],32,2); %color, rect, depth, buffers (none can be changed in curent version)
        %                                                  %blue screen is checking period (unless disabled by doPrudentChecks)
        disp(sprintf('took %g to call screen(openwindow)',GetSecs()-preScreen))

        %Priority(9);
        if doPrudentChecks
            ifi = Screen('GetFlipInterval',window);%,200); %numSamples
        else
            refreshRate=Screen('NominalFrameRate', screenPtr, 1);
            ifi=1/refreshRate;
        end
        %Priority(0);

        if ~strcmp(computer, 'MAC')
            clut = Screen('LoadCLUT', window); %supposed to replace with Screen('ReadNormalizedGammaTable',0), which is in range 0-1
            minV = min(min(clut));
        else
            warning('hacking min(loadclut)=0 -- need to figure out how to do this on osx')
            minV = 0;
        end;


        texture=Screen('MakeTexture', window, minV);
        [resident texidresident] = Screen('PreloadTextures', window);

        if resident ~= 1
            disp(sprintf('error: blank texture not cached'));
            find(texidresident~=1)
        end

        Screen('DrawTexture', window, texture,[],Screen('Rect', window),[],0);
        Screen('DrawingFinished',window,0);

        Screen('Flip',window);

        Screen('Close'); %leaving off second argument closes all textures

    catch
        Screen('CloseAll');
        Priority(0);
        ShowCursor;
        lasterr
        rethrow(lasterror);
    end
else
    window = -1;
    ifi = Screen('NominalFrameRate',0);
    if ifi==0 %happens via remote desktop, even though you can open a window and call Screen('GetFlipInterval') and get a good rate
        ifi = 60;
    end
end