function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
% 1/3/0/09 - trialRecords now includes THIS trial

if ~all(ismember([stimulus.port{:}],responsePorts))
    error('not all the expected correct response ports were available in responsePorts')
end

LUT=makeStandardLUT(LUTbits);

type='loop';

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
if ~isempty(trialRecords) && length(trialRecords)>=2
    lastRec=trialRecords(end-1);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass);

typeInd=find([stimulus.port{:}]==targetPorts);
if length(typeInd)==0
    error('no matching target port')
elseif length(typeInd)>1
    typeInd=typeInd(ceil(rand*length(typeInd))); %choose random type with matching port for this trial
end

if ~isempty(resolutions)
    [resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));
else
    resolutionIndex=stimulus.origHz{typeInd};
    height=1;
    width=1;
    hz=resolutionIndex;
end

if hz==0
    if ismac
        hz=60; %assume laptop lcd
    else
        error('got 0 hz on non-mac')
    end
end

need to call pickcontrast in gaussian computefilterednoise and clip top of hateren and figure out summing here

if isempty(stimulus.cache) || isempty(stimulus.hz) || stimulus.hz~=hz
    stimulus=computeFilteredNoise(stimulus,hz); %intent: stim always normalized
    updateSM=true;
else
    updateSM=false;
end


pre=stimulus.cache{typeInd};

details.hz=stimulus.hz;



detailFields={'distribution','startFrame','contrast','loopDuration','maskRadius','patchDims','patchHeight','patchWidth','background','orientation','kernelSize','kernelDuration','ratio','filterStrength','bound','inds','seed','sha1'};
for i=1:length(detailFields)
    details.(detailFields{i})=stimulus.(detailFields{i}){typeInd};
end

if ~isstruct(details.loopDuration)
    if strcmp(details.startFrame,'randomize')
        details.startFrame=ceil(rand*size(pre,3));
    end
    
    if details.startFrame>size(pre,3)
        details.startFrame
        size(pre)
        error('startFrame was too large')
    end
    pre=pre(:,:,[details.startFrame:size(pre,3) 1:details.startFrame-1]);
end

    h=size(pre,1);
    w=size(pre,2);

if ~isempty(resolutions)
    
    details.location=drawFrom2Ddist(stimulus.locationDistribution{typeInd});
    
    maxPositionalError=.01;
    
    %size(pre)
    %[details.patchHeight details.patchWidth]/maxPositionalError
    if false %out of memory for long stims
        if any([h/details.patchHeight w/details.patchWidth] < 1/maxPositionalError) %if pre's size is too small or the patch size is too large, positioning/sizing will be too coarse
            pre=imresize(pre,[details.patchHeight details.patchWidth]/maxPositionalError,'nearest');
            h=size(pre,1);
            w=size(pre,2);
        end
    end
    
    out=zeros(round(h/details.patchHeight),round(w/details.patchWidth),size(pre,3));
    rinds=ceil(size(out,1)*details.location(2)+[1:h]-(h+1)/2);
    cinds=ceil(size(out,2)*details.location(1)+[1:w]-(w+1)/2);
    rbad = rinds<=0 | rinds > size(out,1);
    cbad = cinds<=0 | cinds > size(out,2);
    
    out(rinds(~rbad),cinds(~cbad),:)=pre(~rbad,~cbad,:);
    
    width=size(out,2);
    height=size(out,1);
    d=sqrt(sum([height width].^2));
    [a b]=meshgrid(1:width,1:height);
    mask=reshape(mvnpdf([a(:) b(:)],[width height].*details.location,(details.maskRadius*d)^2*eye(2)),height,width);
    mask=mask/max(mask(:));
    
    out=details.contrast*out.*mask(:,:,ones(1,size(pre,3)))+details.background;
else
    if any([h w]~=1)
        error('LED only works with 1x1 output')
    end
    out=details.contrast*pre+details.background;
end

out(out<0)=0;
out(out>1)=1;
%out=uint8(double(intmax('uint8'))*out);

if details.correctionTrial;
    text='correction trial!';
else
    text=sprintf('target: %d',targetPorts);
end