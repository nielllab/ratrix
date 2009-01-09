function ts = makeDotTrainingStep(coherence, trialmanager, performancecrit, scheduler)
% ts = makeDotTrainingStep(coherence, trialmanager, performancecrit, scheduler)
% makes a trainingstep for coherent dot stimuli with
% default parameters for screen size, dot density and speed etc
% INPUT
% coherence 
%   if a float 0<coherence<1, this fraction of dots go in same direction
%   if 1x2 array of values between 0 and 1, these define min and max coh
%   and actual coherence is uniformly chosen in that range each trial
% OPTIONAL args
% trialmanager - nAFC is expected - a default is created if not specified
% performancecrit - default performanceCriterion([0.85, 0.8],int16([200, 500]));
% sheduler - default sch=minutesPerSession(90,3);
% dot_size - default 3 pixels
% speed - default 1 pixel/frame (fps=85)
 
% defaults
if ~exist('trialmanager','var') | trialmanager==[], % if none specified,
    trialmanager=maketrialmanager; % default nAFC trial manager
end
if ~exist('performancecrit','var') | performancecrit==[], % if none specified,
    performancecrit=performanceCriterion([0.85, 0.8],int16([200, 500]));
end
if ~exist('scheduler','var') | scheduler==[],
    scheduler=minutesPerSession(90,3);
end
if ~exist('coherence','var') | coherence == [],
    error('Please specify coherence between 0 and 1')
end


dot_size=3; % default size in pixels is 3
speed =2;%speed (pixels/frame) default is 1


% these are fixed variables for now
stimulus = coherentDots;
trialManagerClass='nAFC';
frameRate=100;
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

discrimStim = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    screen_width, screen_height, num_dots, coherence, speed, dot_size, ...
    movie_duration, fps,screen_zoom);

ts = trainingStep(trialmanager, discrimStim, performancecrit,scheduler);

