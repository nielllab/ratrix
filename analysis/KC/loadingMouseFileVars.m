% LOADING MOUSE files % variables

% navigate to BALL DATA folder, then to to diff folder to 
% save figs/vars at end

addpath F:\Kristen\Widefield2\041121_G6H277RT_RIG2\balldata_G6H277RT

close all
clear all

% load SUBJ mat file: 

load('G6H277RT_subj.mat')
% load('EE81LT_subj.mat')

% load SESSIONS mat file:
% doBehavior generates one of these files per session:

load('20210411T123140_25.mat') % 277RT 041121

% load('20210410T195352_20.mat') % 277RT 041021

% load('20210406T144122_9.mat') % EE81LT 040621

% load('20210405T132423_8.mat') % EE81LT 040421 the real date is 4/5 but says 4/4 on file name

%load('20210402T161748_7.mat') % EE81LT 040221 
% now this one is in the EE81LT folder 
% for 4-4 and has the most trials - 656

% % load('20210402T133555_14.mat') % inside 277RT 040221
% % at first I thought misnamed EE81LT 040221's missing ball data from 
% % 4/2 was here, in the 277RT balldata folder from 4-2
% % but, while it has the correct (newest) duration settings
% % it only has but 229 trials

% load('20210305T150519_3.mat') % 277RT 030521

% load('20210311T161951_5.mat') % 277RT 031121
% OR:
% load('20210311T154010_4.mat') % 277RT 031121 - this is the last session that day so maybe the correct one? I think I deleted the previous imaging session just because eye cam didnt work?

% load('20210204T164434_3.mat') % EE1LT 020421
% load('20210204T131006_5.mat') % 277RT 020421

% load('20210107T155415_1.mat') % 277RT 010721
% load('20210107T140819_6.mat') % EE81LT 010721 (file acccidentally named 010621)

%% get topox & topoy MAPS & make polar maps

% topox
[f p] = uigetfile('*.mat','topox maps file')
load(fullfile(p,f),'mapNorm');
topox = polarMap(mapNorm{3}); % polar map = projecting features from plane to sphere

% show polar map
f1 = figure
imshow(topox)
title('topox polar map of normalized WF signal')

% topoy
[f p] = uigetfile('*.mat','topoy maps file')
load(fullfile(p,f),'mapNorm','map');
topoy = polarMap(mapNorm{3});

% polar map
f2 = figure
imshow(topoy)
title('topoy polar map of normalized WF signal')

%% get THRESH MAPS

[f p] = uigetfile('*.mat','maps file');

downsize = 0.25; % why resize by this factor?
load(fullfile(p,f));

%%  downsize all 3 videos

df = imresize(dfof_bg,downsize);
topox = imresize(topox,downsize);
topoy = imresize(topoy,downsize);

%% SAVE 1st VARS - get in right FOLDER!

% save('041121_277RT_imThressPass1stVars.mat','-v7.3')


