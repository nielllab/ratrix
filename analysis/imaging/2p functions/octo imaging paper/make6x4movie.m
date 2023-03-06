clear all
Opt.Resample_dt = 0.1;



dt = 0.1;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
cfg.syncToVid=0; cfg.saveDF=0;

sessionName=0; %%% don't save session data itself
if isfield(Opt,'fSbx')
    fileName = fullfile(Opt.pSbx,Opt.fSbx);
end


get2pSession_sbx;

F = (1 + dfofInterp).*repmat(meanImg,[1 1 size(dfofInterp,3)]);


Fbin = imresize(F,0.5,'box');
Fbin = Fbin(1:180,20:184,:);

stimTimes = vidframetimes;   %%% we call them phasetimes in behavior, but better to call it stimTimes here
startFrame = round((stimTimes(1))/dt);
stimFrames = round(stimTimes/dt);

cycLength = median(diff(vidframetimes))/dt;

if ~isfield(Opt,'fStim')
    %Get tif file input
    [Opt.fStim, Opt.pStim] = uigetfile('*.mat','stimulus record');
end

%%% need to figure out whether to trim off beginning
load(fullfile(Opt.pStim,Opt.fStim),'stimRec','freq','orient');
alignRecs =1;
%nCycles = floor(size(dfofInterp,3)/cycLength)-ceil((cycWindow-cycLength)/cycLength)-2;  %%% trim off last stims to allow window for previous stim
nCycles  = length(stimTimes);
stimT = stimRec.ts - stimRec.ts(1);
for i = 1:length(stimRec.cond)
    if stimRec.cond(i) == 0
        stimRec.cond(i) = pastCond;
    else
        pastCond = stimRec.cond(i);
    end
end


for i = 1:nCycles
    stimOrder(i) = stimRec.cond(min(find(stimT>((i-1)*cycLength*dt+0.1))));
end

stim= zeros(4,6,length(stimOrder));
for i = 1:length(stimOrder)
    if stimOrder(i)<=24
        loc = stimOrder(i);
        luminance=-1;
    else
        luminance=1;
        loc = stimOrder(i)-24;
    end
    x = ceil(loc/4);
    y = mod(loc-1,4)+1;
    stim(y,x,i) = luminance;
end


d = Fbin(5:5:end,5:5:end,5:5:end);
figure
hist(d(:),100);
lb = 0.5*prctile(d(:),1); ub = 1.5*prctile(d(:),99.9);
stimmag = 6;
%
clear mov
stimFrames = stimFrames(1:length(stimOrder));
for f = 1:size(F,3);
    
    im = mat2im(Fbin(:,:,f),gray, [lb, ub]);
    if f<startFrame
        st= zeros(4,6);
    else st=stim(:,:,max(find(stimFrames<=f)));
    end
    im(1:4*stimmag,(end-6*stimmag) + (1:6*stimmag),:) = mat2im(imresize(st,stimmag,'box'),gray,[-1 1]);
    mov(:,:,f) = im(:,:,1);
end


vid = VideoWriter(['100719_6x4_acq20_stim.avi'],'Grayscale AVI');
open(vid);
writeVideo(vid,mov);
close(vid)



