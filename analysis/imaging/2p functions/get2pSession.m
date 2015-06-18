
[f p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');
if strcmp(f(end-3:end),'.mat')
    display('loading data')
    sessionName = fullfile(p,f);
    load(sessionName)
    display('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end
else
    
    [ttlf ttlp] = uigetfile('*.mat','ttl file')
   try 
       [stimPulse framePulse] = getTTL(fullfile(ttlp,ttlf));
       startTime = round(stimPulse(1)/dt);
   catch
       display('couldnt read TTLs')
       stimPulse=[]; framePulse=[]; startTime = 1;
   end
   
   ttlFname = fullfile(ttlp,ttlf);
    cycLength = input('cycle length : ');
    if twocolor
       [dfofInterp dtRaw redframe greenframe] = get2colordata(fullfile(p,f),dt,cycLength);
    else
        [dfofInterp dtRaw greenframe] = get2pdata(fullfile(p,f),dt,cycLength);
    end
    
    figure
    timecourse = squeeze(mean(mean(dfofInterp(:,:,1:120/dt),2),1));
    plot((1:120/dt),timecourse);
    
    hold on
    for st = 0:10
        plot(st*cycLength/dt+ [startTime startTime],[0.2 1],'g:')
    end
   
    sprintf('estimated start time %f',startTime)    
    startTime = input('start time : ');
    
    for st = 0:10
        plot(st*cycLength+ [startTime*dt startTime*dt],[0.2 1],'k:')
    end
    
    dfofInterp = dfofInterp(:,:,startTime:end);
    
    clear cycAvg
    for i = 1:cycLength/dt;
        cycAvg(i) = mean(mean(mean(dfofInterp(:,:,i:cycLength/dt:end))));
    end
    figure
    plot(cycAvg)
        
    [fs ps] = uiputfile('*.mat','session data');
    display('saving data')
    sessionName= fullfile(ps,fs);
   if twocolor
          save(sessionName,'dfofInterp','startTime','cycLength','redframe','greenframe','-v7.3'); 
   else
       save(sessionName,'dfofInterp','startTime','cycLength','greenframe','-v7.3');
   end
   display('done')
end
