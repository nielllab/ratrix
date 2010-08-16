function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData,LFPRecord)
% stimManager is the stimulus manager
% spikes is an index into neural data samples of the time of a spike
% correctedFrameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain
% all the information needed to reconstruct stimData)
% plotParameters - currently not used

%initalize analysisdata
analysisdata.analysisdone = false;

% processed clusters and spikes
theseSpikes = logical(spikeRecord.processedClusters);
spikesThis=spikeRecord.spikes(theseSpikes);
spikeWaveformsThis = spikeRecord.spikeWaveforms(theseSpikes,:);
spikeTimestampsThis = spikeRecord.spikeTimestamps(theseSpikes);

%SET UP RELATION stimInd <--> frameInd
numStimFramesThis=max(spikeRecord.stimInds);
analyzeDrops=true;
if analyzeDrops
    stimFramesThis=spikeRecord.stimInds;
    correctedFrameIndicesThis=spikeRecord.correctedFrameIndices;
else
    stimFramesThis=1:numStimFrames;
    firstFramePerStimIndThis=~[0 diff(spikeRecord.stimInds)==0];
    correctedFrameIndicesThis=spikeRecord.correctedFrameIndices(firstFramePerStimInd);
end

trialsThis = repmat(parameters.trialNumber,length(stimFramesThis),1);
if ~isfield(stimulusDetails,'method')
    mode = {'ordered',[]};
else
    mode = {stimulusDetails.method,stimulusDetails.seed};
end
% get the stimulusCombo
if stimulusDetails.doCombos==1
    comboMatrix = generateFactorialCombo({stimulusDetails.spatialFrequencies,stimulusDetails.frequencies,stimulusDetails.orientations,...
        stimulusDetails.contrasts,stimulusDetails.startPhases,stimulusDetails.durations,stimulusDetails.radii,stimulusDetails.annuli},[],[],mode);
    pixPerCycsThis=comboMatrix(1,:);
    driftfrequenciesThis=comboMatrix(2,:);
    orientationsThis=comboMatrix(3,:);
    contrastsThis=comboMatrix(4,:); %starting phases in radians
    startPhasesThis=comboMatrix(5,:);
    durationsThis=round(comboMatrix(6,:)*parameters.refreshRate); % CONVERTED FROM seconds to frames
    radiiThis=comboMatrix(7,:);
    annuliThis=comboMatrix(8,:);
    
    repeatThis=ceil(stimFramesThis/sum(durationsThis));
    numRepeatsThis=ceil(numStimFramesThis/sum(durationsThis));
    chunkEndFrameThis=[cumsum(repmat(durationsThis,1,numRepeatsThis))];
    chunkStartFrameThis=[0 chunkEndFrameThis(1:end-1)]+1;
    chunkStartFrameThis = chunkStartFrameThis';
    chunkEndFrameThis = chunkEndFrameThis';
    %chunkStartFrame(chunkStartFrame>numStimFrames)=[]; %remove chunks that were never reached. OK TO LEAVE IF WE INDEX BY OTHER THINGS
    %chunkEndFrame(chunkStartFrame>numStimFrames)=[]; %remove chunks that were never reached.
    numChunksThis=length(chunkStartFrameThis);
    trialsByChunkThis = repmat(parameters.trialNumber,numChunksThis,1);
    numTypesThis=length(durationsThis);   
else
    error('analysis not handled yet for this case')
end

numValsPerParamThis=...
    [length(unique(pixPerCycsThis)) length(unique(driftfrequenciesThis))  length(unique(orientationsThis))  length(unique(contrastsThis)) length(unique(startPhasesThis)) length(unique(durationsThis))  length(unique(radiiThis))  length(unique(annuliThis))];
if sum(numValsPerParamThis>1)==1
    names={'pixPerCycs','driftfrequencies','orientations','contrasts','startPhases','durations','radii','annuli'};
    sweptParameterThis=names(find(numValsPerParamThis>1));
else
    error('analysis only for one value at a time now')
    return % to skip
end

valsThis = eval(sprintf('%s%s',char(sweptParameterThis),'This'));

% durations of each condition should be unique
if length(unique(durationsThis))==1
    durationThis=unique(durationsThis);
    typesThis=repmat([1:numTypesThis],durationThis,numRepeatsThis);
    typesThis=typesThis(stimFramesThis); % vectorize matrix and remove extras
else
    error('multiple durations can''t rely on mod to determine the frame type')
end

samplingRate=parameters.samplingRate;

% calc phase per frame, just like dynamic
xThis = 2*pi./pixPerCycsThis(typesThis); % adjust phase for spatial frequency, using pixel=1 which is likely always offscreen, given roation and oversizeness
cycsPerFrameVelThis = driftfrequenciesThis(typesThis)*1/(parameters.refreshRate); % in units of cycles/frame
offsetThis = 2*pi*cycsPerFrameVelThis.*stimFramesThis';
risingPhasesThis=xThis + offsetThis+startPhasesThis(typesThis);
phasesThis=mod(risingPhasesThis,2*pi); phasesThis = phasesThis';

% count the number of spikes per frame
% spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames
spikeCountThis=zeros(size(correctedFrameIndicesThis,1),1);
for i=1:length(spikeCountThis) % for each frame
    spikeCountThis(i)=length(find(spikesThis>=correctedFrameIndicesThis(i,1)&spikesThis<=correctedFrameIndicesThis(i,2))); % inclusive?  policy: include start & stop
end

% always analyze on all the data!
if ~isfield(cumulativedata,'trialNumber')
    trialNumbers = parameters.trialNumber;
    cumulativedata.trialNumber = parameters.trialNumber;
else
    trialNumbers = [cumulativedata.trialNumber parameters.trialNumber];
    cumulativedata.trialNumber = parameters.trialNumber;
end

stimInfo.pixPerCycs = pixPerCycsThis;
stimInfo.driftfrequencies = driftfrequenciesThis;
stimInfo.orientations = orientationsThis;
stimInfo.contrasts = contrastsThis;
stimInfo.startPhases = startPhasesThis;
stimInfo.durations = durationsThis;
stimInfo.radii = radiiThis;
stimInfo.annuli = annuliThis;
stimInfo.numRepeats = numRepeatsThis;
stimInfo.numTypes = numTypesThis;
stimInfo.vals = valsThis;
stimInfo.sweptParameter = sweptParameterThis;

if ~isfield(cumulativedata,'stimInfo')
    cumulativedata.stimInfo = stimInfo;
else
    if ~isequal(cumulativedata.stimInfo,stimInfo)
        warning('something fishy going on here');
        analysisdata = [];
        return
    end
end

numTrials = length(trialNumbers);

numPhaseBins=8;
edges=linspace(0,2*pi,numPhaseBins+1);
events=zeros(numRepeatsThis,numTypesThis,numPhaseBins);
eventsThis=events;
possibleEvents=events;
possibleEventsThis = eventsThis;
phaseDensity=zeros(numRepeatsThis*numTypesThis,numPhaseBins);
phaseDensityThis=zeros(numRepeatsThis*numTypesThis,numPhaseBins);
pow=nan(numRepeatsThis,numTypesThis);
powThis = pow;

[chunkStartFrame chunkEndFrame trialsByChunk...
    stimFrames spikeCount phases types repeat trials cumulativedata]...
    = getCompleteRecords(chunkStartFrameThis, chunkEndFrameThis, trialsByChunkThis,...
    stimFramesThis,spikeCountThis,phasesThis,typesThis, repeatThis,trialsThis,cumulativedata);

for i=1:numRepeatsThis
    for j=1:numTypesThis
        whichType=find(types==j & repeat==i);
        whichTypeThis = find(trials==parameters.trialNumber & types==j & repeat==i);
        if length(whichType)>5  % need some spikes, 2 would work mathematically ??is this maybe spikeCount(whichType)
            [n phaseID]=histc(phases(whichType),edges);
            [nThis phaseIDThis] = histc(phases(whichTypeThis),edges);
            for k=1:numPhaseBins
                whichPhase=find(phaseID==k);
                whichPhaseThis = find(phaseIDThis==k);
                events(i,j,k)=sum(spikeCount(whichType(whichPhase)));
                eventsThis(i,j,k)=sum(spikeCount(whichTypeThis(whichPhaseThis)));
                possibleEvents(i,j,k)=length(whichPhase);
                possibleEventsThis(i,j,k)=length(whichPhaseThis);
                
                %in last repeat density = 0, for parsing and avoiding misleading half data
                if 1 %numRepeats~=i
                    y=(j-1)*(numRepeatsThis)+i;
                    phaseDensity(y,k)=events(i,j,k)/possibleEvents(i,j,k);
                    phaseDensityThis(y,k)=eventsThis(i,j,k)/possibleEventsThis(i,j,k);
                end
            end
            
            % find the power in the spikes at the freq of the grating
            fy=fft(.5+cos(phases(whichType))/2); %fourier of stim
            fx=fft(spikeCount(whichType)); % fourier of spikes
            fy=abs(fy(2:floor(length(fy)/2))); % get rid of DC and symetry
            fx=abs(fx(2:floor(length(fx)/2)));
            peakFreqInd=find(fy==max(fy)); % find the right freq index using stim
            pow(i,j)=fx(peakFreqInd); % determine the power at that freq
            
            % find the power in the spikes at the freq of the grating
            fyThis=fft(.5+cos(phases(whichTypeThis))/2); %fourier of stim
            fxThis=fft(spikeCount(whichTypeThis)); % fourier of spikes
            fyThis=abs(fyThis(2:floor(length(fyThis)/2))); % get rid of DC and symetry
            fxThis=abs(fxThis(2:floor(length(fxThis)/2)));
            peakFreqIndThis=find(fyThis==max(fyThis)); % find the right freq index using stim
            powThis(i,j)=fx(peakFreqIndThis); % determine the power at that freq
            
            % coherency
            chrParam.tapers=[3 5]; % same as default, but turns off warning
            chrParam.err=[2 0.05];  % use 2 for jacknife
            fscorr=true;
            % should check chronux's chrParam,trialave=1 to see how to
            % handle CI's better.. will need to do all repeats at once
            [C,phi,S12,S1,S2,f,zerosp,confC,phistd,Cerr]=...
                coherencycpb(cos(phases(whichType)),spikeCount(whichType),chrParam,fscorr);
            [CThis,phiThis,S12This,S1This,S2This,fThis,zerospThis,confCThis,phistdThis,CerrThis]=...
                coherencycpb(cos(phases(whichTypeThis)),spikeCount(whichTypeThis),chrParam,fscorr);
            
            if ~zerosp
                peakFreqInds=find(S1>max(S1)*.95); % a couple bins near the peak of
                [junk maxFreqInd]=max(S1);
                coh(i,j)=mean(C(peakFreqInds));
                cohLB(i,j)=Cerr(1,maxFreqInd);
            else
                coh(i,j)=nan;
                cohLB(i,j)=nan;
            end
            
            if ~zerospThis
                peakFreqIndsThis=find(S1This>max(S1This)*.95); % a couple bins near the peak of
                [junk maxFreqIndThis]=max(S1This);
                cohThis(i,j)=mean(CThis(peakFreqIndsThis));
                cohLBThis(i,j)=Cerr(1,maxFreqIndThis);
            else
                cohThis(i,j)=nan;
                cohLBThis(i,j)=nan;
            end
            
        end
    end
end


%get eyeData for phase-eye analysis
if ~isempty(eyeData)
    [px py crx cry]=getPxyCRxy(eyeData,10);
    eyeSig=[crx-px cry-py];
    eyeSig(end,:)=[]; % remove last ones to match (not principled... what if we should throw out the first ones?)
    
    if length(unique(eyeSig(:,1)))>10 % if at least 10 x-positions
        
        regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
        [within ellipses]=selectDenseEyeRegions(eyeSig,1,regionBoundsXY);
        
        whichOne=0; % various things to look at
        switch whichOne
            case 0
                %do nothing
            case 1 % plot eye position and the clusters
                regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
                within=selectDenseEyeRegions(eyeSig,3,regionBoundsXY,true);
            case 2  % coded by phase
                [n phaseID]=histc(phases,edges);
                figure; hold on;
                phaseColor=jet(numPhaseBins);
                for i=1:numPhaseBins
                    plot(eyeSig(phaseID==i,1),eyeSig(phaseID==i,2),'.','color',phaseColor(i,:))
                end
            case 3
                density=hist3(eyeSig);
                imagesc(density)
            case 4
                eyeMotion=diff(eyeSig(:,1));
                mean(eyeMotion>0)/mean(eyeMotion<0);   % is close to 1 so little bias to drift and snap
                bound=3*std(eyeMotion(~isnan(eyeMotion)));
                motionEdges=linspace(-bound,bound,100);
                count=histc(eyeMotion,motionEdges);
                
                figure; bar(motionEdges,log(count),'histc'); ylabel('log(count)'); xlabel('eyeMotion (crx-px)''')
                
                figure; plot(phases',eyeMotion,'.'); % no motion per phase (more interesting for sqaure wave single freq)
        end
    else
        disp(sprintf('no good eyeData on trial %d',parameters.trialNumber))
    end
end




% events(events>possibleEvents)=possibleEvents % note: more than one spike could occur per frame, so not really binomial
% [pspike pspikeCI]=binofit(events,possibleEvents);

fullRate=events./possibleEvents;
fullRateThis = eventsThis./possibleEventsThis;
rate=reshape(sum(events,1)./sum(possibleEvents,1),numTypesThis,numPhaseBins); % combine repetitions
rateThis = reshape(sum(eventsThis,1)./sum(possibleEventsThis,1),numTypesThis,numPhaseBins);

[repInds typeInds]=find(isnan(pow));
[repIndsThis typeIndsThis] = find(isnan(powThis));

pow(unique(repInds),:)=[];   % remove reps with bad power estimates
coh(unique(repInds),:)=[];   % remove reps with bad power estimates
cohLB(unique(repInds),:)=[]; % remove reps with bad power estimates

powThis(unique(repIndsThis),:)=[];   % remove reps with bad power estimates
cohThis(unique(repIndsThis),:)=[];   % remove reps with bad power estimates
cohLBThis(unique(repIndsThis),:)=[]; % remove reps with bad power estimates

if numRepeatsThis>2
    rateSEM=reshape(std(events(1:end-1,:,:)./possibleEvents(1:end-1,:,:)),numTypesThis,numPhaseBins)/sqrt(numRepeatsThis-1);
    rateSEMThis=reshape(std(eventsThis(1:end-1,:,:)./possibleEventsThis(1:end-1,:,:)),numTypesThis,numPhaseBins)/sqrt(numRepeatsThis-1);
else
    rateSEM=nan(size(rate));
    rateSEMThis = nan(size(rate));
end

if size(pow,1)>1
    powSEM=std(pow)/sqrt(size(pow,1));
    pow=mean(pow);
    
    cohSEM=std(coh)/sqrt(size(coh,1));
    coh=mean(coh);
    cohLB=mean(cohLB);  % do you really want the mean of the lower bound?
else
    powSEM=nan(1,size(pow,2));
    cohSEM=nan(1,size(pow,2));
    cohLB_SEM=nan(1,size(pow,2));
end

if size(powThis,1)>1
    powSEMThis=std(powThis)/sqrt(size(powThis,1));
    powThis=mean(powThis);
    
    cohSEMThis=std(cohThis)/sqrt(size(cohThis,1));
    cohThis=mean(cohThis);
    cohLBThis=mean(cohLBThis);  % do you really want the mean of the lower bound?
else
    powSEMThis=nan(1,size(powThis,2));
    cohSEMThis=nan(1,size(powThis,2));
    cohLB_SEMThis=nan(1,size(powThis,2));
end

cumulativedata.numPhaseBins = numPhaseBins;
cumulativedata.phaseDensity = phaseDensity;
cumulativedata.pow = pow;
cumulativedata.coh = coh;
cumulativedata.cohLB = cohLB;
cumulativedata.rate = rate;
cumulativedata.rateSEM = rateSEM;
cumulativedata.powSEM = powSEM;
cumulativedata.cohSEM = cohSEM;
cumulativedata.cohLB = cohLB;
cumulativedata.ISIviolationMS = parameters.ISIviolationMS;
cumulativedata.eyeData = [];
cumulativedata.refreshRate = parameters.refreshRate;
cumulativedata.samplingRate = parameters.samplingRate;


if ~isfield(cumulativedata,'spikeWaveforms')
    cumulativedata.spikeWaveforms = spikeWaveformsThis;
    cumulativedata.spikeTimestamps = spikeTimestampsThis;
else
    cumulativedata.spikeWaveforms = [cumulativedata.spikeWaveforms;spikeWaveformsThis];
    cumulativedata.spikeTimestamps = [cumulativedata.spikeTimestamps;spikeTimestampsThis];
end
    
analysisdata.phaseDensity = phaseDensityThis;
analysisdata.pow = powThis;
analysisdata.coh = cohThis;
analysisdata.cohLB = cohLBThis;
analysisdata.rate = rateThis;
analysisdata.rateSEM = rateSEMThis;
analysisdata.powSEM = powSEMThis;
analysisdata.cohSEM = cohSEMThis;
analysisdata.cohLB = cohLBThis;
analysisdata.trialNumber = parameters.trialNumber;
analysisdata.ISIviolationMS = parameters.ISIviolationMS;
analysisdata.spikeWaveforms = spikeWaveformsThis;

end

function [chunkStartFrame chunkEndFrame trialsByChunk...
    stimFrames spikeCount phases type repeat trials cumulativedata]...
    = getCompleteRecords(chunkStartFrameThis, chunkEndFrameThis, trialsByChunkThis,...
    stimFramesThis,spikeCountThis,phasesThis,typeThis,repeatThis,trialsThis,cumulativedata)
if ~isfield(cumulativedata,'chunkStartFrame')
    chunkStartFrame = chunkStartFrameThis;
    chunkEndFrame = chunkEndFrameThis;
    trialsByChunk = trialsByChunkThis;
    stimFrames = stimFramesThis;
    spikeCount = spikeCountThis;
    phases = phasesThis;
    type = typeThis;
    repeat = repeatThis;
    trials = trialsThis;
    % update the cumulativedata
    cumulativedata.chunkStartFrame = chunkStartFrame;
    cumulativedata.chunkEndFrame = chunkEndFrame;
    cumulativedata.trialsByChunk = trialsByChunk;
    cumulativedata.stimFrames = stimFrames;
    cumulativedata.spikeCount = spikeCount;
    cumulativedata.phases = phases;
    cumulativedata.type = type;
    cumulativedata.repeat = repeat;
    cumulativedata.trials = trials;
else
    chunkStartFrame = [cumulativedata.chunkStartFrame; chunkStartFrameThis];
    chunkEndFrame = [cumulativedata.chunkEndFrame; chunkEndFrameThis];
    trialsByChunk = [cumulativedata.trialsByChunk; trialsByChunkThis];
    stimFrames = [cumulativedata.stimFrames; stimFramesThis];
    spikeCount = [cumulativedata.spikeCount; spikeCountThis];
    phases = [cumulativedata.phases; phasesThis];
    type = [cumulativedata.type; typeThis];
    repeat = [cumulativedata.repeat; repeatThis];
    trials = [cumulativedata.trials; trialsThis];
    % update the cumulativedata
    cumulativedata.chunkStartFrame = chunkStartFrame;
    cumulativedata.chunkEndFrame = chunkEndFrame;
    cumulativedata.trialsByChunk = trialsByChunk;
    cumulativedata.stimFrames = stimFrames;
    cumulativedata.spikeCount = spikeCount;
    cumulativedata.phases = phases;
    cumulativedata.type = type;
    cumulativedata.repeat = repeat;
    cumulativedata.trials = trials;
end

end
