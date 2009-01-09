function ts = makeDotTrainingStepParametric(coherence, dot_size, speed, trialmanager, performancecrit, scheduler)
% ts = makeDotTrainingStepParametric(coherence, dot_size, speed, trialmanager,
% performancecrit, scheduler)
%
% makes a trainingstep for coherent dot stimuli with
% default parameters for screen size, dot density and speed etc
% INPUTS
% coherence   
%   if a float 0<coherence<1, this fraction of dots go in same direction
%   if 1x2 array of values between 0 and 1, these define min and max coh
%   and actual coherence is uniformly chosen in that range each trial
% 
% OPTIONAL args
% dot_size (units pixels on a side) - default 3  
%   if an integer, then dots are this may pixels high/wide
%   if 1x2 array of integers, then size uniformly chosen integer
%   between that min and max size each trial
% speed (units pixels/frame) - default 1 (fps=85)
%   if a float then move this many pixels per frame (computed/interpolated)
%   if 1x2 array of values then speed is uniformly chosen in that range each trial
% trialmanager - nAFC is expected - a default is created if not specified
% performancecrit - default performanceCriterion([0.85, 0.8],int16([200, 500]));
% sheduler - default sch=minutesPerSession(90,3);


if ~exist('coherence','var') | isempty(coherence),
    error('Please specify coherence between 0 and 1')
end
% fill in defaults for optional arguments
if ~exist('dot_size','var') | isempty(dot_size), % if none specified,
    dot_size =3; % default size in pixels is 3
end
if ~exist('speed','var') | isempty(speed), % if none specified,
    speed =1; % speed (pixels/frame) default is 1
end
if ~exist('trialmanager','var') | isempty(trialmanager), % if none specified,
    trialmanager=maketrialmanager; % default nAFC trial manager
end
if ~exist('performancecrit','var') | isempty(performancecrit), % if none specified,
    performancecrit=performanceCriterion([0.85, 0.8],int16([200, 500]));
end
if ~exist('scheduler','var') | isempty(scheduler),
    scheduler=minutesPerSession(120,3);
end


% these are fixed variables for now
stimulus = coherentDots;
trialManagerClass='nAFC';
JNK=100; % JUNK not used in code
responsePorts=[1,3];
totalPorts=3;
maxWidth = 100;
maxHeight = 100;
screen_width = 150;
screen_height=100; 
num_dots=100;
movie_duration=10; %sec
fps=85; % frames per sec
screen_zoom=[6 6];

discrimStim = coherentDots(stimulus,trialManagerClass,JNK,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    screen_width, screen_height, num_dots, coherence, speed, dot_size, ...
    movie_duration, fps,screen_zoom);

ts = trainingStep(trialmanager, discrimStim, performancecrit,scheduler);

