%% batch_caspase3
n = 0;
% pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_WF_Imaging\'
% pathname = 'D:\Kristen\'
pathname = 'F:\Kristen\CASPASE3_20\'
% datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% datapathname = 'D:\Kristen\'
datapathname = 'F:\Kristen\CASPASE3_20\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
% outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
outpathname = 'F:\Kristen\CASPASE3_20\'
% outpathname = 'D:\Kristen\'

%% CALB2CK2G6H92LT - no injection

% post only (for purpose of analysis - there was no pre/post)

n=n+1;
files(n).subj = 'CALB2CK2G6H92LT'; %animal name
files(n).expt = '021820'; %date of experiment
files(n).topox= '021820_CALB2CK2G6H92LT_RIG2\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOX\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '021820_CALB2CK2G6H92LT_RIG2\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOX\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '021820_CALB2CK2G6H92LT_RIG2\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOY\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '021820_CALB2CK2G6H92LT_RIG2\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOY\021820_CALB2CK2G6H92LT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '021820_CALB2CK2G6H92LT_RIG2\021820_CALB2CK2G6H92LT_RIG2_PRE_FOURXTHREEY\021820_CALB2CK2G6H92LT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '021820_CALB2CK2G6H92LT_RIG2\021820_CALB2CK2G6H92LT_RIG2_PRE_FOURXTHREEY\021820_CALB2CK2G6H92LT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'no'; 
% files(n).dose = '0.15 mL' 
files(n).virus = 'caspase3';
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
files(n).notes = 'good data';

%% CALB2CK2G6H83LN - no injection

% post only (for purpose of analysis)

n=n+1;
files(n).subj = 'CALB2CK2G6H83LN'; %animal name
files(n).expt = '021820'; %date of experiment
files(n).topox= '021820_CALB2CK2G6H83LN_RIG2\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOX\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '021820_CALB2CK2G6H83LN_RIG2\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOX\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '021820_CALB2CK2G6H83LN_RIG2\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOY\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '021820_CALB2CK2G6H83LN_RIG2\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOY\021820_CALB2CK2G6H83LN_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '021820_CALB2CK2G6H83LN_RIG2\021820_CALB2CK2G6H83LN_RIG2_PRE_FOURXTHREEY\021820_CALB2CK2G6H83LN_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '021820_CALB2CK2G6H83LN_RIG2\021820_CALB2CK2G6H83LN_RIG2_PRE_FOURXTHREEY\021820_CALB2CK2G6H83LN_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'no'; 
% files(n).dose = '0.15 mL' 
files(n).virus = 'caspase3';
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
files(n).notes = 'good data';