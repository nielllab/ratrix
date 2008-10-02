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

detailFields={'background','contrast','maskRadius','patchHeight','patchDims','patchWidth','kernelSize','kernelDuration','loopDuration','ratio','filterStrength','bound'};
for i=1:length(detailFields)
    details.(detailFields{i})=stimulus.(detailFields{i});
end

details.startFrame=ceil(rand*size(pre,3));
pre=pre(:,:,[details.startFrame:size(pre,3) 1:details.startFrame-1]);

h=size(pre,1);
w=size(pre,2);
out=zeros(round(h/stimulus.patchHeight),round(w/stimulus.patchWidth),size(pre,3));
rinds=ceil(size(out,1)*details.location(2)+[1:h]-(h+1)/2);
cinds=ceil(size(out,2)*details.location(1)+[1:w]-(w+1)/2);
rbad = rinds<=0 | rinds > size(out,1);
cbad = cinds<=0 | cinds > size(out,2);

out(rinds(~rbad),cinds(~cbad),:)=pre(~rbad,~cbad,:);

width=size(out,2);
height=size(out,1);
d=sqrt(sum([height width].^2));
[a b]=meshgrid(1:width,1:height);
mask=reshape(mvnpdf([a(:) b(:)],[width height].*details.location,(stimulus.maskRadius*d)^2*eye(2)),height,width);
mask=mask/max(mask(:));

%out=imresize(out,[height width],'nearest');

out=stimulus.contrast*out.*mask(:,:,ones(1,size(pre,3)))+stimulus.background;
out(out<0)=0;
out(out>1)=1;
%out=uint8(double(intmax('uint8'))*out);

if details.correctionTrial;
    text='correction trial!';
else
    text=sprintf('target: %d',targetPorts);
end