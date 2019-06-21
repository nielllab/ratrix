%%% creates session data or reads previously generated session data

if~isfield(cfg,'alignData')
    cfg.alignData = 1;
end

if ~exist('fileName','var')
    
    [f p] = uigetfile({'*.mat;*.sbx'},'.mat or .tif file');
    fileName = fullfile(p,f)
end

if strcmp(fileName(end-3:end),'.mat') %%% previously generated
    display('loading data')
    load(fileName)
    display('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end
    
else %%% new session data
    
    fileName = fileName(1:end-4)  %%% create filename
    
 if ~exist('cycLength','var')
     cycLength = 2;
 end
    
    %     twocolor = input('# of channels : ')
    %     twocolor= (twocolor==2);
    %
    twocolor=0;
    
    if twocolor
        [dfofInterp dtRaw redframe greenframe] = get2colordata(fileName,dt,cycLength,cfg); %%% not currently functional!
    else
        [dfofInterp dtRaw greenframe framerate phasetimes meanImg dt vidframetimes] = get2pdata_sbx(fileName,dt,cycLength,cfg);
    end
    
    
    if ~exist('sessionName','var')
        [fs ps] = uiputfile('*.mat','session data');
        sessionName= fullfile(ps,fs);
    end
    if ~iscell(sessionName) && sessionName(1)~=0
        display('saving data')
        
        tic
        if twocolor
            save(sessionName,'dfofInterp','cycLength','redframe','greenframe','-v7.3');
        else
            save(sessionName,'cycLength','greenframe','phasetimes','meanImg','dt','cfg','-v7.3');
            if cfg.saveDF==1
                save(sessionName,'dfofInterp','-append');
            end
        end
        toc
        display('done')
    end
end

figure
% timecourse = squeeze(mean(mean(dfofInterp(:,:,1:60/dt),2),1));
timecourse = squeeze(mean(mean(dfofInterp,2),1));
% plot(dt:dt:60,timecourse); xlabel('secs')
plot(timecourse); xlabel('secs')
% hold on
% for st = 0:10
%     plot(st*cycLength,[0.2 1],'g:')
% end

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

clear cycAvg
for i = 1:cycLength/dt;
    cycAvg(i) = mean(mean(mean(dfofInterp(:,:,i:cycLength/dt:end))));
end
figure
plot((1:length(cycAvg))*dt,cycAvg); xlabel('secs'); title('cycle average')

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
