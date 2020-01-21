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

%% 4x/3x
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
%% PATCH/OCCLUDE
%% 127RT @ 0.5 Patch
% pre
n=n+1;
files(n).subj = 'G6H127RT'; %animal name
files(n).expt = '020519'; %date of experiment
files(n).topox= '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOX\020519_G6H127RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOX\020519_G6H127RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOY\020519_G6H127RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOY\020519_G6H127RT_RIG2_PRE_TOPOY';
files(n).patchonpatch =  '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_PATCHONPATCH\020519_G6H127RT_RIG2_PRE_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_PATCHONPATCH\020519_G6H127RT_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H127RT'; %animal name
files(n).expt = '020519'; %date of experiment
files(n).topox= '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOX\020519_G6H127RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOX\020519_G6H127RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOY\020519_G6H127RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOY\020519_G6H127RT_RIG2_POST_TOPOY';
files(n).patchonpatch =  '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_PATCHONPATCH\020519_G6H127RT_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_PATCHONPATCH\020519_G6H127RT_RIG2_POST_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
%% G6H127RT @ 0.5 Patch 
% pre
n=n+1;
files(n).subj = 'G6H127RT'; %animal name
files(n).expt = '021319'; %date of experiment
files(n).topox= '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOX\021319_G6H127RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOX\021319_G6H127RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOY\021319_G6H127RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOY\021319_G6H127RT_RIG2_PRE_TOPOY';
files(n).patchonpatch =  '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_PATCHONPATCH\021319_G6H127RT_RIG2_PRE_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_PATCHONPATCH\021319_G6H127RT_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H127RT'; %animal name
files(n).expt = '021319'; %date of experiment
files(n).topox= '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOX\021319_G6H127RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOX\021319_G6H127RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOY\021319_G6H127RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOY\021319_G6H127RT_RIG2_POST_TOPOY';
files(n).patchonpatch =  '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_PATCHONPATCH\021319_G6H127RT_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_PATCHONPATCH\021319_G6H127RT_RIG2_POST_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

%% 132RT @ 0.5 mg Patch
n=n+1;
files(n).subj = 'G6H132RT'; %animal name
files(n).expt = '011719'; %date of experiment
files(n).topox= '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOX\011719_G6H132RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOX\011719_G6H132RT_RIG2_PRE_TOPOX'; %raw data
files(n).topoy = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOY\011719_G6H132RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_TOPOY\011719_G6H132RT_RIG2_PRE_TOPOY';
files(n).patchonpatch =  '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_PATCHONPATCH\011719_G6H132RT_RIG2_PRE_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_PRE_PATCHONPATCH\011719_G6H132RT_RIG2_PRE_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

% post

n=n+1;
files(n).subj = 'G6H132RT'; %animal name
files(n).expt = '011719'; %date of experiment
files(n).topox= '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOX\011719_G6H132RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOX\011719_G6H132RT_RIG2_POST_TOPOX'; %raw data
files(n).topoy = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOY\011719_G6H132RT_RIG2_POST_TOPOYmaps.mat';
files(n).topoydata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_TOPOY\011719_G6H132RT_RIG2_POST_TOPOY';
files(n).patchonpatch =  '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_PATCHONPATCH\011719_G6H132RT_RIG2_POST_PATCHONPATCHmaps.mat';
files(n).patchonpatchdata = '011719_G6H132RT_RIG2\011719_G6H132RT_RIG2_POST_PATCHONPATCH\011719_G6H132RT_RIG2_POST_PATCHONPATCH';
files(n).inject = 'CLOZ'; 
files(n).dose = '0.5 mg/kg'
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';
