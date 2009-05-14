function [imageMatrix numTrials sweptValues conditionInds]=getStimSweep(sweptParameters,sweptValues,borderColor,dataSource,doMontage)
%returns a cell array of images for all sweptParmeters
%and an optional (potentially very  large) matrix of logical inds
%such that inds(:,n) is a logical for all trials in d that showed stim{n}
%
% [images numTrials sweptValues conditionInd]=getStimSweep({'targetOrientation','flankerOrientation','flankerPosAngle','targetContrast'},{pi/8*[-1 1],pi/8*[-1 1],pi/8*[-1 1],[1 0]},'231');
% [images numTrials sweptValues conditionInd]=getStimSweep({'targetOrientation','flankerOrientation','flankerPosAngle'},{pi/8*[-1 1],pi/8*[-1 1],pi/8*[-1 1]},'231');

verbose=1;

if ~exist('dataSource','var')
    dataSource=[];
    %dataSource='231';
end

switch class(dataSource)
    case 'double'
        % nothing, its empty prob
    case 'char' % subject ID
        d=getSmalls(dataSource);
        r=getRatrix;
    otherwise
        dataSource
        error('bad dataSource class')
end

if ~exist('imageType') || isempty(imageType)
    imageType= 'column'; % 'iconSquare','column','full'
end



if exist('r','var')
    s=getSubjectFromID(r,d.info.subject);
    [p step]=getProtocolAndStep(s);
    ts=getTrainingStep(p,step);
    tmClass=class(getTrialManager(ts));
    sm=getStimManager(ts);
else
    %[param]=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToRightDetection','2_4','Oct.09,2007');
    %[ts]=setFlankerStimRewardAndTrialManager(param);
    %sm=getStimManager(ts);
    sm=ifFeatureGoRightWithTwoFlank('basic');
    tmClass='nAFC';
end
% end up with a sm, regardless of whether it came from ratrix or was built

if ~exist('sweptParameters') || isempty(sweptParameters)
    sweptParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast'}; % last entry must be targetContrast
end

if ~exist('sweptValues') || isempty(sweptValues)
    if exist('d','var')
        sweptValues='extractUniqueValuesFromData'; %extractFromStimulusManager
    else
        orient=pi/12;
        sweptValues={orient*[-1 1],orient*[-1 1],orient*[-1 1],[0 1]};
    end
end

if ~exist('borderColor') || isempty(borderColor)
    borderMethod='none'; % maybe switch to 'calculated' one day
else
    borderMethod='input';
end
    
if ~exist('doMontage') || isempty(doMontage)
    doMontage=false;  %might run out of memory if using many conditions; use for debugging during small stim cases
end

switch imageType
    case 'iconSquare'
        desiredX=100;
        desiredY=100;
    case 'column'
        sx=384;
        sy=512;
        desiredX=250;
        desiredY=400;
        padX=(sx-desiredX)/2; padY=(sy-desiredY)/2;
        borderWidth=10;
    case 'full'
        sx=1024;
        sy=768;
    otherwise
        error('bad imageType')
end
sm=setMaxWidthAndHeight(sm,sx,sy);
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

images=repmat(blank,cellSize); %cell array of empty images
thisNDindCell=repmat(blank,1,length(sweptParameters)); % temp cell array get overwritten every ind
cp=cumprod(cellSize);
numInds=cp(end); %length of for loop for all possible conditions

if strcmp(borderMethod,'input') && ~(size(borderColor,1)==numInds)
    borderColor
    size(borderColor,1)
    numInds
    error('must specify a color for each condition in this mode')
end


if nargout>1  
    totalTrials=size(d.date,2);
    numTrials=nan(cellSize);
end

if nargout>3
    conditionInds=zeros(numInds,totalTrials);
end

imageMatrix=zeros(desiredY,desiredX,3,numInds,'uint8');
for i=1:numInds
    forceStimDetails =[];
    if nargout>1
        meetsConditions=ones(1,totalTrials); %starts true for all trials
    end
    
    %find the index in N-dimentions
    [thisNDindCell{:}]=ind2sub(cellSize,i);
    NDind=cell2mat(thisNDindCell);

    %determine the details for this condition, and the trials it occurs on
    for j=1:length(sweptParameters)
        forceStimDetails.(sweptParameters{j})=sweptValues{j}(NDind(j));
        if nargout>1
            meetsConditions= meetsConditions & d.(sweptParameters{j})==sweptValues{j}(NDind(j));
        end
    end
    
    if nargout>1 %only save if its asked for
        %the count of each condition
        numTrials(i)=sum(meetsConditions);
    end
    
    if nargout>3 %only save if its asked for
        conditionInds(i,:)=meetsConditions;
    end

    %get the stimulus image
    reponsePorts=3;
      
    %make a colored border for the image
        switch borderMethod
            case 'none'
                im0= repmat(sampleStimFrame(sm,tmClass,forceStimDetails,reponsePorts,sx,sy),[1 1 3]);
                image=repmat(im0(1+padY:sy-padY,1+padX:sx-padX),[1 1 3]);
            case 'input'
                [im0]= sampleStimFrame(sm,tmClass,forceStimDetails,reponsePorts,sx,sy);
                center=repmat(im0(1+padY+borderWidth:sy-padY-borderWidth,1+padX+borderWidth:sx-padX-borderWidth),[1 1 3]);
                image=uint8(255*repmat(reshape(borderColor(i,:),[1 1 3]),[desiredY desiredX 1]));
                image(borderWidth+1:end-borderWidth,borderWidth+1:end-borderWidth,:)=center;
            case 'calculate'
                error('not yet')
                %borderColor
                colorInd=2;
                if torients(i)==forients(j)
                    if torients(i)==fpas(l)
                        colorInd=1;% colin
                    else
                        colorInd=4;% para
                    end
                end
            otherwise
                borderMethod
                error('bad method')
        end

    %images{i}=uint8(image);
    imageMatrix(:,:,:,i)=uint8(image); % use format compatible with montage

    if verbose
        forceStimDetails
        if nargout>1
            disp(sprintf('stimulus condition: %d, numTrials: %d',i,numTrials(i)))
        end
    end
end

if nargout>3
    conditionInds=logical(conditionInds);
end

if doMontage
    %have=find(numTrials(:)>0);
    %figure; montage(imageMatrix,'DisplayRange',[0,255],'Indices',have)
    figure; montage(imageMatrix,'DisplayRange',[0,255],'Size', [nan 4])
end

