function [images numTrials sweptValues conditionInds]=getStimSweep(r,d,sweptParameters,sweptValues,supressImages)
%returns a cell array of images for all sweptParmeters
%and an optional (potentially very  large) matrix of logical inds
%such that inds(:,n) is a logical for all trials in d that showed stim{n}
%
% [images numTrials sweptValues conditionInd]=getStimSweep(r,d,{'targetOrientation','flankerOrientation','flankerPosAngle','targetContrast'},{pi/8*[-1 1],pi/8*[-1 1],pi/8*[-1 1],[1 0]});
% [images numTrials sweptValues conditionInd]=getStimSweep(r,d,{'targetOrientation','flankerOrientation','flankerPosAngle'},{pi/8*[-1 1],pi/8*[-1 1],pi/8*[-1 1]});

verbose=1;
doMontage=0;  %might run out of memory if using many conditions; use for debugging during small stim cases

if ~exist('d') || isempty(d)
    d=getSmalls('231')
end

if ~exist('imageType') || isempty(imageType)
    imageType= 'column'; % 'iconSquare','column','full'
end

if ~exist('sweptParameters') || isempty(sweptParameters)
    sweptParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast'}; % last entry must be targetContrast
end

if ~exist('sweptValues') || isempty(sweptValues)
    %sweptValues={orient*[-1 1],orient*[-1 1],orient*[-1 1],[0 1]};
    sweptValues='extractUniqueValuesFromData'; %extractFromStimulusManager
end

if ~exist('supressImages') || isempty(sweptValues)
    supressImages=false;  %option to make things faster for multiRat analysis
end

s=getSubjectFromID(r,d.info.subject);
[p step]=getProtocolAndStep(s);
ts=getTrainingStep(p,step);
sm=getStimManager(ts);
tm=getTrialManager(ts);

switch imageType
    case 'iconSquare'
        height=100;
        width=100;
        sm=setMaxHeightAndWidth(sm);
    case 'column'
        height=800;
        width=400;
    case 'full'
        height=1024;
        width=768;
    otherwise
        error('bad imageType')
end

sm=cache(sm);

if isa(sweptValues,'char')
    switch sweptValues
        case 'extractUniqueValuesFromData'
            sweptValues={};
            for i=1:length(sweptParameters)
                sweptValues{i,1}=unique(d.(sweptParameters{i})(~isnan(d.(sweptParameters{i}))));
            end
        case 'extractFromStimulusManager'
            for i=1:length(sweptParameters)
                %sweptValues{i}=getFeild{s,sweptParameters(i)}  %add this method
            end
            error('not written')
        otherwise
            error('not an option')
    end
elseif isa(sweptValues,'cell')
    %leave it as passed in, a cell of vectors
    %sweptValues=sweptValues
else
    error('bad')
end

%define the output dimentions for initialization
for i=1:length(sweptParameters)
    cellSize(i)=length(sweptValues{i});
end

if verbose
    cellSize
    sweptValues
end

%initialize
blank={[]};
totalTrials=size(d.date,2);

images=repmat(blank,cellSize); %cell array of empty images
numTrials=nan(cellSize);
thisNDindCell=repmat(blank,1,length(sweptParameters)); % temp cell array get overwritten every ind
cp=cumprod(cellSize);
numInds=cp(end); %length of for loop for all possible conditions\
if nargout>3
    conditionInds=zeros(numInds,totalTrials);
end
if doMontage
    imageMatrix=zeros(height,width,1,numInds);
end

for i=1:numInds
    forceStimDetails =[];
    meetsConditions=ones(1,totalTrials); %starts true for all trials

    %find the index in N-dimentions
    [thisNDindCell{:}]=ind2sub(cellSize,i);
    NDind=cell2mat(thisNDindCell);

    %determine the details for this condition, and the trials it occurs on
    for j=1:length(sweptParameters)
        forceStimDetails.(sweptParameters{j})=sweptValues{j}(NDind(j));
        meetsConditions= meetsConditions & d.(sweptParameters{j})==sweptValues{j}(NDind(j));
    end

    %the count of each condition
    numTrials(i)=sum(meetsConditions);

    %only save if its asked for
    if nargout>3
        conditionInds(i,:)=meetsConditions;
    end

    %get the stimulus image
    %if numTrials(i)>0 %leave empty if no such trials.... turned off
    if ~supressImages
        reponsePorts=1;
        [image details]= sampleStimFrame(sm,class(tm),forceStimDetails,reponsePorts,height,width);
        images{i}=image;
        if doMontage
            imageMatrix(:,:,1,i)=image;
        end
    end
    %end

    if verbose
        forceStimDetails
        disp(sprintf('stimulus condition: %d, numTrials: %d',i,numTrials(i)))
    end
end

if nargout>3
    conditionInds=logical(conditionInds);
end

if doMontage
    have=find(numTrials(:)>0);
    figure; montage(imageMatrix,'DisplayRange',[0,255],'Indices',have)
    figure;  montage(imageMatrix,'DisplayRange',[0,255],'Size', [4 nan])

end

