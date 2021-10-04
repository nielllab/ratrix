%% batch_CLOZonly
n = 0;
% pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% pathname = 'D:\Kristen\'
pathname = 'F:\Kristen\clozOnly_19\'
% datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% datapathname = 'D:\Kristen\'
datapathname = 'F:\Kristen\clozOnly_19\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
% outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
outpathname = 'F:\Kristen\clozOnly_19\'
% outpathname = 'D:\Kristen\'

%% G6H113LT non-dreadds @ 0.5 mg/kg cloz **really 4x3y
n=n+1;
files(n).subj = 'G6H113LT'; %animal name
files(n).expt = '051719'; %date of experiment
files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURYmaps.mat';
files(n).grating4x3y5sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).virus = 'control';
files(n).timing = 'pre';
files(n).training = 'naive';
% files(n).area = 'lp'; % no injection, no area
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H113LT'; %animal name
files(n).expt = '051719'; %date of experiment
files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOX\051719_G6H113LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOX\051719_G6H113LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOY\051719_G6H113LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOY\051719_G6H113LT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURYmaps.mat';
files(n).grating4x3y5sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).virus = 'control';
files(n).timing = 'post';
files(n).training = 'naive';
% files(n).area = 'lp'; % no injection, no area
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

%% G6H146LT non-dreadds @ 0.1 mg/kg cloz **really 4x3y
% n=n+1;
% files(n).subj = 'G6H146LT'; %animal name
% files(n).expt = '051719'; %date of experiment
% files(n).topox= '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOX\051719_G6H146LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOX\051719_G6H146LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOY\051719_G6H146LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOY\051719_G6H146LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y6sf3tf =  '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_THREEXFOURY\051719_G6H146LT_RIG2_PRE_THREEXFOURYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_THREEXFOURY\051719_G6H146LT_RIG2_PRE_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.1 mg/kg'
% files(n).virus = 'control';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% % files(n).area = 'lp'; % no injection, no area
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H146LT'; %animal name
% files(n).expt = '051719'; %date of experiment
% files(n).topox= '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOX\051719_G6H146LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOX\051719_G6H146LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOY\051719_G6H146LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOY\051719_G6H146LT_RIG2_POST_TOPOY';
% files(n).grating4x3y6sf3tf =  '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_THREEXFOURY\051719_G6H146LT_RIG2_POST_THREEXFOURYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_THREEXFOURY\051719_G6H146LT_RIG2_POST_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.1 mg/kg'
% files(n).virus = 'control';
% files(n).timing = 'post';
% files(n).training = 'naive';
% % files(n).area = 'lp'; % no injection, no area
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';

%% G6H141RT non-dreadds @ 1.0 mg/kg, here I changed data file name to correctly reflect stim name (4x3y)
n=n+1;
files(n).subj = 'G6H141RT'; %animal name
files(n).expt = '051819'; %date of experiment
files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg';
files(n).virus = 'control';
files(n).timing = 'pre';
files(n).training = 'naive';
% files(n).area = 'lp'; % no injection, no area
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H141RT'; %animal name
files(n).expt = '051819'; %date of experiment
files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOX\051819_G6H141RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOX\051819_G6H141RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOY\051819_G6H141RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOY\051819_G6H141RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg';
files(n).virus = 'control';
files(n).timing = 'post';
files(n).training = 'naive';
% files(n).area = 'lp'; % no injection, no area
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';