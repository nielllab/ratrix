%% batch LP 4X3Y

n = 0;

pathname = 'F:\Kristen\LP_Imaging_winter20\'
datapathname = 'F:\Kristen\LP_Imaging_winter20\'
outpathname = 'F:\Kristen\LP_Imaging_winter20\'

%% Cre-d Dreadds in Calb2Cre-ck2-g6 mice, 4x3y:


%%  012220_CALB2CK2G6H53RT_RIG2 @ 1.0 mg/kg SQ LP
n=n+1;
files(n).subj = 'CALB2CK2G6H53RT'; %animal name
files(n).expt = '012220'; %date of experiment
files(n).topox= '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'no expression';

% post

n=n+1;
files(n).subj = 'CALB2CK2G6H53RT'; %animal name
files(n).expt = '012220'; %date of experiment
files(n).topox= '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOX\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOX\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOY\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOY\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'no expression';
%
%% 012220_CALB2CK2G6H47LT_RIG2 @ 1.0 mg/kg SQ LP
% REMOVED frm group analysis because vis ctx not centered in FOV
% correctly
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47LT'; %animal name
% files(n).expt = '012220'; %date of experiment
% files(n).topox= '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOX\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOX\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOY\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOY\012220_CALB2CK2G6H47LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY\012220_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY\012220_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'holes';

% post

% n=n+1;
% files(n).subj = 'CALB2CK2G6H47LT'; %animal name
% files(n).expt = '012220'; %date of experiment
% files(n).topox= '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOX\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOX\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOY\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOY\012220_CALB2CK2G6H47LT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY\012220_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012220_CALB2CK2G6H47LT_RIG2\012220_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY\012220_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'holes';
%
%% 012320_CALB2CK2G6H47RT_RIG2 @ 1.0 mg/kg SQ LP *good expression*
n=n+1;
files(n).subj = 'CALB2CK2G6H47RT'; %animal name
files(n).expt = '012320'; %date of experiment
files(n).topox= '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg';
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'CALB2CK2G6H47RT'; %animal name
files(n).expt = '012320'; %date of experiment
files(n).topox= '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOX\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOX\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
% 
%%  012720_CALB2CK2G6H47LT_RIG2 @ 1.0 mg/kg SQ LP 
n=n+1;
files(n).subj = 'CALB2CK2G6H47LT'; %animal name
files(n).expt = '012720'; %date of experiment
files(n).topox= '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOX\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOX\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOY\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOY\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'holes';

% post

n=n+1;
files(n).subj = 'CALB2CK2G6H47LT'; %animal name
files(n).expt = '012720'; %date of experiment
files(n).topox= '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOX\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOX\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOY\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOY\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'holes';
%
%%  012720_CALB2CK2G6H47RN_RIG2 @ 1.0 mg/kg SQ LP
% NOTE: removed 'pre' from topoy & x by accident
n=n+1;
files(n).subj = 'CALB2CK2G6H47RN'; %animal name
files(n).expt = '012720'; %date of experiment
files(n).topox= '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOX\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_TOPOX\012720_CALB2CK2G6H47RN_RIG2_TOPOX'; %raw data
files(n).topoy = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOY\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_TOPOY\012720_CALB2CK2G6H47RN_RIG2_TOPOY';
files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'holes';

% post

n=n+1;
files(n).subj = 'CALB2CK2G6H47RN'; %animal name
files(n).expt = '012720'; %date of experiment
files(n).topox= '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOX\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOX\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOY\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOY\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'holes';

%%  012820_CALB2CK2G6H47RT_RIG2 @ 1.0 mg/kg SQ LP *good expression*
% NOTE: named 'POST_TOPOX' as 'POST_FOURXTHREEX' by accident
n=n+1;
files(n).subj = 'CALB2CK2G6H47RT'; %animal name
files(n).expt = '012820'; %date of experiment
files(n).topox= '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'CALB2CK2G6H47RT'; %animal name
files(n).expt = '012820'; %date of experiment
files(n).topox= '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOX\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEX\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEX'; %raw data
files(n).topoy = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';

%%  012820_CALB2CK2G6H53RT_RIG2 @ 1.0 mg/kg SQ LP
% 
n=n+1;
files(n).subj = 'CALB2CK2G6H53RT'; %animal name
files(n).expt = '012820'; %date of experiment
files(n).topox= '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOY';
files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'no expression';

% post

n=n+1;
files(n).subj = 'CALB2CK2G6H53RT'; %animal name
files(n).expt = '012820'; %date of experiment
files(n).topox= '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOX\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOX\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOY\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOY\012820_CALB2CK2G6H53RT_RIG2_POST_TOPOY';
files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY\012820_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY\012820_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'no expression';
