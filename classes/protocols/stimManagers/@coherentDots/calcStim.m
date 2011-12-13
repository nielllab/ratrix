function [stimulus updateSM resolutionIndex preRequestStim preResponseStim discrimStim LUT targetPorts distractorPorts ...
    details interTrialLuminance text indexPulses imagingTasks] = ...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)

% Reinagel, Mankin, Calhoun 2008 SFN Poster: http://biology.ucsd.edu/labs/reinagel/SpeedAccuracyPoster2009.pdf
%
% "In the visual random dot motion task, subjects discriminate which of two directions the majority of dots are moving."
% as originally coded and used in the poster, this is false.
% dots build up towards the edge of the screen in the direction of motion.
% thus, the task can be solved by detecting more dots (contrast) on that side of the screen, completely independent of motion.
% this is because dots that fall off a screen boundary move to a random position on the screen, rather than wrapping around
% (see http://www.shadlen.org/Code/VCRDM README)
% consider how many dots are on each side of the screen at time t:
%   new dots are balanced on both sides of the screen.
%   but on the side in the direction of motion, it has all dots that started there and haven't yet fallen off
%   PLUS all the dots that have moved there from the opposite side.

% also, the stim figure in the poster is false -- it shows every dot moving the same distance, in varying directions
% as coded, dots that are chosen to move incoherently move to a random position on the screen, NOT a fixed distance in a random direction.
% this matches newsome's original strategy (but his figures also correctly represent this, though they imply a small max distance, not total random new location)

% newsome's first description of the task: http://neurosci.info/courses/vision2/Extrastriate/Newsome_pare_1988.pdf
% used PDP-11 (!) code from tony movshon -- would be great to see original
% is silent regarding dots that fall off the end of the screen
% their examples, however, show that such dots are not replaced at a random screen location, but appear on the edge opposite the direction of motion
% http://monkeybiz.stanford.edu/movies/100coh_circle.qt

% shadlen, newsome's student, DOES do wrap-around correction (VCRDM is his)

% newsome quotes these previously existing dot stimuli, which DO do wrap-around correction (i need to verify that):
% 1) morgan and ward 80 Conditions for motion flow in dynamic visual noise. Vision Res. 20: 431-435
% 2) nakayama and tyler 81 Psychophysical isolation of movement sensitivty by removal of familiar position cues. Vision Res. 21: 427-433.
%    http://visionlab.harvard.edu/members/ken/Ken%20papers%20for%20web%20page/024NKTylerVisionR1981.pdf
% 3) williams and sekuler 84 Coherent global motion percepts from stochastic local omtions. Vision Res. 24: 55-62.
%    (DOES keep distance uniform)
%    http://people.brandeis.edu/~sekuler/papers/williamsSekuler_coherentPerceptRDC_VisRes1984.pdf

% 1/30/09 - trialRecords now includes THIS trial
s = stimulus;
indexPulses=[];
imagingTasks=[];
%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));

% TODO:  Change this
% out = 1;

% LUTBitDepth=8;
% numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
% ramp=[0:fraction:1];
% LUT= [ramp;ramp;ramp]';
[LUT stimulus updateSM]=getLUT(stimulus,LUTbits);

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

if isnan(resolutionIndex)
    resolutionIndex=1;
end


% updateSM=0;     % For intertrial dependencies
% isCorrection=0;     % For correction trials to force to switch sides

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

details.pctCorrectionTrials=stimulus.pctCorrectionTrials; % need to change this to be passed in from trial manager
if ~isempty(trialRecords) && length(trialRecords)>=2
    lastRec=trialRecords(end-1);
else
    lastRec=[];
end
[targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass,allowRepeats);

targets = ismember(responsePorts,targetPorts);

leftMid = floor(length(targets)/2);
rightMid = 1+ceil(length(targets)/2);

lefts = sum(targets(1:leftMid));
rights = sum(targets(rightMid:end));

if lefts==rights
    static=true;
    dotDirection=-1;
    selectedDuration=1/hz;
else
    static=false;
    if lefts>rights
        dotDirection = pi;
    else
        dotDirection = 0;
    end
    if length(s.movie_duration)==2
        selectedDuration = s.movie_duration(1) + rand(1)*(s.movie_duration(2)-s.movie_duration(1));
    else
        selectedDuration = s.movie_duration;
    end
end

num_frames = floor(hz * selectedDuration);

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
wrap = false;
if wrap % prevent spatial buildup in direction of motion
    [dots_movie alldotsxy] = cdots(s.num_dots,s.screen_width,s.screen_height,num_frames,selectedCoherence,selectedSpeed,dotDirection,shape);   
else
    alldotsxy = [rand(s.num_dots,1)*(s.screen_width-1)+1 ...
        rand(s.num_dots,1)*(s.screen_height-1)+1];
    dot_history = zeros(s.num_dots,2,num_frames);
    
    dots_movie = uint8(zeros(s.screen_height, s.screen_width, num_frames));
    
    frame = zeros(s.screen_height,s.screen_width);
    frame(sub2ind(size(frame),floor(alldotsxy(:,2)),floor(alldotsxy(:,1)))) = 1;
    frame = conv2(frame,shape,'same');
    frame(frame > 0) = 255;
    dot_history(:,:,1) = alldotsxy;
    dots_movie(:,:,1) = uint8(frame);
    % alldotsxy(:,1);
    % alldotsxy(:,2);
    
    if ~static
        
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
            
        end
    end
end

out = dots_movie*selectedContrast;

switch dotDirection
    case -1 %static
        % do nothing
    case pi %go left
        out(:,1+round(s.screen_width*s.sideDisplay):end,:)=0;
    case 0 %go right
        out(:,1:round(s.screen_width*(1-s.sideDisplay)),:)=0;
    otherwise
        error('unrecognized direction')
end

if strcmp(stimulus.replayMode,'loop')
    type='loop';
elseif strcmp(stimulus.replayMode,'once')
    type='cache';
    out(:,:,end+1)=0;
else
    error('unknown replayMode');
end

% details.stimStruct = structize(stimulus);
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
details.selectedDuration = selectedDuration;

details.sideDisplay=s.sideDisplay;

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;

if (strcmp(trialManagerClass,'nAFC') || strcmp(trialManagerClass,'goNoGo')) && details.correctionTrial
    text='correction trial!';
else
    text=sprintf('coherence: %g dot_size: %g contrast: %g speed: %g',selectedCoherence,selectedDotSize,selectedContrast,selectedSpeed);
end