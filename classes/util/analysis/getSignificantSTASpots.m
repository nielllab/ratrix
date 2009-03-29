function [bigSpots2D significantPixels2D sigSpots3D]=getSignificantSTASpots(sta,spikeCount,stimMean,contrast,medianFilter,atLeastNpixels,alpha);
%     getSignificantSTASpots(sta,spikeCount,stimMean=empiricMean, contrast=1,medianFilter=logical(ones(3)),atLeastNPixels=3,alpha=.05);
% sigSpots2D labels of the spots that are siginifcant in the time slice.
% 0= not signifcant
% 1= belongs to group 1
% 2= belongs to group 2... etc
% with the most significant pixels
% sig spots3D is returned but might not be used yet by any users,
% it contains the labels for each 2D processed time slice.  spot #1:N in time slice t
% do NOT have unique values across time slices (ie. there are many ID==1's)
% and may or may not be contiguous in space-time.

if ~exist('contrast','var') || isempty(contrast)
    contrast=1;
end

if ~exist('medianFilter','var') || isempty(medianFilter)
    medianFilter=logical(ones(3));
else
    if all(size(medianFilter)~=[3 3])
        error('must be defined by local 2D neighborhood')
    end
end

if ~exist('alpha','var') || isempty(alpha)
    alpha=.05;
end

if ~exist('stimMean','var') || isempty(stimMean)
    stimMean=mean(sta(:));
    warning('the empiric mean is only a crude estimate, it will be wrong if there is an asymetric-luminance receptive field present')
end

nullStd=contrast/sqrt(spikeCount);
delta=abs((sta-stimMean)/nullStd);
significantPixels = delta > norminv(1-alpha/2);

midpoint=ceil(length(medianFilter(:))/2);
sigSpots3D=nan(size(sta));
bigSpots2D = zeros(size(sta,1),size(sta,2));
filtered=nan(size(sta));
T=size(sta,3);
for t=1:T
    filtered(:,:,t) = ordfilt2(significantPixels(:,:,t),midpoint,medianFilter);
    [sigSpots3D(:,:,t) numSpots] = bwlabel(filtered(:,:,t),8); % use 8-connected (count 2D diagonal connections)
end

% connect in 3D
%[sigSpots3D numSpots] =bwlabeln(filtered,26); % use 26-connected (count 3D diagonal connections)

%num significant pixels per time step
sigPixels=reshape(sum(sum(sigSpots3D,1), 2),T,[]);

%push to 2D
%only earliest time if there is a tie for the max number of significant pixels
whichTime=find(sigPixels==max(sigPixels));
sigSpots2D=sigSpots3D(:,:,whichTime(1));
significantPixels2D=significantPixels(:,:,whichTime(1));
bigs = bwareaopen(sigSpots2D,atLeastNpixels);
bigSpots2D(bigs)=sigSpots2D(bigs);

view=2;
if view
    x=bigSpots2D;
    x(bigs)=x(bigs)+20;
    imagesc(x-(sigSpots2D>0)*20);
end

end

function validateSignificance()
frames=20000;
sz=30;
contrast=1;
stimMean=0;

rf=fspecial('gauss',sz,sz/6);
halfLoc=zeros(sz);
halfLoc(1:sz/2,:)=1; halfLoc=halfLoc==1;
rf(halfLoc)=0;
numHalfSamps=(sz^2)/2;
stim=stimMean+randn(sz,sz,frames)*contrast;
temp=repmat(rf,[1,1,frames]).*stim;
gen=reshape(sum(sum(temp,2),1),1,[]);
spikes=find(gen>mean(gen)+std(gen));
spikeCount=length(spikes)

faRate=[];
numSpikes=floor(linspace(500,frames/8,3));
alphas=linspace(.01,.1,40);
figure(1)
colors=jet(length(numSpikes));
for i=1:length(numSpikes)
    sta=mean(stim(:,:,spikes(1:numSpikes(i))),3);
    nullStd=contrast/sqrt(numSpikes(i)); % double check this
    delta=abs((sta-stimMean)/nullStd);
    
    for j=1:length(alphas)
        alpha=alphas(j);
        %significant = zscore > (1 - alpha);
        significant = delta > norminv(1-alpha/2);
        faRate(i,j)=sum(sum(significant(1:sz/2,:)))/numHalfSamps;
        hitRate(i,j)=sum(sum(significant(sz/2+1:end,:)))/numHalfSamps;
    end
    plot(alphas,faRate(i,:),'color',colors(i,:)); hold on
    %plot(alphas,hitRate(i,:),'color',[0 0 0]); hold on
    axis([0 max(alphas) 0 max(alphas)])
    plot([0 max(alphas)],[0 max(alphas)],'k')
    
    
    
end

figure(2); hist(zscore(:),200)
subplot(2, 2, 1); hist(rf(:),200)
subplot(2, 2, 2); hist(significant(:),200)
subplot(2, 2, 3); hist(delta(:),200)
subplot(2, 2, 4); hist(zscore(:),200)
figure(3);
subplot(2, 2, 1); imagesc(rf); colormap(gray); colorbar
subplot(2, 2, 2); imagesc(significant); colormap(gray); colorbar
subplot(2, 2, 3); imagesc(delta); colormap(gray); colorbar
subplot(2, 2, 4); imagesc(zscore); colormap(gray); colorbar
end
