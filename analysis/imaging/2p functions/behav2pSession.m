function behav2pSession( fileName, sessionName,behavfile,psfile)%%% create session file for behavioral run
%%% reads raw images, calculates dfof, and aligns to stim sync

dt = 0.1; %%% resampled time frame


framerate=1/dt;
cycLength=10;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  cfg.syncToVid = 0; cfg.saveDF=0;%%% configuration parameters
get2pSession_sbx;

if ~exist('onsets','var')
    if ~exist('behavfile','var')
        [bf bp] = uigetfile('*.mat','behav permanent trial record');
        behavfile = fullfile(bp,bf);
    end
    
    [onsets starts trialRecs] = sync2pBehavior_sbx(behavfile ,phasetimes);
    use = find(onsets<size(dfofInterp,3)*dt-3 & onsets>5); %%%% get rid of trials right at beginning or end, that may be incomplete
    %use = use(1:(length(use)-1))  %sometimes behavior session trial records has 1 xtra trial
    onsets = onsets(use); starts=starts(use,:); trialRecs = trialRecs(use);
    save(sessionName,'onsets','starts','trialRecs','-append');
end

figure
plot(squeeze(mean(mean(dfofInterp,2),1)));
ylabel('mean dF/F');
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

global info

figure
plot(info.aligned.T);
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

display('aligning frames')
tic
if ~exist('mapalign','var')
    timepts = -1:0.2:2;
    mapalign = align2onsets(dfofInterp,onsets,dt,timepts);
    display('saving')
    % save(sessionName,'timepts','mapalign','-append')
end
toc

figure
plot(timepts,squeeze((mean(mean(mean(mapalign,4),2),1))))

%keyboard

%%% get target location, orientation, phase
stim = [trialRecs.stimDetails];
stim = [trialRecs.stimDetails];
for i = 1:length(trialRecs);
    orient(i) = pi/2 - trialRecs(i).stimDetails.subDetails.orientations;
    gratingPh(i) = trialRecs(i).stimDetails.subDetails.phases;
    location(i) =  sign(trialRecs(i).stimDetails.subDetails.xPosPcts - 0.5);
    targ(i) = sign(stim(i).target);
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
        dfmean = mean(mapalign(:,:,:,location==-1),4);
    elseif t==2
        dfmean = mean(mapalign(:,:,:,location==1),4);
    else
        dfmean = mean(mapalign(:,:,:,location==-1),4) -mean(mapalign(:,:,:,location==1),4) ;
    end
    pixResp(:,:,:,t) = dfmean;
    %mn = mean(dfmean,3);
    % mn = min(dfmean,[],3);
    mn = dfmean(:,:,timepts==0);
    figure; set(gcf,'Name',labels{t})
    for i = 1:12;
        subplot(3,4,i);
        if t<3
            imagesc(dfmean(:,:,i+4)-mn,[-0.3 0.3]); colormap jet;
        else
            imagesc(dfmean(:,:,i+4),[-0.3 0.3]); colormap jet;
        end
        axis equal; axis off; set(gca,'LooseInset',get(gca,'TightInset')); title(sprintf('t = %0.2f',timepts(i+4)));
    end
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
end

sbxfilename = fileName;
save(sessionName,'pixResp','sbxfilename','-append');

top = squeeze(mean(mapalign(:,:,timepts==1,location==-1),4)) - squeeze(mean(mapalign(:,:,timepts==0,location==-1),4));
bottom =  squeeze(mean(mapalign(:,:,timepts==1,location==1),4)) - squeeze(mean(mapalign(:,:,timepts==0,location==1),4));

amp = meanImg-min(meanImg(:));
amp = amp/prctile(amp(:),99);
amp(amp>1)=1;
% topScaled = mat2im(top,jet,[-0.3 0.3]);
% bottomScaled = mat2im(bottom,jet,[-0.3 0.3]);
topScaled = mat2im(top,jet,[-0.3 0.3]).*repmat(amp,[1 1 3]);
bottomScaled = mat2im(bottom,jet,[-0.3 0.3]).*repmat(amp,[1 1 3]);

figure
subplot(1,2,1);
imshow(imresize(topScaled,2));
title('top')
subplot(1,2,2);
imshow(imresize(bottomScaled,2));
title('bottom')


if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
