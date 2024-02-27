%%% makes videos of 2p with sparse noise stimulus embedded
%%% for paper, used 100719_acq17


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

load('C:\data\octo_sparse_flash_10min.mat')
stim = imresize(moviedata,1/8);
stim = permute(stim,[2 1 3]);

d = Fbin(5:5:end,5:5:end,5:5:end);
figure
hist(d(:),100);
lb = 0.5*prctile(d(:),1); ub = 1.5*prctile(d(:),99.9);

%
clear mov
for f = 1:size(F,3);
%for f = 1:200;    
    im = mat2im(Fbin(:,:,f),gray, [lb, ub]);
    stimnum = max(find(stimFrames<=f));
    if stimnum>size(stim,3)
        break
    end
    if f<startFrame
        st= zeros(size(stim,1),size(stim,2))+127;
    else
        st=stim(:,:,stimnum);
    end
    im(1:size(stim,1),(end-size(stim,2)) + (1:size(stim,2)),:) = mat2im(st,gray,[0 255]);
    mov(:,:,f) = im(:,:,1);
end


vid = VideoWriter(['100719_acq17_sn_stim.avi'],'Grayscale AVI');
open(vid);
writeVideo(vid,mov);
close(vid)



