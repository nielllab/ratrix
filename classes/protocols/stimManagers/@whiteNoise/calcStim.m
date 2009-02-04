function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% see ratrixPath\documentation\stimManager.calcStim.txt for argument specification (applies to calcStims of all stimManagers)
% 1/3/0/09 - trialRecords now includes THIS trial
LUTbits
displaySize
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);
%[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));
[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[ 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end

type = 'phased';
scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
%         type='static';
        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastResponse=find(trialRecords(end-1).response);
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
        end

        targetPorts=setdiff(responsePorts,lastResponse);
        distractorPorts=[];

    case 'nAFC'
%         type='trigger';

        details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastRec=trialRecords(end-1);
        else
            lastRec=[];
        end
        [targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts);
    case 'autopilot'
        details.pctCorrectionTrials=0;
        details.correctionTrial=0;
        targetPorts=[1];
        distractorPorts=[];
    otherwise
        error('unknown trial manager class')
end

% ================================================================================
% start calculating frames now
meanLuminance = stimulus.meanLuminance;
std = stimulus.std;
background = stimulus.background;
method = stimulus.method;
requestedStimLocation = stimulus.requestedStimLocation;
stixelSize = stimulus.stixelSize;
searchSubspace = stimulus.searchSubspace;
numFrames = stimulus.numFrames;

%calculate spatialDim
spatialDim=ceil([requestedStimLocation(3)-requestedStimLocation(1) requestedStimLocation(4)-requestedStimLocation(2)]./stixelSize)

% %if not evenly tiled, make the stim location slightly larger, to the nearest integer pixel size
% reqCntr=[(requestedStimLocation(3)+requestedStimLocation(1))/2 (requestedStimLocation(4)+requestedStimLocation(2))/2]
% reqSz=[requestedStimLocation(3)-requestedStimLocation(1) requestedStimLocation(4)-requestedStimLocation(2)]
% stixelSz=ceil(reqSz./spatialDim)
% halfSz=ceil((stixelSz.*spatialDim)/2)
% stimLocation= [reqCntr reqCntr] + [-halfSz halfSz ] 
% 
% %sanity check:
% %actualCtr=[(stimLocation(3)+stimLocation(1))/2 (stimLocation(4)+stimLocation(2))/2]
% 
% %find actual size
% actualSz=[stimLocation(3)-stimLocation(1) stimLocation(4)-stimLocation(2)]
% 
% %check that stixels are the same size and see and tile the stim space
% if ( actualSz(1)/stixelSz(1)-round(actualSz(1)/stixelSz(1))==0) && ( actualSz(2)/stixelSz(2)-round(actualSz(2)/stixelSz(2))==0)
%     %Note: nearest nieghbor interp is used, should check fullScreenHistory
% else
%     error('stims don''t tile the stim space')  
% end

% if stixelSz(1)~=stixelSz(2)
%     %NOTE: does not preserve aspect ratio of stixels, ie. allows skinny tall ones
%     %you may want to enforce a pixel ratio that has a square mm value
%     %b/c pixels themselves are not square
%     warning('non square stixel rendering;')
% end  

% %check the subspace  %not implimented yet
% if searchSubspace==1
%     searchSubspace=1; 
%     %use the identity matrix;
% else
%     error('no other subspace is defined')
% end

% movie=zeros(spatialDim(1),spatialDim(2),numFrames);
% for i=1:numFrames
%     switch method 
%         case 'texOnPartOfScreen'
%             miniIm=randn(spatialDim);
%             miniIm=meanLuminance+std*miniIm*255; % 255= white
%             movie(:,:,i) = miniIm;
% 
% %                 Screen('FillRect',w,background);
% %                 
% %                 %need to confirm that this works by GetImage and inspection
% %                 %of gfx card nearest neighbor
% %                 tex=Screen('MakeTexture', w, miniIm);
% %                 Screen('DrawTexture', w, tex, [0 0 spatialDim(1) spatialDim(2)], stimLocation, 0,0);
% %                 
% %                 %or consider this but make sure its not too slow
% %                 %tex=Screen('MakeTexture', w, imresize(miniIm,[actualSz],'nearest'));
% %                 %Screen('DrawTexture', w, tex, [0 0 actualSz(1) actualSz(2)], stimLocation, 0,0);
% % 
% %                 Screen('Flip', w);   
% %                 
% %                  switch nargout
% %                     case 2
% %                         stixelHistory(i,:,:)=miniIm;
% %                     case 3
% %                         stixelHistory(i,:,:)=miniIm;
% %                         temp=Screen('GetImage', w);
% %                         temp=reshape(temp(:,:,1),screenRect(3:4));  %only look at red channel, b/c all the same
% %                         fullScreenHistory(i,:,:)=temp;
% %                  end
% 
%         case 'fullScreenTex'
%             %tex=getStixelNoiseImage(a,b,c,d,background)
%     end
% end

% 10/31/08 - dynamic mode stim is a struct of parameters
stim = [];
stim.height = min(height,getMaxHeight(stimulus));
stim.width = min(width,getMaxWidth(stimulus));
stim.floatprecision = 1;
% set seed values
rand('state',sum(100*clock)); % initialize randn to random starting state
stim.seedValues = ceil(rand(1,numFrames)*1000000);
out.stimSpecs{1} = stimSpec(stim,{[] 2},'expert',0,numFrames,[],scaleFactor,0,hz,[]); % expert mode
% out.stimSpecs{1} = stimSpec(movie,{[] 2}, 'loop',[],1,numFrames,[],0); % regular mode

% final phase
out.stimSpecs{2} = stimSpec(interTrialLuminance,{[] 1},'loop',0,1,[],scaleFactor,1,hz,[]);

% details.big = {'expert', stim.seedValues}; % store in 'big' so it gets written to file
% variables to be stored for recalculation of stimulus from seed value for rand generator
details.strategy='expert';
details.seedValues=stim.seedValues;
details.spatialDim = spatialDim;
details.stixelSize = stixelSize;
details.std = stimulus.std;
details.meanLuminance = meanLuminance;
details.numFrames=numFrames;
details.height=stim.height;
details.width=stim.width;
% =============================

% ================================================================================
if strcmp(trialManagerClass,'nAFC') && details.correctionTrial
    text='correction trial!';
else
    text=sprintf('meanLuminance: %g',meanLuminance);
end