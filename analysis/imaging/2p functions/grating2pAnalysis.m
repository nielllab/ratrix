%this is a modification of the gratingAnalysis function and does a
%cell-wise analysis of the grating stimulus after 2p cell extraction has
%been performed
% function [osicv osi tuningtheta amp tfpref minp R resp alltuning spont allresp] = grating2pAnalysis(fname, startTime, dF, dt, blank);

clear all
close all
dbstop if error

movname = 'C:\grating2p8orient2sfBlank.mat';
dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=8/dt;
pre = 0; %1 if pre, 0 if post, determines naming of output file
exclude = 0; %0 removes trials above threshold, 1 clips them to the threshold
peakWindow = 1:80;

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end

%%% get topo stimuli

%%% read topoX (spatially periodic white noise)
%%% long axis of monitor, generally vertical
[f p] = uigetfile('*.mat','topo x pts');
load(fullfile(p,f));

%%% extract phase and amplitude from complex fourier varlue at 0.1Hz
xph = phaseVal; rfCyc(:,:,1) = cycAvg;  %%%cycle averaged timecourse (10sec period)
rfAmp(:,1) = abs(xph); rf(:,1) = mod(angle(xph)-(2*pi*0.25/10),2*pi)*128/(2*pi); %%% convert phase to pixel position, subtract 0.25sec from phase for gcamp delay
topoxUse = mean(dF,2)~=0;  %%% find cells that were successfully extracted

%%% read topoY (spatially periodic white noise)
%%% short axis of monitor, generally horizontal
[f p] = uigetfile('*.mat','topo y pts');
load(fullfile(p,f));

figure
imagesc(dF,[0 1])
cellCutoff = input('cell cutoff : ')

%%% extract phase and amplitude from complex fourier varlue at 0.1Hz
yph = phaseVal; rfCyc(:,:,2) = cycAvg;
rf(:,2) = mod(angle(yph)-(2*pi*0.25/10),2*pi)*72/(2*pi); rfAmp(:,2) = abs(yph);
topoyUse = mean(dF,2)~=0;

%%% find sbc? use distance from center?
d1 = sqrt((mod(angle(xph),2*pi)-pi).^2 + (mod(angle(yph),2*pi)-pi).^2);
d2 = sqrt((mod(angle(xph)+pi,2*pi)-pi).^2 + (mod(angle(yph)+pi,2*pi)-pi).^2);
sbc = (d1>d2);

respthresh=0.025;
%%% select cells responsive to both topoX and topoY
dpix = 0.8022; centrad = 10; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
d = sqrt((rf(:,1)-xcent).^2 + (rf(:,2)-ycent).^2);
%goodTopo = find(rfAmp(:,1)>0.01 & rfAmp(:,2)>0.01 & (xcent-dpix*centrad)<rf(:,1) & rf(:,1)<(xcent+dpix*centrad)& (ycent-dpix*centrad)<rf(:,2) & rf(:,2)<(ycent+dpix*centrad));
goodTopo = find(rfAmp(:,1)>respthresh & rfAmp(:,2)>respthresh & d<centrad/dpix);
goodTopo=goodTopo(goodTopo<=cellCutoff);
sprintf('%d cells in center with good topo under cutoff',length(goodTopo))

allgoodTopo = find(~sbc & rfAmp(:,1)>respthresh & rfAmp(:,2)>respthresh); allgoodTopo = allgoodTopo(allgoodTopo<=cellCutoff);
sprintf('%d cells with good topo under cutoff',length(allgoodTopo))
%%% plot RF locations
figure
hold on
plot(rf(allgoodTopo,2),rf(allgoodTopo,1),'.','color',[0.5 0.5 0.5],'MarkerSize',10); %%% the rfAmp criterion wasn't being applied here
plot(rf(goodTopo,2),rf(goodTopo,1),'b.','MarkerSize',10);
circle(ycent,xcent,centrad/dpix)
axis equal;
axis([0 72 0 128]);
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

% ptsfname = uigetfile('*.mat','pts file');
[f p] = uigetfile('*.mat','gratings pts file');
ptsfname = fullfile(p,f);
load(ptsfname);

movname
load(movname)

%stopped here

baseRange = round((2.5:dt:3.5)/dt);
evokeRange = round((0:dt:2)/dt);

nstim = min(length(xpos),floor(size(dF,2)*dt/8 -1))
theta = theta(1:nstim); sf = sf(1:nstim);
for s = 1:nstim;
    
    base(:,s) = mean(dF(:,startTime + (s-1)*(duration+isi)/dt +baseRange),2);
    evoked(:,s) = mean(dF(:,startTime + isi/dt +(s-1)*(duration+isi)/dt +evokeRange),2);
end

resp = evoked-base;

angles = unique(theta);
sf
sfs = unique(sf);

for th = 1:length(angles);
    for sp = 1:length(sfs);
        %   allresp(:,th,sp,:) = resp(:,theta ==angles(th) & sf==sfs(sp));
        orientation(:,th,sp) = median(resp(:,theta ==angles(th) & sf==sfs(sp)),2);
        %     figure
        %     imagesc(squeeze(orientation(:,:,th)),[-0.5 0.5]);
        ori_std(:,th,sp) = std(resp(:,theta ==angles(th) & sf==sfs(sp)),[],2);
    end
end

allresp=[];
npts = size(dF,1);

if npts<=1000
    figure
    nfigs = ceil(sqrt((npts)));
end

for i= 1:npts
    if i/1000 == round(i/1000);
        i
    end
    
    tftuning=squeeze(mean(orientation(i,:,:),2));
    tfpref(i) =(tftuning(2)-tftuning(1))/(tftuning(2) + tftuning(1));
    %     if tfpref(i)>0
    %         tf_use=2;
    %     else
    %         tf_use=1;
    %     end
    
    if abs(tftuning(1))>abs(tftuning(2))
        tf_use=1;
    else
        tf_use=2;
    end
    if ~blank
        tuning = squeeze(orientation(i,:,tf_use));
        tuning_std = squeeze(ori_std(i,:,tf_use));
        spont(i)=0; spont_std(i)=0;
    else
        tuning = squeeze(orientation(i,1:end-1,tf_use)) ; tuning_std = squeeze(ori_std(i,1:end-1,tf_use));
        spont(i) = mean(orientation(i,end,:)); spont_std(i)=sqrt(sum(ori_std(i,end,:).^2))/(size(ori_std,3));
    end
    ntrials = length(find(theta==angles(1) & sf==sfs(1)));
    
    
    R(i) = max(tuning)-spont(i);
    
    [osicv(i) tuningtheta(i)] = calcOSI(tuning'-spont(i),0);
    if npts<100*100
        [thetafit(i) osi(i) A1(i) A2(i) w(i) B(i) nr yfit] = fit_tuningcurve(tuning-spont(i),angles(1:length(tuning)));
        if ~(sum(tuning)==0)
        [osi(i) width(i) amp(i)] = calculate_tuning(A1(i),A2(i),B(i),w(i));
                else
                    osi(i)=NaN; width(i)=NaN; amp(i)=0;
                end
    else
        osi=[];
        width=[];
        amp=[];
    end
    
    alltuning(i,:)=tuning;
    if npts<100*100
        for ori=1:length(tuning);
            t(ori)=(tuning(ori)-spont(i))/(tuning_std(ori) /sqrt(ntrials));
            p(ori) = tcdf(t(ori),ntrials-1);
            p(ori) = 2*min(p(ori),1-p(ori));
        end
        minp(i) = min(p);
    else
        minp(i)=NaN;
    end
    
    if npts<=1000
        subplot(nfigs,nfigs,i)
        %  subplot(10,8,i-1)
        errorbar(1:length(tuning),tuning,tuning_std/sqrt(ntrials));
        hold on; plot([1 8],[spont(i) spont(i)],'g');
        ylim(1.1*[-2 max(max(tuning),2)]); xlim([0 9])
        set(gca,'Xtick',[]); set(gca,'Ytick',[]);
        
        %title(sprintf('%0.2f %0.2f',minp(i)*length(angles),osi(i)));
    end
    
% end

resp = evoked-base;
