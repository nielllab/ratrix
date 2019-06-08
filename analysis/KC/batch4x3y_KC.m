%% batch4x3y_KC

n = 0;
% pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
pathname = 'D:\Kristen\'
% datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
datapathname = 'D:\Kristen\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
% outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
outpathname = 'D:\Kristen\'
%% G6H113LT non-dreadds @ 0.5 mg/kg cloz
n=n+1;
files(n).subj = 'G6H113LT'; %animal name
files(n).expt = '051719'; %date of experiment
files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURYmaps.mat';
files(n).grating4x3y6sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'yes'; %no actual virus, just control
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
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
files(n).grating4x3y6sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURYmaps.mat';
files(n).grating4x3y6sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'yes'; %no actual virus, just control
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H146LT non-dreadds @ 0.1 mg/kg 
n=n+1;
files(n).subj = 'G6H146LT'; %animal name
files(n).expt = '051719'; %date of experiment
files(n).topox= '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOX\051719_G6H146LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOX\051719_G6H146LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOY\051719_G6H146LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_TOPOY\051719_G6H146LT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_THREEXFOURY\051719_G6H146LT_RIG2_PRE_THREEXFOURYmaps.mat';
files(n).grating4x3y6sf3tfdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_PRE_THREEXFOURY\051719_G6H146LT_RIG2_PRE_THREEXFOURY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.1 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H146LT'; %animal name
files(n).expt = '051719'; %date of experiment
files(n).topox= '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOX\051719_G6H146LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOX\051719_G6H146LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOY\051719_G6H146LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_TOPOY\051719_G6H146LT_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_THREEXFOURY\051719_G6H146LT_RIG2_POST_THREEXFOURYmaps.mat';
files(n).grating4x3y6sf3tfdata = '051719_G6H146LT_RIG2\051719_G6H146LT_RIG2_POST_THREEXFOURY\051719_G6H146LT_RIG2_POST_THREEXFOURY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.1 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H141RT non-dreadds @ 1.0 mg/kg, here I changed data file name to correctly reflect stim name (4x3y)
n=n+1;
files(n).subj = 'G6H141RT'; %animal name
files(n).expt = '051819'; %date of experiment
files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'yes'; %no actual virus, just control
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
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
files(n).grating4x3y6sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'yes'; %no actual virus, just control
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H1213LT @ 0.5 mg/kg
n=n+1;
files(n).subj = 'G6H1213LT'; %animal name
files(n).expt = '052119'; %date of experiment
files(n).topox= '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOX\052119_G6H1213LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOX\052119_G6H1213LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOY\052119_G6H1213LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOY\052119_G6H1213LT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_FOURXTHREEY\052119_G6H1213LT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_FOURXTHREEY\052119_G6H1213LT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H1213LT'; %animal name
files(n).expt = '052119'; %date of experiment
files(n).topox= '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOX\052119_G6H1213LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOX\052119_G6H1213LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOY\052119_G6H1213LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOY\052119_G6H1213LT_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_FOURXTHREEY\052119_G6H1213LT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_FOURXTHREEY\052119_G6H1213LT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H1212RT @ 0.5 mg/kg
n=n+1;
files(n).subj = 'G6H1212RT'; %animal name
files(n).expt = '052219'; %date of experiment
files(n).topox= '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOX\052219_G6H1212RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOX\052219_G6H1212RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOY\052219_G6H1212RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOY\052219_G6H1212RT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_FOURXTHREEY\052219_G6H1212RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_FOURXTHREEY\052219_G6H1212RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H1212RT'; %animal name
files(n).expt = '052219'; %date of experiment
files(n).topox= '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOX\052219_G6H1212RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOX\052219_G6H1212RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOY\052219_G6H1212RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOY\052219_G6H1212RT_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_FOURXTHREEY\052219_G6H1212RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_FOURXTHREEY\052219_G6H1212RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H137LT @ 0.5 mg/kg
n=n+1;
files(n).subj = 'G6H137LT'; %animal name
files(n).expt = '052319'; %date of experiment
files(n).topox= '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_PRE_TOPOX\052319_G6H137LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_PRE_TOPOX\052319_G6H137LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_PRE_TOPOY\052319_G6H137LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_PRE_TOPOY\052319_G6H137LT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_PRE_FOURXTHREEY\052319_G6H137LT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_PRE_FOURXTHREEY\052319_G6H137LT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H137LT'; %animal name
files(n).expt = '052319'; %date of experiment
files(n).topox= '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_POST_TOPOX\052319_G6H137LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_POST_TOPOX\052319_G6H137LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_POST_TOPOY\052319_G6H137LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_POST_TOPOY\052319_G6H137LT_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_POST_FOURXTHREEY\052319_G6H137LT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052319_G6H137LT_RIG2\052319_G6H137LT_RIG2_POST_FOURXTHREEY\052319_G6H137LT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H137TT @ 1.0 mg/kg
n=n+1;
files(n).subj = 'G6H137TT'; %animal name
files(n).expt = '052419'; %date of experiment
files(n).topox= '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOX\052419_G6H137TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOX\052419_G6H137TT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOY\052419_G6H137TT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOY\052419_G6H137TT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_FOURXTHREEY\052419_G6H137TT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_FOURXTHREEY\052419_G6H137TT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H137TT'; %animal name
files(n).expt = '052419'; %date of experiment
files(n).topox= '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOX\052419_G6H137TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOX\052419_G6H137TT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOY\052419_G6H137TT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOY\052419_G6H137TT_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECT\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECTmaps.mat';
files(n).grating4x3y6sf3tfdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECT\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECT';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%% G6H175NN @ 1.0 mg/kg
n=n+1;
files(n).subj = 'G6H175NN'; %animal name
files(n).expt = '052719'; %date of experiment
files(n).topox= '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_PRE_TOPOX\052719_G6H175NN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_PRE_TOPOX\052719_G6H175NN_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_PRE_TOPOY\052719_G6H175NN_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_PRE_TOPOY\052719_G6H175NN_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_PRE_FOURXTHREEY\052719_G6H175NN_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_PRE_FOURXTHREEY\052719_G6H175NN_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H175NN'; %animal name
files(n).expt = '052719'; %date of experiment
files(n).topox= '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_POST_TOPOX\052719_G6H175NN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_POST_TOPOX\052719_G6H175NN_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_POST_TOPOY\052719_G6H175NN_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_POST_TOPOY\052719_G6H175NN_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_POST_FOURXTHREEY\052719_G6H175NN_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052719_G6H175NN_RIG2\052719_G6H175NN_RIG2_POST_FOURXTHREEY\052719_G6H175NN_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

%% for new 3x2y
% files(n).grating3x2y6sf4tf =  '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Ymaps.mat';
% files(n).grating3x2y6sf4tfdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Y';
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
%% NOTE - all mice before here recorded in portriat mode, even though says otherwise currently
%% G6H175LN @ 1.0 mg/kg
n=n+1;
files(n).subj = 'G6H175LN'; %animal name
files(n).expt = '060119'; %date of experiment
files(n).topox= '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOX\060119_G6H175LN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOX\060119_G6H175LN_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOY\060119_G6H175LN_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOY\060119_G6H175LN_RIG2_PRE_TOPOY';
files(n).grating3x2y6sf4tf =  '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Y';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H175LN'; %animal name
files(n).expt = '060119'; %date of experiment
files(n).topox= '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOX\060119_G6H175LN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOX\060119_G6H175LN_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOY\060119_G6H175LN_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOY\060119_G6H175LN_RIG2_POST_TOPOY';
files(n).grating3x2y6sf4tf =  '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Ymaps.mat';
files(n).grating3x2y6sf4tfdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Y';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';
