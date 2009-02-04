function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =... 
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)

LUT=makeStandardLUT(LUTbits);
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

% type='static';
% type='expert';
type = stimulus.drawingMode; % 12/9/08 - user can specify to use 'static' (default) or 'expert' mode (optional)

% ====================================================================================
% if we are in deck mode, do card selection and checking
% else, just assign ind randomly based on the trialDistribution
if strcmp(stimulus.imageSelectionMode,'deck')
    numImages = length(getDist(stimulus));
    % 1/28/09 - fixed to correctly reset decksFinished counter at the start of a new trainingStep, because
    % this assumes that calcStim now receives ALL trialRecords instead of up to trialRecords(end-1)
    if length(trialRecords)>1
        if trialRecords(end).trainingStepNum ~= trialRecords(end-1).trainingStepNum % if this is the first trial of a new step
            % reset decksFinished to 0, cardsRemaining should be empty
            details.decksFinished=0;
            details.cardsRemaining=[];
        else % same step
            if isfield(trialRecords(end-1),'stimDetails') && isfield(trialRecords(end-1).stimDetails,'decksFinished') ...
                    && isfield(trialRecords(end-1).stimDetails,'cardsRemaining')
                details.decksFinished=trialRecords(end-1).stimDetails.decksFinished;
                details.cardsRemaining=trialRecords(end-1).stimDetails.cardsRemaining;
            else
                details.decksFinished=0;
                details.cardsRemaining=[];
            end
        end
    else
        % this is the first trial
        details.decksFinished=0;
        details.cardsRemaining=[];
    end

    % if cardsRemaining is empty, then generate a new deck - this only happens once during initialization
    if isempty(details.cardsRemaining)
        details.cardsRemaining=randperm(numImages);
    elseif length(details.cardsRemaining) == 1
        % because we remove the last card, and then check and increment decksFinished
        % - now, we will draw the last card from a deck in trial N, and move on to trial N+1 without incrementing decksFinished
        % when we get to trial N+1, this will catch that the deck only has one card and then increment decksFinished and reshuffle a new deck
        % if only card left is the exemplar
        details.cardsRemaining = randperm(numImages);
        % this means we finished a deck - store this in details
        details.decksFinished = details.decksFinished + 1; % - we can use this to check graduation criteria

        %     finishedADeck = true;
        %     break
    end

    % how to draw from distribution? - two step process
    % first draw from full trialDistribution to decide exemplar/morph
    % then, if morph - if morph card still remaining, use it, otherwise select a random morph card from deck
    indFromTrialDistribution=min(find(rand<cumsum(getDist(stimulus)))); %draw from trialDistribution
    if indFromTrialDistribution ~= 1 % if this is not exemplar
        % check if morph card remains
        if ~isempty(find(details.cardsRemaining == indFromTrialDistribution))
            indOfCardsLeft = find(details.cardsRemaining == indFromTrialDistribution);
        else
            % morph card already used, pick a random one - MAKE SURE YOU DONT PICK EXEMPLAR
            exemplarIndex = find(details.cardsRemaining == 1);
            indOfCardsLeft = exemplarIndex;
            while (indOfCardsLeft == exemplarIndex || indOfCardsLeft == 0) % keep picking randomly until you hit a morph
                indOfCardsLeft=round(rand*length(details.cardsRemaining));
            end
        end
        % pick the correct element from cardsLeft, and remove it from the stim manager
        ind = details.cardsRemaining(indOfCardsLeft);
        details.cardsRemaining(indOfCardsLeft) = []; % delete the element that got selected
    else
        % this is exemplar
        ind = indFromTrialDistribution;
    end

    % pickedIndices(end+1) = ind;
    details.cardSelected = ind;
    % details.cardsRemaining = details.cardsRemaining;

    % finished doing deck handling
else
    % 'normal' mode
    ind=min(find(rand<cumsum(getDist(stimulus)))); %draw from trialDistribution
end

% ====================================================================================
% do image preparation
scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

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
[stimulus updateSM ims]=checkImages(stimulus,uint8(ind),backgroundcolor, pctScreenFill, normalizeHistograms,width,height);

%ims comes back as a nX2 cell array, where n is number of images specified in the trialDistribution entry we requested
%ims{:,1} is the image data, ims{:,2} are details (like the file name)

if strcmp(trialManagerClass,'freeDrinks') && size(ims,1)==length(responsePorts)-1
    responsePorts=responsePorts(1:end-1); %free drinks trial will have one extra response port
end

details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
if ~isempty(trialRecords) && length(trialRecords)>1 % added length check because now we get trialRecords(end) (includes this trial)
    lastRec=trialRecords(end-1);
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

% 1/22/09 - expert mode
if strcmp(type,'expert')
    stim=details;
    stim.height=height;
    stim.width=width;
    stim.floatprecision=0;
end

out=stim;

if details.correctionTrial;
    text='correction trial!';
else
    d=getDist(stimulus);
    text=sprintf('trial type %d (%g%%) (%s)',ind,round(100*d(ind)),fileNames);
end