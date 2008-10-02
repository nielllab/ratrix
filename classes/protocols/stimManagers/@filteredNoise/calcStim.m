function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)

LUT=makeStandardLUT(LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if hz==0
    if ismac
        hz=60; %assume laptop lcd
    else
        error('got 0 hz on non-mac')
    end
end

type='loop';

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
if ~isempty(trialRecords)
    lastRec=trialRecords(end);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts);

empties=cellfun(@isempty,stimulus.orientations);
if empties(targetPorts)
    targetPorts
    stimulus.orientations
    error('targetPorts includes members that have no entry')
end

if isempty(stimulus.cache)
    stimulus=computeFilteredNoise(stimulus,hz);
    updateSM=true;
else
    updateSM=false;
end

if isscalar(targetPorts)
    pre=stimulus.cache{targetPorts};
else
    error('targetPorts not scalar')
end

details.orientation=stimulus.orientations{targetPorts};
details.location=computeLocation(stimulus);

detailFields={'background','contrast','maskRadius','patchHeight','patchWidth','kernelSize','kernelDuration','loopDuration','ratio','filterStrength','bound'};
for i=1:length(detailFields)
    details.(detailFields{i})=stimulus.(detailFields{i});
end

details.startFrame=ceil(rand*size(pre,3));
pre=pre(:,:,[details.startFrame:size(pre,3) 1:details.startFrame-1]);

%width=80;
%height=60;
%stimulus.maskRadius=.03;
%details.location=[.75 2/3];

d=sqrt(sum([height width].^2));
[a b]=meshgrid(1:width,1:height);
mask=reshape(mvnpdf([a(:) b(:)],[width height].*details.location,(stimulus.maskRadius*d)^2*eye(2)),height,width);
mask=mask/max(mask(:));

%stimulus.patchHeight=.3;
%stimulus.patchWidth=.2;
%pre=rand(9,4,4);

h=size(pre,1);
w=size(pre,2);
out=zeros(round(h/stimulus.patchHeight),round(w/stimulus.patchWidth),size(pre,3));
rinds=ceil(size(out,1)*details.location(2)+[1:h]-(h+1)/2);
cinds=ceil(size(out,2)*details.location(1)+[1:w]-(w+1)/2);
rbad = rinds<=0 | rinds > size(out,1);
cbad = cinds<=0 | cinds > size(out,2);

out(rinds(~rbad),cinds(~cbad),:)=pre(~rbad,~cbad,:);
size(out)
height
width
out=imresize(out,[height width],'nearest');

out=stimulus.contrast*out.*mask(:,:,ones(1,size(pre,3)))+stimulus.background;
out(out<0)=0;
out(out>1)=1;
%out=uint8(double(intmax('uint8'))*out);
% 
% close all
% for i=1:size(pre,3)
%     figure
%     imagesc(out(:,:,i))
%     axis image
% end


% in.orientations               cell of orientations, one for each correct answer port, in radians, 0 is vertical, positive is clockwise  ex: {-pi/4 [] pi/4}
% in.locationDistributions      cell of 2-d densities, one for each correct answer port, will be normalized to stim area  ex: {[2d] [] [2d]}
%
% in.background                 0-1, normalized
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area
%
% in.patchHeight                0-1, normalized to diagonal of stim area
% in.patchWidth                 0-1, normalized to diagonal of stim area
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound
%
% in.cache

if details.correctionTrial;
    text='correction trial!';
else
    text=sprintf('target: %d',targetPorts);
end