% this script runs a quick test for topox or topoy to get cycavg and
% fourier map

%%add pixel-wise, thresholded histogram of phase

% %%% reads raw images, calculates dfof, and aligns to stim sync
close all; clear all
fileName = uigetfile('*.sbx','spotTest file');

dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=10;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters
cfg.syncToVid=1; cfg.saveDF=0; cfg.alignData=0;
sessionName = 'spot';
get2pSession_sbx;

nframes = min(size(dfofInterp,3),3000);  %%% limit topoY data to 5mins to avoid movie boundaries
dfofInterp = dfofInterp(:,:,1:nframes);

xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
% moviefname = 'C:\sizeSelect2sf8sz26min.mat';
moviefname = 'C:\sizeTest.mat'
load(moviefname)
ntrials= min(dt*length(dfofInterp)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dfofInterp,onsets,dt,timepts);
timepts = timepts - isi;
timepts = round(timepts*1000)/1000;
sbxfilename = fileName;
meandfofInterp = squeeze(mean(mean(dfofInterp,1),2))';

sz = unique(radius);
freq = unique(sf);
x=unique(xpos);
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)); end


frmdata = nan(size(dFout,1),size(dFout,2),length(sz));
for s = 1:length(sz);
        frmdata(:,:,s) = nanmean(nanmean(dFout(:,:,9:11,radius==sz(s)),4),3)-...
            nanmean(nanmean(dFout(:,:,1:4,radius==sz(s)),4),3);
end

figure;
colormap jet
subplot(1,3,1)
imagesc(frmdata(:,:,1),[-0.01 0.1])
set(gca,'ytick',[],'xtick',[])
axis square
xlabel('5deg')
subplot(1,3,2)
imagesc(frmdata(:,:,2),[-0.01 0.1])
set(gca,'ytick',[],'xtick',[])
axis square
xlabel('10deg')
subplot(1,3,3)
imagesc(frmdata(:,:,3),[-0.01 0.1])
set(gca,'ytick',[],'xtick',[])
axis square
xlabel('50deg')


