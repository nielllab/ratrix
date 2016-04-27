function behav2pSession( fileName, sessionName,behavfile,psfile)%%% create session file for behavioral run
%%% reads raw images, calculates dfof, and aligns to stim sync

dt = 0.1; %%% resampled time frame
framerate=1/dt;
cycLength=10;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters
get2pSession_sbx;

if ~exist('onsets','var')
    if ~exist('behavfile','var')
    [bf bp] = uigetfile('*.mat','behav permanent trial record');
    behavfile = fullfile(bp,bf);
    end
    
    [onsets starts trialRecs] = sync2pBehavior_sbx(behavfile ,phasetimes);
    use = find(onsets<size(dfofInterp,3)*dt-3 & onsets>5); %%%% get rid of trials right at beginning or end, that may be incomplete
    onsets = onsets(use); starts=starts(use,:); trialRecs = trialRecs(use);
    save(sessionName,'onsets','starts','trialRecs','-append');
end

figure
plot(squeeze(mean(mean(dfofInterp,2),1)))


display('aligning frames')
tic
if ~exist('mapalign','var')
    timepts = -1:0.25:2;
    mapalign = align2onsets(dfofInterp,onsets,dt,timepts);
    display('saving')
   % save(sessionName,'timepts','mapalign','-append')
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

labels = {'position -1','position 1','-1 vs 1'};
figure
for t = 1:3
    if t==1
        dfmean = mean(mapalign(:,:,:,targ==-1),4);
    elseif t==2
        dfmean = mean(mapalign(:,:,:,targ==1),4);
    else
        dfmean = mean(mapalign(:,:,:,targ==-1),4) -mean(mapalign(:,:,:,targ==1),4) ;
    end
    pixResp(:,:,:,t) = dfmean;
    %mn = mean(dfmean,3);
    % mn = min(dfmean,[],3);
    mn = dfmean(:,:,timepts==0);
    figure; set(gcf,'Name',labels{t})
    for i = 1:12;
        subplot(3,4,i);
        if t<3
            imagesc(dfmean(:,:,i+1)-mn,[-0.3 0.3]); colormap jet; 
        else
            imagesc(dfmean(:,:,i+1),[-0.3 0.3]); colormap jet; 
        end
        axis equal; axis off; set(gca,'LooseInset',get(gca,'TightInset'))
    end
    if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
    
end

save(sessionName,'pixResp','-append');
