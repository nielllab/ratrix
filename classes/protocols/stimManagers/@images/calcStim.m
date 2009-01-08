function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =... 
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)

LUT=makeStandardLUT(LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

% type='static';
% type='expert';
type = stimulus.drawingMode; % 12/9/08 - user can specify to use 'static' (default) or 'expert' mode (optional)

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = uint8(intmax('uint8')*getInterTrialLuminance(stimulus));

% 12/8/08 - randomly draw from size and rotation; store values into selectedSize and selectedRotation, and also write to details
% goes hand in hand with dynamic mode for doing the rotation and scaling
% 12/15/08 - moved up here so that these values can get sent to checkImages->prepareImages (for static mode rotation/scaling)
if stimulus.sizeyoked
    stimulus.selectedSizes = repmat(stimulus.size(1) + rand(1)*(stimulus.size(2)-stimulus.size(1)),1,totalPorts);
else
    % draw a random size for every image
    stimulus.selectedSizes=zeros(1,totalPorts);
    for i=1:totalPorts
        stimulus.selectedSizes(i) = stimulus.size(1) + rand(1)*(stimulus.size(2)-stimulus.size(1));
    end
end
stimulus.selectedRotation = round(stimulus.rotation(1) + rand(1)*(stimulus.rotation(2)-stimulus.rotation(1)));

%from PR: how to get this passed to calcstim as user defined param?
%response from edf: add fields to the class (in its constructor)
normalizeHistograms=false;
pctScreenFill=0.75;
backgroundcolor=uint8(intmax('uint8')*stimulus.background);
ind=min(find(rand<cumsum(getDist(stimulus)))); %draw from trialDistribution
[stimulus updateSM ims]=checkImages(stimulus,uint8(ind),backgroundcolor, pctScreenFill, normalizeHistograms,width,height);

%ims comes back as a nX2 cell array, where n is number of images specified in the trialDistribution entry we requested
%ims{:,1} is the image data, ims{:,2} are details (like the file name)

if strcmp(trialManagerClass,'freeDrinks') && size(ims,1)==length(responsePorts)-1
    responsePorts=responsePorts(1:end-1); %free drinks trial will have one extra response port
end
%12/9/08 - remove this error check to allow selection of random images for each distractor
% if size(ims,1)~=length(responsePorts)
%     trialManagerClass
%     size(ims)
%     responsePorts
%     size(trialRecords)
%     error('stim distribution specifies an entry that has different number of images than length of responsePorts')
% end


details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
if ~isempty(trialRecords)
    lastRec=trialRecords(end);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts);

%assign the correct answer to the target port (defined to be first file listed in the trialDistribution entry)
pics=cell(totalPorts,2);
pics(targetPorts,:)={ims{1,:}}; %note the ROUND parens -- ugly!

% 12/9/08 - check that we have enough ims in our trialDistribution for the number of distractor ports
if size(ims,1)<length(distractorPorts)
    error('trialDistribution has fewer entries than distractor ports')
end 

%randomly assign distractors
% inds=2:length(responsePorts);
% [garbage order]=sort(rand(1,length(responsePorts)-1));
% changed 12/9/08 - select n random distractor images from imagelist, where n = number of distractor ports
inds=2:size(ims,1);
[garbage order]=sort(rand(1,size(ims,1)-1)); 
inds=inds(order);

for i=1:length(distractorPorts)
    dp=distractorPorts(i);
    pics(dp,:)={ims{inds(end),:}};
    inds=inds(1:end-1);
end

out = [pics{:,1}];
details.imageDetails={pics{:,2}};

fileNames='';
for i=1:length(details.imageDetails)
    if ~isempty(details.imageDetails{i})
        fileNames=[fileNames details.imageDetails{i}.name ' '];
    end
end




details.size=stimulus.size;
details.rotation=stimulus.rotation;
details.selectedSizes=stimulus.selectedSizes;
details.selectedRotation=stimulus.selectedRotation;
details.sizeyoked=stimulus.sizeyoked;

details.trialDistribution = stimulus.trialDistribution;

% testing
horiz_ind = 1;
for i=1:size(pics,1)
    if ~isempty(pics{i,1})
        pics{i,2}=[horiz_ind horiz_ind+size(pics{i,1},2)-1];
        horiz_ind=horiz_ind+size(pics{i,1},2);
    end
end
stimulus.images=pics;
% details.images=stimulus.images; % dont store full image - takes up too much space

if details.correctionTrial;
    text='correction trial!';
else
    d=getDist(stimulus);
    text=sprintf('trial type %d (%g%%) (%s)',ind,round(100*d(ind)),fileNames);
end