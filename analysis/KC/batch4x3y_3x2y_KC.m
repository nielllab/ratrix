%% batch4x3y_KC
n = 0;
% pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% pathname = 'D:\Kristen\'
pathname = 'F:\Widefield_Analysis\Kristen\'
% datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% datapathname = 'D:\Kristen\'
datapathname = 'F:\Widefield_Analysis\Kristen\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
% outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
outpathname = 'F:\Widefield_Analysis\Kristen\'
% outpathname = 'D:\Kristen\'

%% G6H113LT non-dreadds @ 0.5 mg/kg cloz **really 4x3y
% n=n+1;
% files(n).subj = 'G6H113LT'; %animal name
% files(n).expt = '051719'; %date of experiment
% files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y6sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'yes'; %no actual virus, just control
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
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
% files(n).subj = 'G6H113LT'; %animal name
% files(n).expt = '051719'; %date of experiment
% files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOX\051719_G6H113LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOX\051719_G6H113LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOY\051719_G6H113LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOY\051719_G6H113LT_RIG2_POST_TOPOY';
% files(n).grating4x3y6sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'yes'; %no actual virus, just control
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%% G6H146LT non-dreadds @ 0.1 mg/kg **really 4x3y
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
% files(n).controlvirus = 'yes';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
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
% files(n).controlvirus = 'yes'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';

%% G6H141RT non-dreadds @ 1.0 mg/kg, here I changed data file name to correctly reflect stim name (4x3y)
% n=n+1;
% files(n).subj = 'G6H141RT'; %animal name
% files(n).expt = '051819'; %date of experiment
% files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y6sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg'
% files(n).controlvirus = 'yes'; %no actual virus, just control
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
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
% files(n).subj = 'G6H141RT'; %animal name
% files(n).expt = '051819'; %date of experiment
% files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOX\051819_G6H141RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOX\051819_G6H141RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOY\051819_G6H141RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOY\051819_G6H141RT_RIG2_POST_TOPOY';
% files(n).grating4x3y6sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg'
% files(n).controlvirus = 'yes'; %no actual virus, just control
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%% G6H1213LT @ 0.5 mg/kg **leave mouse out due to poor window
% n=n+1;
% files(n).subj = 'G6H1213LT'; %animal name
% files(n).expt = '052119'; %date of experiment
% files(n).topox= '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOX\052119_G6H1213LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOX\052119_G6H1213LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOY\052119_G6H1213LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_TOPOY\052119_G6H1213LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y6sf3tf =  '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_FOURXTHREEY\052119_G6H1213LT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_PRE_FOURXTHREEY\052119_G6H1213LT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'poor window';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H1213LT'; %animal name
% files(n).expt = '052119'; %date of experiment
% files(n).topox= '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOX\052119_G6H1213LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOX\052119_G6H1213LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOY\052119_G6H1213LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_TOPOY\052119_G6H1213LT_RIG2_POST_TOPOY';
% files(n).grating4x3y6sf3tf =  '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_FOURXTHREEY\052119_G6H1213LT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '052119_G6H1213LT_RIG2\052119_G6H1213LT_RIG2_POST_FOURXTHREEY\052119_G6H1213LT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'poor window';
% 
%% G6H1212RT @ 0.5 mg/kg
% n=n+1;
% files(n).subj = 'G6H1212RT'; %animal name
% files(n).expt = '052219'; %date of experiment
% files(n).topox= '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOX\052219_G6H1212RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOX\052219_G6H1212RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOY\052219_G6H1212RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_TOPOY\052219_G6H1212RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y6sf3tf =  '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_FOURXTHREEY\052219_G6H1212RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_PRE_FOURXTHREEY\052219_G6H1212RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
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
% files(n).subj = 'G6H1212RT'; %animal name
% files(n).expt = '052219'; %date of experiment
% files(n).topox= '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOX\052219_G6H1212RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOX\052219_G6H1212RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOY\052219_G6H1212RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_TOPOY\052219_G6H1212RT_RIG2_POST_TOPOY';
% files(n).grating4x3y6sf3tf =  '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_FOURXTHREEY\052219_G6H1212RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '052219_G6H1212RT_RIG2\052219_G6H1212RT_RIG2_POST_FOURXTHREEY\052219_G6H1212RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%%  G6H137LT @ 0.5 mg/kg
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
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
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
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
% 
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
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
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
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
% 
%% G6H1210LT @ 1.0 mg/kg
n=n+1;
files(n).subj = 'G6H1210LT'; %animal name
files(n).expt = '052719'; %date of experiment
files(n).topox= '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_PRE_TOPOX\052719_G6H1210LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_PRE_TOPOX\052719_G6H1210LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_PRE_TOPOY\052719_G6H1210LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_PRE_TOPOY\052719_G6H1210LT_RIG2_PRE_TOPOY';
files(n).grating4x3y6sf3tf =  '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_PRE_FOURXTHREEY\052719_G6H1210LT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_PRE_FOURXTHREEY\052719_G6H1210LT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H1210LT'; %animal name
files(n).expt = '052719'; %date of experiment
files(n).topox= '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_POST_TOPOX\052719_G6H1210LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_POST_TOPOX\052719_G6H1210LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_POST_TOPOY\052719_G6H1210LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_POST_TOPOY\052719_G6H1210LT_RIG2_POST_TOPOY';
files(n).grating4x3y6sf3tf =  '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_POST_FOURXTHREEY\052719_G6H1210LT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y6sf3tfdata = '052719_G6H1210LT_RIG2\052719_G6H1210LT_RIG2_POST_FOURXTHREEY\052719_G6H1210LT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'vert';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
% 
%% G6H175LN @ 1.0 mg/kg (~2.5 in reality)
% n=n+1;
% files(n).subj = 'G6H175LN'; %animal name
% files(n).expt = '060119'; %date of experiment
% files(n).topox= '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOX\060119_G6H175LN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOX\060119_G6H175LN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOY\060119_G6H175LN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_TOPOY\060119_G6H175LN_RIG2_PRE_TOPOY';
% files(n).grating4x3y6sf3tf =  '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_FOURXTHREEY\060119_G6H175LN_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_PRE_FOURXTHREEY\060119_G6H175LN_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '2.5 mg/kg' % actually ~2.5 mg/kg
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
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
% files(n).subj = 'G6H175LN'; %animal name
% files(n).expt = '060119'; %date of experiment
% files(n).topox= '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOX\060119_G6H175LN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOX\060119_G6H175LN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOY\060119_G6H175LN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_TOPOY\060119_G6H175LN_RIG2_POST_TOPOY';
% files(n).grating4x3y6sf3tf =  '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_FOURXTHREEY\060119_G6H175LN_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y6sf3tfdata = '060119_G6H175LN_RIG2\060119_G6H175LN_RIG2_POST_FOURXTHREEY\060119_G6H175LN_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '2.5 mg/kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% %% NOTE - all mice before here recorded in vert mode
% 
% %% for new 3x2y
% % files(n).grating3x2y6sf4tf =  '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Ymaps.mat';
% % files(n).grating3x2y6sf4tfdata = '060319_G6H21p1LT_RIG2\060319_G6H21p1LT_RIG2_GRATINGS3X2Y\060319_G6H21p1LT_RIG2_GRATINGS3X2Y';
% % files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% 
%% G6H1212RT @ 1.0 mg/kg (oil spill)
% n=n+1;
% files(n).subj = 'G6H1212RT'; %animal name
% files(n).expt = '060719'; %date of experiment
% files(n).topox= '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_PRE_TOPOX\060719_G6H1212RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_PRE_TOPOX\060719_G6H1212RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_PRE_TOPOY\060719_G6H1212RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_PRE_TOPOY\060719_G6H1212RT_RIG2_PRE_TOPOY';
% files(n).grating3x2y6sf4tf =  '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_PRE_THREEXTWOY\060719_G6H1212RT_RIG2_PRE_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_PRE_THREEXTWOY\060719_G6H1212RT_RIG2_PRE_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert of land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H1212RT'; %animal name
% files(n).expt = '060719'; %date of experiment
% files(n).topox= '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_POST_TOPOX\060719_G6H1212RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_POST_TOPOX\060719_G6H1212RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_POST_TOPOY\060719_G6H1212RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_POST_TOPOY\060719_G6H1212RT_RIG2_POST_TOPOY';
% files(n).grating3x2y6sf4tf =  '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_POST_THREEXTWOY\060719_G6H1212RT_RIG2_POST_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '060719_G6H1212RT_RIG2\060719_G6H1212RT_RIG2_POST_THREEXTWOY\060719_G6H1212RT_RIG2_POST_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert of land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good data';
% 
%% G6H137TT @ 1.0 mg/kg 
% --> Topography output is dated 6/08, here was originally 6/17 but fixed date & re-ran analysis
n=n+1;
files(n).subj = 'G6H137TT'; %animal name
files(n).expt = '060819'; %date of experiment
files(n).topox= '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOX\060819_G6H137TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOX\060819_G6H137TT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOY\060819_G6H137TT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOY\060819_G6H137TT_RIG2_PRE_TOPOY';
files(n).grating3x2y6sf4tf =  '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_THREEXTWOY\060819_G6H137TT_RIG2_PRE_THREEXTWOYmaps.mat';
files(n).grating3x2y6sf4tfdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_THREEXTWOY\060819_G6H137TT_RIG2_PRE_THREEXTWOY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert of land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H137TT'; %animal name
files(n).expt = '060819'; %date of experiment
files(n).topox= '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOX\060819_G6H137TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOX\060819_G6H137TT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOY\060819_G6H137TT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOY\060819_G6H137TT_RIG2_POST_TOPOY';
files(n).grating3x2y6sf4tf =  '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_THREEXTWOY\060819_G6H137TT_RIG2_POST_THREEXTWOYmaps.mat';
files(n).grating3x2y6sf4tfdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_THREEXTWOY\060819_G6H137TT_RIG2_POST_THREEXTWOY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert of land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';

%% G6H175NN @ 1.0 mg/kg (~0.7 in reality)
% n=n+1;
% files(n).subj = 'G6H175NN'; %animal name
% files(n).expt = '060819'; %date of experiment
% files(n).topox= '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_PRE_TOPOX\060819_G6H175NN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_PRE_TOPOX\060819_G6H175NN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_PRE_TOPOY\060819_G6H175NN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_PRE_TOPOY\060819_G6H175NN_RIG2_PRE_TOPOY';
% files(n).grating3x2y6sf4tf =  '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_PRE_THREEXTWOY\060819_G6H175NN_RIG2_PRE_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_PRE_THREEXTWOY\060819_G6H175NN_RIG2_PRE_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H175NN'; %animal name
% files(n).expt = '060819'; %date of experiment
% files(n).topox= '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_POST_TOPOX\060819_G6H175NN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_POST_TOPOX\060819_G6H175NN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_POST_TOPOY\060819_G6H175NN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_POST_TOPOY\060819_G6H175NN_RIG2_POST_TOPOY';
% files(n).grating3x2y6sf4tf =  '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_POST_THREEXTWOY\060819_G6H175NN_RIG2_POST_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '060819_G6H175NN_RIG2\060819_G6H175NN_RIG2_POST_THREEXTWOY\060819_G6H175NN_RIG2_POST_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg' % probably more like 0.7 mg/kg, due to loss of injection volume
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good data';
% 
%% G6H1210LT @ 2.5 mg/kG
% n=n+1;
% files(n).subj = 'G6H1210LT'; %animal name
% files(n).expt = '061319'; %date of experiment
% files(n).topox= '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_PRE_TOPOX\061319_G6H1210LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_PRE_TOPOX\061319_G6H1210LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_PRE_TOPOY\061319_G6H1210LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_PRE_TOPOY\061319_G6H1210LT_RIG2_PRE_TOPOY';
% files(n).grating3x2y6sf4tf =  '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_PRE_THREEXTWOY\061319_G6H1210LT_RIG2_PRE_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_PRE_THREEXTWOY\061319_G6H1210LT_RIG2_PRE_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '2.5 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H1210LT'; %animal name
% files(n).expt = '061319'; %date of experiment
% files(n).topox= '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_POST_TOPOX\061319_G6H1210LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_POST_TOPOX\061319_G6H1210LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_POST_TOPOY\061319_G6H1210LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_POST_TOPOY\061319_G6H1210LT_RIG2_POST_TOPOY';
% files(n).grating3x2y6sf4tf =  '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_POST_THREEXTWOY\061319_G6H1210LT_RIG2_POST_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '061319_G6H1210LT_RIG2\061319_G6H1210LT_RIG2_POST_THREEXTWOY\061319_G6H1210LT_RIG2_POST_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '2.5 mg_kg' % probably more like 0.7 mg/kg, due to loss of injection volume
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good data';

%% G6H1210LT @ 1.0 mg/kG
n=n+1;
files(n).subj = 'G6H1210LT'; %animal name
files(n).expt = '060819'; %date of experiment
files(n).topox= '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_PRE_TOPOX\060819_G6H1210LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_PRE_TOPOX\060819_G6H1210LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_PRE_TOPOY\060819_G6H1210LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_PRE_TOPOY\060819_G6H1210LT_RIG2_PRE_TOPOY';
files(n).grating3x2y6sf4tf =  '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_PRE_THREEXTWOY\060819_G6H1210LT_RIG2_PRE_THREEXTWOYmaps.mat';
files(n).grating3x2y6sf4tfdata = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_PRE_THREEXTWOY\060819_G6H1210LT_RIG2_PRE_THREEXTWOY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H1210LT'; %animal name
files(n).expt = '060819'; %date of experiment
files(n).topox= '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_POST_TOPOX\060819_G6H1210LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_POST_TOPOX\060819_G6H1210LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_POST_TOPOY\060819_G6H1210LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_POST_TOPOY\060819_G6H1210LT_RIG2_POST_TOPOY';
files(n).grating3x2y6sf4tf =  '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_POST_THREEXTWOY\060819_G6H1210LT_RIG2_POST_THREEXTWOYmaps.mat';
files(n).grating3x2y6sf4tfdata = '060819_G6H1210LT_RIG2\060819_G6H1210LT_RIG2_POST_THREEXTWOY\060819_G6H1210LT_RIG2_POST_THREEXTWOY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg' % probably more like 0.7 mg/kg, due to loss of injection volume
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).notes = 'good data';

%% G6H1210LT @ 0.5 mg/kG
n=n+1;
files(n).subj = 'G6H1210LT'; %animal name
files(n).expt = '061919'; %date of experiment
files(n).topox= '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_PRE_TOPOX\061919_G6H1210LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_PRE_TOPOX\061919_G6H1210LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_PRE_TOPOY\061919_G6H1210LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_PRE_TOPOY\061919_G6H1210LT_RIG2_PRE_TOPOY';
files(n).grating3x2y6sf4tf =  '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_PRE_FOURXTHREEY\061919_G6H1210LT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating3x2y6sf4tfdata = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_PRE_FOURXTHREEY\061919_G6H1210LT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg_kg'
files(n).controlvirus = 'no';
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H1210LT'; %animal name
files(n).expt = '061919'; %date of experiment
files(n).topox= '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_POST_TOPOX\061919_G6H1210LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_POST_TOPOX\061919_G6H1210LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_POST_TOPOY\061919_G6H1210LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_POST_TOPOY\061919_G6H1210LT_RIG2_POST_TOPOY';
files(n).grating3x2y6sf4tf =  '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_POST_FOURXTHREEY\061919_G6H1210LT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating3x2y6sf4tfdata = '061919_G6H1210LT_RIG2\061919_G6H1210LT_RIG2_POST_FOURXTHREEY\061919_G6H1210LT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg_kg' % probably more like 0.7 mg/kg, due to loss of injection volume
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat';
files(n).notes = 'good data';

%% Post-mid-July '19

%% G6H1511RN SALINE
% n=n+1;
% files(n).subj = 'G6H1511RN'; %animal name
% files(n).expt = '080219'; %date of experiment
% files(n).topox= '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_PRE_TOPOX\080219_G6H1511RN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_PRE_TOPOX\080219_G6H1511RN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_PRE_TOPOY\080219_G6H1511RN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_PRE_TOPOY\080219_G6H1511RN_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_PRE_FOURXTHREEY\080219_G6H1511RN_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_PRE_FOURXTHREEY\080219_G6H1511RN_RIG2_PRE_FOURXTHREEY';
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
% files(n).subj = 'G6H1511RN'; %animal name
% files(n).expt = '080219'; %date of experiment
% files(n).topox= '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_POST_TOPOX\080219_G6H1511RN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_POST_TOPOX\080219_G6H1511RN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_POST_TOPOY\080219_G6H1511RN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_POST_TOPOY\080219_G6H1511RN_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_POST_FOURXTHREEY\080219_G6H1511RN_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '080219_G6H1511RN_RIG2\080219_G6H1511RN_RIG2_POST_FOURXTHREEY\080219_G6H1511RN_RIG2_POST_FOURXTHREEY';
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

%% G6H197LT SALINE
% n=n+1;
% files(n).subj = 'G6H197LT'; %animal name
% files(n).expt = '080819'; %date of experiment
% files(n).topox= '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_PRE_TOPOX\080819_G6H197LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_PRE_TOPOX\080819_G6H197LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_PRE_TOPOY\080819_G6H197LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_PRE_TOPOY\080819_G6H197LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_PRE_FOURXTHREEY\080819_G6H197LT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_PRE_FOURXTHREEY\080819_G6H197LT_RIG2_PRE_FOURXTHREEY';
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
% files(n).subj = 'G6H197LT'; %animal name
% files(n).expt = '080819'; %date of experiment
% files(n).topox= '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_POST_TOPOX\080819_G6H197LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_POST_TOPOX\080819_G6H197LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_POST_TOPOY\080819_G6H197LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_POST_TOPOY\080819_G6H197LT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_POST_FOURXTHREEY\080819_G6H197LT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '080819_G6H197LT_RIG2\080819_G6H197LT_RIG2_POST_FOURXTHREEY\080819_G6H197LT_RIG2_POST_FOURXTHREEY';
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

%% G6H1511RN @ 1.0 mg/kg CLOZ
n=n+1;
files(n).subj = 'G6H1511RN'; %animal name
files(n).expt = '080919'; %date of experiment
files(n).topox= '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_PRE_TOPOX\080919_G6H1511RN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_PRE_TOPOX\080919_G6H1511RN_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_PRE_TOPOY\080919_G6H1511RN_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_PRE_TOPOY\080919_G6H1511RN_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_PRE_FOURXTHREEY\080919_G6H1511RN_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_PRE_FOURXTHREEY\080919_G6H1511RN_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
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
files(n).subj = 'G6H1511RN'; %animal name
files(n).expt = '080919'; %date of experiment
files(n).topox= '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_POST_TOPOX\080919_G6H1511RN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_POST_TOPOX\080919_G6H1511RN_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_POST_TOPOY\080919_G6H1511RN_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_POST_TOPOY\080919_G6H1511RN_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_POST_FOURXTHREEY\080919_G6H1511RN_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '080919_G6H1511RN_RIG2\080919_G6H1511RN_RIG2_POST_FOURXTHREEY\080919_G6H1511RN_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg' 
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
files(n).notes = 'good data';

%% G6H197LT @ 1.0 mg/kg cloz
% n=n+1;
% files(n).subj = 'G6H197LT'; %animal name
% files(n).expt = '081419'; %date of experiment
% files(n).topox= '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_PRE_TOPOX\081419_G6H197LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_PRE_TOPOX\081419_G6H197LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_PRE_TOPOY\081419_G6H197LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_PRE_TOPOY\081419_G6H197LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_PRE_FOURXTHREEY\081419_G6H197LT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_PRE_FOURXTHREEY\081419_G6H197LT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
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
% files(n).subj = 'G6H197LT'; %animal name
% files(n).expt = '081419'; %date of experiment
% files(n).topox= '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_POST_TOPOX\081419_G6H197LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_POST_TOPOX\081419_G6H197LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_POST_TOPOY\081419_G6H197LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_POST_TOPOY\081419_G6H197LT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_POST_FOURXTHREEY\081419_G6H197LT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '081419_G6H197LT_RIG2\081419_G6H197LT_RIG2_POST_FOURXTHREEY\081419_G6H197LT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg' 
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

%% G6H203RT @ 0.15 mL SALINE
% n=n+1;
% files(n).subj = 'G6H203RT'; %animal name
% files(n).expt = '082919'; %date of experiment
% files(n).topox= '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOX\082919_G6H203RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOX\082919_G6H203RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOY\082919_G6H203RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_TOPOY\082919_G6H203RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_FOURXTHREEY\082919_G6H203RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_PRE_FOURXTHREEY\082919_G6H203RT_RIG2_PRE_FOURXTHREEY';
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
% files(n).subj = 'G6H203RT'; %animal name
% files(n).expt = '082919'; %date of experiment
% files(n).topox= '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOX\082919_G6H203RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOX\082919_G6H203RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOY\082919_G6H203RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_TOPOY\082919_G6H203RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_FOURXTHREEY\082919_G6H203RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '082919_G6H203RT_RIG2\082919_G6H203RT_RIG2_POST_FOURXTHREEY\082919_G6H203RT_RIG2_POST_FOURXTHREEY';
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

%% G6H203RT @ 1.0 mg/kg CLOZ
n=n+1;
files(n).subj = 'G6H203RT'; %animal name
files(n).expt = '083019'; %date of experiment
files(n).topox= '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOX\083019_G6H203RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOX\083019_G6H203RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOY\083019_G6H203RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOY\083019_G6H203RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_FOURXTHREEY\083019_G6H203RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_FOURXTHREEY\083019_G6H203RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
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
files(n).expt = '083019'; %date of experiment
files(n).topox= '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOX\083019_G6H203RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOX\083019_G6H203RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOY\083019_G6H203RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOY\083019_G6H203RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_FOURXTHREEY\083019_G6H203RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_FOURXTHREEY\083019_G6H203RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg' 
files(n).controlvirus = 'no'
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

%% G6H204RT @ 1.0 mg/kg CLOZ (#1)
% n=n+1;
% files(n).subj = 'G6H204RT'; %animal name
% files(n).expt = '100819'; %date of experiment
% files(n).topox= '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_PRE_TOPOX\100819_G6H204RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_PRE_TOPOX\100819_G6H204RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_PRE_TOPOY\100819_G6H204RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_PRE_TOPOY\100819_G6H204RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_PRE_FOURXTHREEY\100819_G6H204RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_PRE_FOURXTHREEY\100819_G6H204RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
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
% files(n).expt = '100819'; %date of experiment
% files(n).topox= '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_POST_TOPOX\100819_G6H204RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_POST_TOPOX\100819_G6H204RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_POST_TOPOY\100819_G6H204RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_POST_TOPOY\100819_G6H204RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_POST_FOURXTHREEY\100819_G6H204RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '100819_G6H204RT_RIG2\100819_G6H204RT_RIG2_POST_FOURXTHREEY\100819_G6H204RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg' 
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

%% G6H204RT @ 1.0 mg/kg CLOZ (#2)
% n=n+1;
% files(n).subj = 'G6H204RT'; %animal name
% files(n).expt = '110819'; %date of experiment
% files(n).topox= '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_PRE_TOPOX\110819_G6H204RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_PRE_TOPOX\110819_G6H204RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_PRE_TOPOY\110819_G6H204RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_PRE_TOPOY\110819_G6H204RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_PRE_FOURXTHREEY\110819_G6H204RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_PRE_FOURXTHREEY\110819_G6H204RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
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
% files(n).expt = '110819'; %date of experiment
% files(n).topox= '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_POST_TOPOX\110819_G6H204RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_POST_TOPOX\110819_G6H204RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_POST_TOPOY\110819_G6H204RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_POST_TOPOY\110819_G6H204RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_POST_FOURXTHREEY\110819_G6H204RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '110819_G6H204RT_RIG2\110819_G6H204RT_RIG2_POST_FOURXTHREEY\110819_G6H204RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg' 
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
