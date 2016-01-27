% function [cycavg tuning] = analyzeMasking(dfof_bg,sp,moviename,useframes,base,xpts,ypts, label,stimRec,psfilename,frameT);
% close all
% clear all
%% code from analyzeWidefieldDOI
batchDOIphilMaskSizesel

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

   alluse = find(strcmp({files.inject},'doi')  & strcmp({files.timing},'pre') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
  
length(alluse)
%alluse=alluse(1:5)
%alluse=alluse(end-5:end);
allsubj = unique({files(alluse).subj})

%%% use this one for subject by subject averaging
%for s = 1:length(allsubj)
%use = intersect(alluse,find(strcmp({files.subj},allsubj{s})))    

%%% use this one to average all sessions that meet criteria
for s=1:1
use = alluse;
allsubj{s}
%%% calculate gradients and regions
clear map merge
x0 =0; y0=0; sz = 128;
doTopography;
end

%% code from doGratingsNew
 mnAmp=0; mnPhase=0; mnAmpWeight=0; mnData=0; mnFit=0;
    clear shiftData shiftAmp shiftPhase fit cycavg
    
for f = 1:length(use)
    figure
    set(gcf,'Name',[files(use(f)).subj ' ' files(use(f)).expt])

    for i = 1:2  %%%% load in topos for check
        if i==1
            load([pathname files(use(f)).topox],'map');
        elseif i==2
            load([pathname files(use(f)).topoy],'map');
        elseif i==3 && length(files(use(f)).topoyland)>0
            load([pathname files(use(f)).topoyland],'map');
        elseif i==4 &&length(files(use(f)).topoxland)>0
            load([pathname files(use(f)).topoxland],'map');
        end
        subplot(2,2,i);
        imshow(polarMap(shiftImageRotate(map{3},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz),90));
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
end

if ~isempty(files(use(f)).masking)
    load ([pathname files(use(f)).masking], 'dfof_bg','sp','stimRec','frameT')
    zoom = 260/size(dfof_bg,1);
    if ~exist('sp','var')
        sp =0;stimRec=[];
    end
    dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
    dfof_bg = imresize(dfof_bg,0.25);
    moviename = 'C:\metamask2sf2theta4soa15min'
    useframes = 3;
    base = 1;
    xpts = xpts/4;
    ypts = ypts/4;
    label = [files(use(f)).subj ' ' files(use(f)).expt];
end

%% code from analyzeGratingPatch
timingfig = figure;
subplot(2,2,1)
plot(diff(stimRec.ts));
xlabel('frame')
title('stim frames')

subplot(2,2,2)
plot(diff(frameT));
xlabel('frame')
title('acq frames')

subplot(2,2,3)
plot((stimRec.ts-stimRec.ts(1))/60,(stimRec.ts' - stimRec.ts(1)) - (1/60)*(0:length(stimRec.ts)-1));
hold on
plot((frameT-frameT(1))/60,(frameT' - frameT(1)) - 0.1*(0:length(frameT)-1),'g');
legend('stim','acq')
ylabel('slippage (secs)')
xlabel('mins')

sf=0; tf=0; isi=0; duration=0; radius=0; %PRLP

load(moviename);

imagerate=10;

imageT=(1:size(dfof_bg,3))/imagerate;
img = imresize(double(dfof_bg),1,'method','box');

trials = length(sf)-1;
trials = floor(min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1);
xpos=xpos(1:trials); sf=sf(1:trials); lag=lag(1:trials); dOri=dOri(1:trials); %PRLP

acqdurframes = (duration+isi)*imagerate; %%% length of each cycle in frames;
nx=ceil(sqrt(acqdurframes+1)); %%% how many rows in figure subplot

%%% mean amplitude map across cycle
figure
map=0;
for f=1:acqdurframes
    cycavg(:,:,f) = mean(img(:,:,(f+trials*acqdurframes/2):acqdurframes:end),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavg(:,:,f)),[-0.02 0.02])
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    map = map+squeeze(cycavg(:,:,f))*exp(2*pi*sqrt(-1)*(0.5 +f/acqdurframes));
end

%%% add timecourse
subplot(nx,nx,f+1)
plot(circshift(squeeze(mean(mean(cycavg,2),1)),5))
axis off
set(gca,'LooseInset',get(gca,'TightInset'))
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%%% calculate phase of cycle response
%%% good for detectime framedrops or other problems
tcourse = squeeze(mean(mean(img,2),1));

fourier = tcourse'.*exp((1:length(tcourse))*2*pi*sqrt(-1)/(10*duration + 10*isi));
figure(timingfig)
subplot(2,2,4)
plot((1:length(tcourse))/600,angle(conv(fourier,ones(1,600),'same')));
ylim([-pi pi])
ylabel('phase'); xlabel('mins')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%%% separate responses by trials
speedcut = 500;
trialdata = zeros(size(img,1),size(img,2),trials+2);
trialspeed = zeros(trials+2,1);
shift = (duration+isi)*imagerate;
trialcyc = zeros(size(img,1),size(img,2),shift,trials+2);
for tr=1:trials;
    t0 = round((tr-1)*shift);
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
    try
        trialspeed(tr) = mean(sp(useframes+t0));
    catch
        trialspeed(tr)=500;
    end
    trialcourse(tr,:) = squeeze(mean(mean(img(:,:,t0+(1:10)),2),1));
    trialcyc(:,:,:,tr) = img(:,:,t0+shift/2+(1:10));    %whats the proper amount to shift this?
end

% %%% get full timecourse for each stim condition
% trialcycavg = zeros(size(img,1),size(img,2),20,size(xrange),size(radiusRange),size(sfrange),size(tfrange));
% for tr = 1:trials
%     

spd = tf./sf;
spd(tf==0)=0;
spd(sf==0)=0;
unique(spd);
spd(spd==0)=1.6;
spd=log(spd);
xrange = unique(xpos); sfrange=unique(sf); lagrange = unique(lag); dOrirange = unique(dOri);
tuning=zeros(size(trialdata,1),size(trialdata,2),length(xrange),length(sfrange),length(lagrange),length(dOrirange));



%%% separate out responses by stim parameter
cond = 0;
run = find(trialspeed>=speedcut);
sit = find(trialspeed<speedcut);
for i = 1:length(xrange)
    i
    for j= 1:length(sfrange)
        for k = 1:length(lagrange)
            for l=1:length(dOrirange)
                cond = cond+1;
                inds = find(xpos==xrange(i)&sf==sfrange(j)&lag==lagrange(k)&dOri==dOrirange(l));
                avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,inds),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
                avgtrialcourse(i,j,k,l,:) = squeeze(median(trialcourse(inds,:),1));
                avgcondtrialcourse(cond,:) = avgtrialcourse(i,j,k,l,:);
                avgspeed(cond)=0;
                avgx(cond) = xrange(i); avgsf(cond)=sfrange(j); avglag(cond)=lagrange(k); avgdOri(cond)=dOrirange(l);
                tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
                meanspd(i,j,k,l) = squeeze(mean(trialspeed(inds)>500));
                trialcycavg(:,:,:,i,j,k,l) = squeeze(mean(trialcyc(:,:,:,inds),4));
                trialcycavgRun(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,run)),4));
                trialcycavgSit(:,:,:,i,j,k,l) = squeeze(nanmean(trialcyc(:,:,:,intersect(inds,sit)),4));
            end
        end
    end
end

% %get average map with no stimulus
% for i = 1:length(xrange)
%     minmap(:,:,i) = squeeze(mean(mean(tuning(:,:,i,1,:,:),5),6));
%     mintrialcyc(:,:,:,i) = squeeze(mean(mean(trialcycavg(:,:,:,i,1,:,:),6),7));
% end
% %subtract average map with no stimulus from every map
% for i = 1:length(xrange)
%     for j = 1:length(radiusRange)
%         for k = 1:length(sfrange)
%             for l = 1:length(tfrange)
%                 tuning(:,:,i,j,k,l) = tuning(:,:,i,j,k,l)-minmap(:,:,i);
%                 trialcycavg(:,:,:,i,j,k,l) = trialcycavg(:,:,:,i,j,k,l)-mintrialcyc(:,:,:,i);
%             end
%         end
%     end
% end

%%% plot response based on previous trial's response
%%% this is a check for whether return to baseline is an issue
% figure
% plot(avgcondtrialcourse(:,1)-avgcondtrialcourse(:,10),avgcondtrialcourse(:,5)-avgcondtrialcourse(:,10),'o');
% xlabel('pre dfof'); ylabel('post dfof');


%%% plot responses at different lags
figure %one set of plots for each x position
cnt = 0;
for i = 1:length(xrange)
    for j=1:length(lagrange)
        cnt = cnt+1;
        subplot(length(xrange),length(lagrange),cnt)
        imagesc(squeeze(mean(mean(tuning(:,:,i,:,j,:),4),6)),[ -0.005 0.05]); colormap jet;
        title(sprintf('%0.0fxpos %0.0flag',xrange(i),lagrange(j)))
        axis off; axis equal
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
end
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end


for i = 1:length(dOrirange)
    figure %one plot for each dOri
    for j = 1:length(lagrange)
        subplot(3,3,j)
        imagesc(squeeze(mean(mean(tuning(:,:,:,:,j,i),3),4)),[ -0.02 0.15]); colormap jet;
        title(sprintf('%0.0flag',lagrange(j)))
        axis off; axis equal
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:length(xrange)
    d = squeeze(mean(mean(tuning(:,:,i,:,1,:),4),6));
    ximg(:,:,i) = (d-min(min(d)))/(max(max(d))-min(min(d)));
end
ximg(:,:,3) = 0;

[fname pname] = uigetfile('*.mat','points file');
if fname~=0
    load(fullfile(pname, fname));
else
    figure
    for i = 1:length(xrange)
        imshow(ximg(:,:,i));hold on; plot(ypts,xpts,'w.','Markersize',2)
        [y(i) x(i)] = ginput(1);
        x=round(x); y=round(y);
    %     range = floor(size(ximg,1)*0.05); %findmax range is 5% of image size
    %     [maxval(i) maxind(i)] =  max(max(ximg(x(i)-range:x(i)+range,y(i)-range:y(i)+range,1)));
    %     [xoff(i),yoff(i)] = ind2sub([1+2*range,1+2*range],maxind(i));
    end
    close(gcf);
    [fname pname] = uiputfile('*.mat','save points?');
    if fname~=0
        save(fullfile(pname,fname),'x','y');
    end
end
% x = x+(xoff'-(1+range));
% y = y+(yoff'-(1+range));
figure
imshow(ximg);hold on;plot(y,x,'o');



%% get lag/orientation tuning curves across sf
figure
for i = 1:length(xrange)
    subplot(1,length(xrange),i)
    hold on
    for j = 1:length(dOrirange)
        plot(1:size(tuning,5),squeeze(mean(tuning(x(i),y(i),i,:,:,j),4)))
    end
    set(gca,'xtick',1:length(lagrange),'xticklabel',lagrange)
    xlabel('lag')
    axis([1 length(lagrange) 0 0.25])
end
legend('aligned','perpend','location','northwest')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%%plot cycle averages for the different radii at the 2 x positions
figure
for i = 1:length(xrange)
    subplot(1,length(xrange),i)
    hold on
    for j = 1:length(lagrange)
        plot(circshift(squeeze(mean(mean(trialcycavg(x(i),y(i),:,i,:,j,:),5),7)),5))
    end
end
legend('0','2','4','6')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%%plot cycle averages for the different lags at the 2 x positions run vs.
%%sit
figure
for i = 1:length(xrange)
    subplot(2,length(xrange),i)
    hold on
    for j = 1:length(lagrange)
        plot(circshift(squeeze(mean(mean(trialcycavgRun(x(i),y(i),:,i,:,j,:),5),7)),5))
    end
    axis([1 shift -0.1 0.25])
    title('run')
    hold off
    subplot(2,length(xrange),i+length(xrange))
    hold on
    for j = 1:length(lagrange)
        plot(circshift(squeeze(mean(mean(trialcycavgSit(x(i),y(i),:,i,:,j,:),5),7)),5))
    end
    axis([1 shift -0.05 0.15])
    title('sit')
    hold off
end
legend('0','2','4','6')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%%get percent time running
sp = conv(sp,ones(50,1),'same')/50;
mv = sum(sp>500)/length(sp);
figure
subplot(1,2,1)
bar(mv);
xlabel('subject')
ylabel('fraction running')
subplot(1,2,2)
bar([mean(trialspeed(run)) mean(trialspeed(sit))])
set(gca,'xticklabel',{'run','sit'})
ylabel('speed')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end
%%
[f p] = uiputfile('*.mat','save data?');
sessiondata = files(alluse);

if f~=0
%     save(fullfile(p,f),'allsubj','sessiondata','shiftData','fit','mnfit','cycavg','mv');
    save(fullfile(p,f),'cycavg','tuning');
end

[f p] = uiputfile('*.pdf','save pdf');
if f~=0
    try
   ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,f));
catch
    display('couldnt generate pdf');
    end
end
delete(psfilename);