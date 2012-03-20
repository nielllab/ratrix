function CheckPTB
% for checking basic timing of ptb on your setup
clear Screen

numSecs = 5;

AssertOpenGL;

try
    Screen('Preference', 'Verbosity', 4);
    Screen('Preference','VisualDebugLevel', 6);
    
    s=max(Screen('Screens'));
    res=Screen('Resolution', s);
    
    [win, winRect] = Screen('OpenWindow', s);
    
    p=MaxPriority(win);
    Priority(p);
    fprintf('running at priority %d',p);
    
    hz=Screen('NominalFrameRate', win, 1);
    ifi=Screen('GetFlipInterval', win);
    
    n=ceil(numSecs*hz);
    t=nan(n,1);
    for i=1:n
        tex=Screen('MakeTexture', win, WhiteIndex(win)*(rand(100)>.5));
        Screen('DrawTexture', win, tex, [], winRect, [], 0);
        Screen('Close', tex);
        
        t(i) = Screen('Flip', win);
    end
    
catch e
    getReport(e)
end

plot([diff(t) repmat([ifi 1./[hz res.hz]],n-1,1)])
title('ifis')
xlabel('secs')
ylabel('frame')
legend({'measured','checked','nominal','res'})

Screen('CloseAll');
Priority(0);
end