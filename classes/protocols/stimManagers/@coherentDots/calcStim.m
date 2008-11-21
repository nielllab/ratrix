function [stimulus updateSM resolutionIndex out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance text] = ...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)

s = stimulus;

%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));

% TODO:  Change this
out = 1;

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
LUT= [ramp;ramp;ramp]';

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end


updateSM=0;     % For intertrial dependencies
% isCorrection=0;     % For correction trials to force to switch sides

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
%     case 'freeDrinks'
%         type='cache';
%         if ~isempty(trialRecords)
%             lastResponse=find(trialRecords(end).response);
%             if length(lastResponse)>1
%                 lastResponse=lastResponse(1);
%             end
%         else
%             lastResponse=[];
%         end
% 
%         targetPorts=setdiff(responsePorts,lastResponse);
%         distractorPorts=[];

    case 'nAFC'
        type='loop';

        %edf: 11.25.06: copied correction trial logic from hack addition to cuedGoToFeatureWithTwoFlank
        %edf: 11.15.06 realized we didn't have correction trials!
        %changing below...

        details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager

        %length(trialRecords)
       % trialRecords(end).stimDetails
        
        if ~isempty(trialRecords)
            lastResponse=find(trialRecords(end).response);
            lastCorrect=trialRecords(end).correct;
            lastWasCorrection=trialRecords(end).stimDetails.correctionTrial;
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
            lastCorrect=[];
            lastWasCorrection=0;
        end

        %note that this implementation will not show the exact same
        %stimulus for a correction trial, but just have the same side
        %correct.  may want to change...
        if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            'correction trial!'
            targetPorts=trialRecords(end).targetPorts;
%             isCorrection=1;
        else
            details.correctionTrial=0;
            targetPorts=responsePorts(ceil(rand*length(responsePorts)));
        end


        distractorPorts=setdiff(responsePorts,targetPorts);
        targetPorts

        %edf: 11.25.06: original:
        %targetPorts=responsePorts(ceil(rand*length(responsePorts)));
        %distractorPorts=setdiff(responsePorts,targetPorts);

    otherwise
        error('unknown trial manager class')
end


if targetPorts == 1
    % animal should go left
    dotDirection = pi
elseif targetPorts == 3
    dotDirection = 0
else
    error('Zah?  This should never happen!')
end

num_frames = hz * s.movie_duration;

alldotsxy = [rand(s.num_dots,1)*(s.screen_width-1)+1 ...
              rand(s.num_dots,1)*(s.screen_height-1)+1];
dot_history = zeros(s.num_dots,2,num_frames);

dots_movie = uint8(zeros(s.screen_height, s.screen_width, num_frames));

% ===================================================================================
% 11/20/08 - fli
% do all random picking here (from coherence, size, contrast, speed as necessary)
%   s.coherence -> selectedCoherence
%   s.dot_size -> selectedDotSize
%   s.contrast -> selectedContrast
%   s.speed -> selectedSpeed
% coherence
if length(s.coherence)==2
    selectedCoherence = s.coherence(1) + rand(1)*(s.coherence(2)-s.coherence(1));
else
    selectedCoherence = s.coherence;
end
% dot_size
if length(s.dot_size)==2
    selectedDotSize = round(s.dot_size(1) + rand(1)*(s.dot_size(2)-s.dot_size(1)));
else
    selectedDotSize = s.dot_size;
end
% contrast
if length(s.contrast)==2
    selectedContrast = s.contrast(1) + rand(1)*(s.contrast(2)-s.contrast(1));
else
    selectedContrast = s.contrast;
end
% speed
if length(s.speed)==2
    selectedSpeed = s.speed(1) + rand(1)*(s.speed(2)-s.speed(1));
else
    selectedSpeed = s.speed;
end
% ===================================================================================
%shape = zeros(dot_size,2);
% Make a square shape
shape = ones(selectedDotSize);

%% Draw those dots!

frame = zeros(s.screen_height,s.screen_width);
frame(sub2ind(size(frame),floor(alldotsxy(:,2)),floor(alldotsxy(:,1)))) = 1;
frame = conv2(frame,shape,'same');
frame(frame > 0) = 255;
dot_history(:,:,1) = alldotsxy;
dots_movie(:,:,1) = uint8(frame);
% alldotsxy(:,1);
% alldotsxy(:,2);

vx = selectedSpeed*cos(dotDirection);
vy = selectedSpeed*sin(dotDirection);

for i=1:num_frames
    frame = zeros(s.screen_height,s.screen_width);
    frame(sub2ind(size(frame),floor(alldotsxy(:,2)),floor(alldotsxy(:,1)))) = 1;
    frame = conv2(frame,shape,'same');
    frame(frame > 0) = 255;
    dots_movie(:,:,i) = uint8(frame);
    dot_history(:,:,i) = alldotsxy;
    
    % Randomly find who's going to be coherent and who isn't
    move_coher = rand(s.num_dots,1) < selectedCoherence;
    move_randomly = ~move_coher;

    num_out = sum(move_randomly);

    if (num_out ~= s.num_dots)
        alldotsxy(move_coher,1) = alldotsxy(move_coher,1) + vx;
        alldotsxy(move_coher,2) = alldotsxy(move_coher,2) + vy;
    end
    if (num_out)
        alldotsxy(move_randomly,:) = [rand(num_out,1)*(s.screen_width-1)+1 ...
                                        rand(num_out,1)*(s.screen_height-1)+1];
    end

    overboard = alldotsxy(:,1) > s.screen_width | alldotsxy(:,2) > s.screen_height | ...
                    floor(alldotsxy(:,1)) <= 0 | floor(alldotsxy(:,2)) <= 0;
    num_out = sum(overboard);
    if (num_out)
        alldotsxy(overboard,:) = [rand(num_out,1)*(s.screen_width-1)+1 ...
                                        rand(num_out,1)*(s.screen_height-1)+1];
    end

end;

out = dots_movie*selectedContrast;

details.stimStruct = structize(stimulus);
details.dotDirection = dotDirection;
details.dotxy = alldotsxy;
details.coherence = s.coherence;
details.dot_size = s.dot_size;
details.contrast = s.contrast;
details.speed = s.speed;

details.selectedCoherence = selectedCoherence;
details.selectedDotSize = selectedDotSize;
details.selectedContrast = selectedContrast;
details.selectedSpeed = selectedSpeed;

if strcmp(trialManagerClass,'nAFC') && details.correctionTrial
    text='correction trial!';
else
    text=sprintf('coherence: %g dot_size: %g contrast: %g speed: %g',selectedCoherence,selectedDotSize,selectedContrast,selectedSpeed);
end