function CheckPTB
% for checking basic timing of ptb on your setup
clear Screen

numSecs = 5;
d = 100; %(80kB)

% edf's machine (intel core i7 2600 4x3.4GHz, 16GB, win7/64 sp1, nvidia geforce gt 430 1GB/128bit 4.1.0, r2011b) drops about 1 frame/sec when d = 800 (5MB)
% http://www.asus.com/Graphics_Cards/NVIDIA_Series/ENGT430DI1GD3LP
% http://ark.intel.com/products/52213

AssertOpenGL;
try
    Screen('Preference', 'Verbosity', 4);
    Screen('Preference', 'VisualDebugLevel', 6);
    Screen('Preference', 'SuppressAllWarnings', 0);
    Screen('Preference', 'SkipSyncTests', 0);
    
    s=max(Screen('Screens'));
    res=Screen('Resolution', s);
    
    [win, winRect] = Screen('OpenWindow', s);
    
    p=MaxPriority(win);
    Priority(p);
    fprintf('running at priority %d\n',p);
    
    hz=Screen('NominalFrameRate', win, 1);
    ifi=Screen('GetFlipInterval', win);
    
    n=ceil(numSecs*hz);
    t=nan(n,1);
    for i=1:n
        tex=Screen('MakeTexture', win, WhiteIndex(win)*(rand(d)>.5));
        Screen('DrawTexture', win, tex, [], winRect, [], 0);
        Screen('Close', tex);
        
        t(i) = Screen('Flip', win);
    end
    
catch e
    getReport(e)
end

plot([diff(t) repmat([ifi 1./[hz res.hz]],n-1,1)])
title('ifis')
ylabel('secs')
xlabel('frame')
legend({'measured','checked','nominal','res'})

Screen('CloseAll');
Priority(0);
end