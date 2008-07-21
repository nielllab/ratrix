function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =... 
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)

LUT=makeStandardLUT(LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

type='static';

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = uint8(intmax('uint8')*getInterTrialLuminance(stimulus));

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
if size(ims,1)~=length(responsePorts)
    trialManagerClass
    size(ims)
    responsePorts
    size(trialRecords)
    error('stim distribution specifies an entry that has different number of images than length of responsePorts')
end


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


%randomly assign distractors
inds=2:length(responsePorts);
[garbage order]=sort(rand(1,length(responsePorts)-1));
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

if details.correctionTrial;
    text='correction trial!';
else
    d=getDist(stimulus);
    text=sprintf('trial type %d (%g%%) (%s)',ind,round(100*d(ind)),fileNames);
end