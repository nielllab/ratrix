
[f p] = uigetfile({'*.mat;*.sbx'},'.mat or .tif file');
if strcmp(f(end-3:end),'.mat')
    display('loading data')
    sessionName = fullfile(p,f);
    load(sessionName)
    display('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end
else
    
    f = f(1:end-4)
    
    
    cycLength = input('cycle length : ');
    if twocolor
        [dfofInterp dtRaw redframe greenframe] = get2colordata(fullfile(p,f),dt,cycLength);
    else
        [dfofInterp dtRaw greenframe framerate] = get2pdata_sbx(fullfile(p,f),dt,cycLength);
    end
    
    global info
    stim = find( info.event_id ==1);
    if ~isempty(stim)
        startTime = info.frame(stim(1))/framerate;
    else
        startTime = 1;
    end
    
    figure
    timecourse = squeeze(mean(mean(dfofInterp(:,:,1:120/dt),2),1));
    plot(dt:dt:120,timecourse); xlabel('secs')
    
    hold on
    for st = 0:10
        plot(st*cycLength+ [startTime startTime],[0.2 1],'g:')
   
    end
    
    sprintf('estimated start time %f',startTime)
    startTime = input('start time : ');
    
    for st = 0:10
        plot(st*cycLength+ [startTime startTime],[0.2 1],'k:')
    end
    
    keyboard
    
    dfofInterp = dfofInterp(:,:,round(startTime/dt):end);
    
    clear cycAvg
    for i = 1:cycLength/dt;
        cycAvg(i) = mean(mean(mean(dfofInterp(:,:,i:cycLength/dt:end))));
    end
    figure
    plot(cycAvg)
    
    [fs ps] = uiputfile('*.mat','session data');
    if fs~=0
        display('saving data')
    sessionName= fullfile(ps,fs);
    if twocolor
        save(sessionName,'dfofInterp','startTime','cycLength','redframe','greenframe','-v7.3');
    else
        save(sessionName,'dfofInterp','startTime','cycLength','greenframe','-v7.3');
    end
    display('done')
    end
end
