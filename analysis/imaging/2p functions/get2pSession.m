% Get File Path for tiff Image
[f,p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');
cycLength = input('cycle length : ');

%Get Image acquisition frame rate
Img_Info = imfinfo(fullfile(p,f));
eval(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;
dt = 1/framerate;
    
if strcmp(f(end-3:end),'.mat')
    disp('loading data')
    sessionName = fullfile(p,f);
    load(sessionName)
    disp('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end
else
    disp(f);
    [ttlf, ttlp] = uigetfile('*.mat','ttl file');
    try
        [stimPulse, framePulse] = getTTL(fullfile(ttlp,ttlf));
        figure
        plot(diff(stimPulse)); title('stimPulse cycle time');hold on
        plot(1:length(stimPulse),ones(size(stimPulse))*cycLength); ylabel('secs');xlabel('stim #')
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

        startTime = round(stimPulse(1)/dt)-1;
    catch
        disp('couldnt read TTLs')
        stimPulse=[]; framePulse=[]; startTime = 1;
    end
    
    ttlFname = fullfile(ttlp,ttlf);

    if twocolor
        [dfofInterp, dtRaw, redframe, greenframe, mv] = get2colordata(fullfile(p,f),dt,cycLength);
    else
        [dfofInterp, dtRaw, greenframe] = get2pdata(fullfile(p,f),dt,cycLength);
    end
    
    figure
    timecourse = squeeze(mean(mean(dfofInterp(:,:,1:end),2),1));
    plot(timecourse);
        
    hold on
    for st = 0:10
        plot(st*cycLength/dt+ [startTime startTime],[0.2 1],'g:')
    end
    
    sprintf('estimated start time %f',startTime)
    % startTime = input('start time : ');
    
    for st = 0:10
        plot(st*cycLength+ [startTime*dt startTime*dt],[0.2 1],'k:')
    end
    
    dfofInterp = dfofInterp(:,:,startTime:end);
    
%     clear cycAvg
%     cycAvg = zeros(cycLength/dt,1);
%     for i = 1:cycLength/dt
%         cycAvg(i) = mean(mean(mean(dfofInterp(:,:,i:cycLength/dt:end))));
%     end
%     figure
%     plot(cycAvg); title('cycle average'); xlabel('frames')
    
%     [fs ps] = uiputfile('*.mat','session data');
%     if fs ~=0
%         display('saving data')
%         sessionName= fullfile(ps,fs);
%         if twocolor
%             save(sessionName,'dfofInterp','startTime','cycLength','redframe','greenframe','-v7.3');
%         else
%             save(sessionName,'dfofInterp','startTime','cycLength','greenframe','-v7.3');
%         end
%         display('done')
%     end
end
