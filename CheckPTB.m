function CheckPTB
% for checking basic timing of ptb on your setup
clear Screen

numSecs = 5;
d = 100; %(80kB)

% edf's machine (intel core i7 2600 4x3.4GHz, 16GB, win7/64 sp1, discrete nvidia geforce gt 430 1GB/128bit 4.1.0, r2011b) drops about 1 frame/sec when d = 800 (5MB)
% http://www.asus.com/Graphics_Cards/NVIDIA_Series/ENGT430DI1GD3LP
% http://ark.intel.com/products/52213

% niell lab cheap stations (AMD athlon II X2 260 2x3.2GHz, 4GB, win7/32 sp1, integrated ati radeon hd 4250, 3.3.11554, r2011b)  drops about 1 frame/sec when d = 375 (1.125 MB)
% http://www.asus.com/Motherboards/AMD_AM3Plus/M5A88M/
% http://www.amd.com/us/products/desktop/processors/athlon-ii-x2/Pages/AMD-athlon-ii-x2-processor-model-numbers-feature-comparison.aspx
% note 2nd core was disabled, needed BIOS update to v1001 using asus update (http://dlcdnet.asus.com/pub/ASUS/misc/utils/AsusUpdt_V71803.zip)
% also turn off catalyst a.i.

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