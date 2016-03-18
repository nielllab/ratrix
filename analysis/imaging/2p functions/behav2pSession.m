%%% create session file for behavioral run
%%% reads raw images, calculates dfof, and aligns to stim sync

clear all

dt = 0.25; %%% resampled time frame
framerate=1/dt;
cycLength=10;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=4;  %%% configuration parameters
get2pSession_sbx;

if ~exist('onsets','var')

    [bf bp] = uigetfile('*.mat','behav permanent trial record');
    [onsets starts trialRecs] = sync2pBehavior_sbx(fullfile(bp,bf) ,phasetimes);
    save(sessionName,'onsets','starts','trialRecs','-append');
end

display('aligning frames')
tic
if ~exist('mapalign','var')
    timepts = -1:0.25:2;
    mapalign = align2onsets(dfofInterp,onsets,dt,timepts);
    display('saving')
    save(sessionName,'timepts','mapalign','-append')
end
toc

%%% get target location, orientation, phase
stim = [trialRecs.stimDetails];
targ = sign([stim.target]);
for i = 1:length(trialRecs);
    orient(i) = trialRecs(i).stimDetails.subDetails.orientations;
    gratingPh(i) = trialRecs(i).stimDetails.subDetails.phases;
end

%%% get correct
s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1;

figure
for t = 1:3
    if t==1
        dfmean = mean(mapalign(:,:,:,targ==-1),4);
    elseif t==2
        dfmean = mean(mapalign(:,:,:,targ==1),4);
    else
        dfmean = mean(mapalign(:,:,:,targ==-1),4) -mean(mapalign(:,:,:,targ==1),4) ;
    end
    %mn = mean(dfmean,3);
    mn = min(dfmean,[],3);
    figure
    for i = 1:13;
        subplot(4,4,i);
        if t<3
            imagesc(dfmean(:,:,i)-mn,[0 0.1]);
        else
            imagesc(dfmean(:,:,i),[-0.1 0.1]);
        end
        axis equal; axis off
    end
    
end
