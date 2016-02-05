%function running2p(fname,spname,label);
% fname ='running area - darkness stim - zoom1004.tif'
% spname = 'running area - darkness stim - zoom1004_stim_obj.mat';
close all
clear all
label = 'running';

dt = 0.25;
framerate=1/dt;

[f p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');

if strcmp(f(end-3:end),'.mat')
   display('loading data')
  sessionName = fullfile(p,f);
  load(fullfile(p,f))
   display('done')
else
    cycLength=10;
    dfofInterp = get2pdata(fullfile(p,f),dt,cycLength);
    
 
    [f p] = uiputfile('*.mat','save session data');
    sessionName=fullfile(p,f);
    display('saving data')
    save(sessionName,'dfofInterp','-v7.3','-append');
    display('done')
end

if ~exist('stimRec','var')
       [f p] =uigetfile('*.mat','speed data');
    spname = fullfile(p,f);
    load(spname);
    save(sessionName,'stimRec','-append')
end


interval = 1/framerate;
nframes = size(dfofInterp,3);

mouseT = stimRec.ts- stimRec.ts(1);

mouseMax = max(mouseT)
frameMax = nframes*dt
if max(mouseT)<(nframes*dt)
    display('duration of mouse times is less than duration of 2p images')
    nframes = floor(mouseMax/dt);
    dfofInterp = dfofInterp(:,:,1:nframes);
end


meandf = squeeze(mean(mean(dfofInterp,2),1));

dt_mouse = diff(mouseT);
use = [1>0; dt_mouse>0];
mouseT=mouseT(use);

posx = cumsum(stimRec.pos(use,1)-900);
posy = cumsum(stimRec.pos(use,2)-500);
frameT = dt:dt:max(mouseT);
vx = diff(interp1(mouseT,posx,frameT));
vy = diff(interp1(mouseT,posy,frameT));
vx(end+1)=0; vy(end+1)=0;
%
    figure
    plot(vx); hold on; plot(vy,'g');
sp = sqrt(vx.^2 + vy.^2);
%     figure
%     plot(sp)


sp = sp(1:length(meandf));
%spshift = circshift(spshift,25);


figure
plot((1:nframes)/framerate,meandf);
hold on
plot(frameT(1:length(sp)),sp/max(sp),'g');
xlabel('time');
legend('dfof','speed');
title(label);


figure

[xcc lag] = xcorr(meandf-mean(meandf),sp-mean(sp),'coeff');
plot(lag,xcc);
[y ind] = max(abs(xcc(lag>0 & lag<240)));
lag = lag(lag>0 & lag<240);
title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));

if ~exist('offset','var')
offset = lag(ind);
save(sessionName,'offset','-append')
end

%     figure
%     plot(xcorr(sp-mean(sp),meanimg-mean(meanimg)))
mv=sp>1000;
% display('calculating xcorr')
% tic
% for x = 1:size(dfofInterp,1);
%     x
%     for y = 1:size(dfofInterp,2);
%         xc(x,y) = xcorr(circshift(squeeze((dfofInterp(x,y,:))),-offset)-mean(dfofInterp(x,y,:)),sp'-mean(sp),0,'coeff');
%         %  xc(x,y) = corr(squeeze(dfof(x,y,:)),sp(1:size(dfof,3))','type','spearman');
%     end
% end
% fig = figure;
% imagesc(xc,[-0.5 0.5]); axis square; colormap jet
% title([label 'speed xcorr']);

figure
spoffset = circshift(sp',offset);
imagesc(mean(dfofInterp(:,:,spoffset>500),3)-mean(dfofInterp(:,:,spoffset<500),3),[-1 1]);
title('running dfof'); axis square

ptsfname = uigetfile('*.mat','pts file');
if ptsfname==0
    [pts dF neuropil] = get2pPts(dfofInterp);
else
    load(ptsfname);
end
dFClean = dF-0.7*repmat(neuropil,size(dF,1),1);

for i = 1:size(dF,1);
    df = circshift(dFClean(i,:)',-offset)';
    df=df(1:length(sp));
    %      figure
    %     plot((1:nframes)/framerate,df/max(df),'g');
    %
    %     hold on
    %     plot((1:nframes)/framerate, sp(1:size(dfofInterp,3))/max(sp),'b');
    %     legend('fluorescence','speed');
    
    figure
    subplot(2,1,1)
    [xcc lag] =  xcorr( df-mean(df),sp-mean(sp),'coeff');
    plot(lag,xcc)
    [y ind] = max(abs(xcc));
    title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));
    ylim([-0.5 0.5])
    
    subplot(2,1,2)
    plot(sp,df,'.')
    
    range = linspace(0, max(sp),10);
    for s = 1:length(range)-1;
        sphist(s) = mean(df(sp>range(s) & sp<range(s+1)));
    end
    hold on
    plot(range(1:end-1),sphist,'g'); ylim([0 2])
    
    xccenter = xcc(lag>-10 & lag<10);
    [y ind] = max(abs(xccenter));
    runC(i) = xccenter(ind);
    runZ(i) = (runC(i) - mean(xcc))/std(xcc);
    close(gcf)
end

figure
plot(runZ)

save(sessionName,'offset','runC','runZ','stimRec','-append');

for i = 1:5;
    figure(fig)
    [y x] = ginput(1);
    figure
    df = circshift(squeeze(dfofInterp(round(x),round(y),:)),-offset);
    plot((1:nframes)/framerate,df/max(df),'g');
    
    hold on
    plot((1:nframes)/framerate, sp(1:size(dfofInterp,3))/max(sp),'b');
    legend('fluorescence','speed');
    
    figure
    [xcc lag] =  xcorr( df-mean(df),sp-mean(sp),'coeff');
    plot(lag,xcc)
    [y ind] = max(abs(xcc));
    title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));
end




