%% batch_caspase3

n = 0;
pathname = 'F:\Kristen\LP_Imaging_winter20\'
datapathname = 'F:\Kristen\LP_Imaging_winter20\'
outpathname = 'F:\Kristen\LP_Imaging_winter20\'


%% CAV2-cre (V1) + cre-Dreadds (LP) in g6 ck2 mice:


%% G6H203RT @ 0.15 mL SALINE *good expression* 4x3y

%pre
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
files(n).virus = 'CAV-hM4Di'
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
files(n).virus = 'CAV-hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
files(n).notes = 'good data';

%% G6H203RT @ 1.0 mg/kg CLOZ *good expression* 4x3y

% pre
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
files(n).virus = 'CAV-hM4Di'
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
files(n).virus = 'CAV-hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; %vert or land for portrait or landscape
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
files(n).notes = 'good data';

%% non-cre-Dreadds in ck2 g6 mice:


%% *OLD cloz* G6H127RT @ 0.5 mg/kg *good expression* patch

%pre
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
files(n).dose = '0.5 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'maybe data';

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
files(n).dose = '0.5 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'maybe data';

%% G6H127RT @ (probably) 0.5 mg/kg *good expression* patch

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
files(n).dose = '0.5 mg_kg'
files(n).virus = 'hM4Di'
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
files(n).dose = '0.5 mg_kg'
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good data';

%% G6H137TT @ 1.0 mg/kg *good expression* 3x2y

%pre
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
files(n).virus = 'hM4Di'
files(n).timing = 'pre';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; 
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
files(n).virus = 'hM4Di'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'lp';
files(n).rignum = 'rig2';
files(n).monitor = 'land'; 
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename3x2y = 'C:\grating3x2y6sf4tf_1728sec.mat'
files(n).notes = 'good data';

%% G6H137TT @ 1.0 mg/kg *good expression* 4x3y

%pre
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

