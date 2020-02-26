%% batch_SALINEonly
n = 0;
% pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% pathname = 'D:\Kristen\'
pathname = 'F:\Kristen\salineOnly_19\'
% datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% datapathname = 'D:\Kristen\'
datapathname = 'F:\Kristen\salineOnly_19\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
% outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
outpathname = 'F:\Kristen\salineOnly_19\'
% outpathname = 'D:\Kristen\'

%% G6H203RT @ 0.15 mL SALINE
n=n+1;
files(n).subj = 'G6H203RT'; %animal name
files(n).expt = '082919'; %date of experiment
files(n).topox= '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOX\082919_G6H203RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOX\082919_G6H203RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOY\082919_G6H203RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOY\082919_G6H203RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_FOURXTHREEY\082919_G6H203RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_FOURXTHREEY\082919_G6H203RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'SALINE'; 
files(n).dose = '0.15 mL'
files(n).virus = 'hM4Di';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H203RT'; %animal name
files(n).expt = '082919'; %date of experiment
files(n).topox= '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOX\082919_G6H203RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOX\082919_G6H203RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOY\082919_G6H203RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOY\082919_G6H203RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_FOURXTHREEY\082919_G6H203RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_FOURXTHREEY\082919_G6H203RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'SALINE'; 
files(n).dose = '0.15 mL' 
files(n).virus = 'hM4Di';
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
files(n).notes = 'good data';

%% G6H204RT @ 0.15 mL SALINE
% MAYBE - waiting on sectioning results
% n=n+1;
% files(n).subj = 'G6H204RT'; %animal name
% files(n).expt = '100419'; %date of experiment
% files(n).topox= '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_PRE_TOPOX\100419_G6H204RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_PRE_TOPOX\100419_G6H204RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_PRE_TOPOY\100419_G6H204RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_PRE_TOPOY\100419_G6H204RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_PRE_FOURXTHREEY\100419_G6H204RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_PRE_FOURXTHREEY\100419_G6H204RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'SALINE'; 
% files(n).dose = '0.15 mL'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H204RT'; %animal name
% files(n).expt = '100419'; %date of experiment
% files(n).topox= '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_POST_TOPOX\100419_G6H204RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_POST_TOPOX\100419_G6H204RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_POST_TOPOY\100419_G6H204RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_POST_TOPOY\100419_G6H204RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_POST_FOURXTHREEY\100419_G6H204RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '100419_G6H204RT_RIG2\100419_G6H204RT_RIG2_POST_FOURXTHREEY\100419_G6H204RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'SALINE'; 
% files(n).dose = '0.15 mL' 
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';