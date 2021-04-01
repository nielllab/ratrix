%% ALL MICE, ALL EXPTS

n = 0;
pathname = 'F:\Kristen\Widefield2\'
datapathname = 'F:\Kristen\Widefield2\'
outpathname = 'F:\Kristen\Widefield2\'

%% 031121_G6H277RT_RIG2  
% 
n=n+1;
files(n).subj = 'G6H277RT'; %animal name
files(n).expt = '031121'; %date of experiment
files(n).topox= '031121_G6H277RT_RIG2\031121_G6H277RT_RIG2_TOPOX\031121_G6H277RT_RIG2_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '031121_G6H277RT_RIG2\031121_G6H277RT_RIG2_TOPOX\031121_G6H277RT_RIG2_TOPOX'; %raw data
files(n).topoy = '031121_G6H277RT_RIG2\031121_G6H277RT_RIG2_TOPOY\031121_G6H277RT_RIG2_TOPOYmaps.mat';
files(n).topoydata = '030521_G6H277RT_RIG2\031121_G6H277RT_RIG2_TOPOY\031121_G6H277RT_RIG2_TOPOY';
files(n).thresh = '031121_G6H277RT_RIG2\030521_G6H277RT_RIG2_THRESH2\030521_G6H277RT_RIG2_THRESH2';
files(n).threshdata = '031121_G6H277RT_RIG2\030521_G6H277RT_RIG2_THRESH2\030521_G6H277RT_RIG2_THRESH2';
files(n).inject = 'none'; 
files(n).dose = 'none';
files(n).virus = 'none'
files(n).timing = 'none';
files(n).training = 'naive';
files(n).area = 'none';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).genotype = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% files(n).notes = ' ';

%% 020421_EE81LT_RIG2  %% accidentally left out the '1' in animal id

% n=n+1;
% files(n).subj = 'EE8LT'; %animal name
% files(n).expt = '020421'; %date of experiment
% files(n).topox= '020421_EE8LT_RIG2\020421_EE8LT_RIG2_TOPOX\020421_EE8LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '020421_EE8LT_RIG2\020421_EE8LT_RIG2_TOPOX\020421_EE8LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '020421_EE8LT_RIG2\020421_EE8LT_RIG2_TOPOY\020421_EE8LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '020421_EE8LT_RIG2\020421_EE8LT_RIG2_TOPOY\020421_EE8LT_RIG2_TOPOY';
% files(n).thresh = '020421_EE8LT_RIG2\020421_EE8LT_RIG2_THRESH\020421_EE8LT_RIG2_THRESH';
% files(n).threshdata = '020421_EE8LT_RIG2\020421_EE8LT_RIG2_THRESH\020421_EE8LT_RIG2_THRESH';
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% files(n).notes = ' ';

%% 020421_G6H277RT_RIG2  
% % 
% n=n+1;
% files(n).subj = 'G6H277RT'; %animal name
% files(n).expt = '020421'; %date of experiment
% files(n).topox= '020421_G6H277RT_RIG2\020421_G6H277RT_RIG2_TOPOX\020421_G6H277RT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '020421_G6H277RT_RIG2\020421_G6H277RT_RIG2_TOPOX\020421_G6H277RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '020421_G6H277RT_RIG2\020421_G6H277RT_RIG2_TOPOY\020421_G6H277RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '020421_G6H277RT_RIG2\020421_G6H277RT_RIG2_TOPOY\020421_G6H277RT_RIG2_TOPOY';
% files(n).thresh = '020421_G6H277RT_RIG2\020421_G6H277RT_RIG2_THRESH\020421_G6H277RT_RIG2_THRESH';
% files(n).threshdata = '020421_G6H277RT_RIG2\020421_G6H277RT_RIG2_THRESH\020421_G6H277RT_RIG2_THRESH';
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';

%% 010621_EE8LT_RIG2  %% accidentally wrote 'B' instead of '8' in animal id

% n=n+1;
% files(n).subj = 'EEB1LT'; %animal name
% files(n).expt = '010621'; %date of experiment
% files(n).topox= '010621_EEB1LT_RIG2\010621_EEB1LT_RIG2_TOPOX\010621_EEB1LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '010621_EEB1LT_RIG2\010621_EEB1LT_RIG2_TOPOX\010621_EEB1LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '010621_EEB1LT_RIG2\010621_EEB1LT_RIG2_TOPOY\010621_EEB1LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '010621_EEB1LT_RIG2\010621_EEB1LT_RIG2_TOPOY\010621_EEB1LT_RIG2_TOPOY';
% files(n).thresh = '010621_EEB1LT_RIG2\010621_EEB1LT_RIG2_THRESH\010621_EEB1LT_RIG2_THRESH';
% files(n).threshdata = '010621_EEB1LT_RIG2\010621_EEB1LT_RIG2_THRESH\010621_EEB1LT_RIG2_THRESH';
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% files(n).notes = ' ';

%% 010721_G6H277RT_RIG2  

% n=n+1;
% files(n).subj = 'G6H277RT'; %animal name
% files(n).expt = '010721'; %date of experiment
% files(n).topox= '010721_G6H277RT_RIG2\010721_G6H277RT_RIG2_TOPOX\010721_G6H277RT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '010721_G6H277RT_RIG2\010721_G6H277RT_RIG2_TOPOX\010721_G6H277RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '010721_G6H277RT_RIG2\010721_G6H277RT_RIG2_TOPOY\010721_G6H277RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '010721_G6H277RT_RIG2\010721_G6H277RT_RIG2_TOPOY\010721_G6H277RT_RIG2_TOPOY';
% files(n).thresh = '010721_G6H277RT_RIG2\010721_G6H277RT_RIG2_THRESH\010721_G6H277RT_RIG2_THRESH';
% files(n).threshdata = '010721_G6H277RT_RIG2\010721_G6H277RT_RIG2_THRESH\010721_G6H277RT_RIG2_THRESH';
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% files(n).notes = ' ';
% 
% %% 010621_EE8LT_RIG2  %% accidentally wrote 'B' instead of '8' in animal id
% 
% n=n+1;
% files(n).subj = 'EE81LT'; %animal name
% files(n).expt = '010621'; %date of experiment
% files(n).topox= '010621_EE81LT_RIG2\010621_EE81LT_RIG2_TOPOX\010621_EE81LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '010621_EE81LT_RIG2\010621_EE81LT_RIG2_TOPOX\010621_EE81LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '010621_EE81LT_RIG2\010621_EE81LT_RIG2_TOPOY\010621_EE81LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '010621_EE81LT_RIG2\010621_EE81LT_RIG2_TOPOY\010621_EE81LT_RIG2_TOPOY';
% files(n).thresh = '010621_EE81LT_RIG2\010621_EE81LT_RIG2_THRESH\010621_EE81LT_RIG2_THRESH';
% files(n).threshdata = '010621_EE81LT_RIG2\010621_EE81LT_RIG2_THRESH\010621_EE81LT_RIG2_THRESH';
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';

% %% '112520_EE81RT_RIG2  
% 
% n=n+1;
% files(n).subj = 'EE81RT'; %animal name
% files(n).expt = '112520'; %date of experiment
% files(n).topox= '112520_EE81RT_RIG2\112520_EE81RT_RIG2_TOPOX\112520_EE81RT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '112520_EE81RT_RIG2\112520_EE81RT_RIG2_TOPOX\112520_EE81RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '112520_EE81RT_RIG2\112520_EE81RT_RIG2_TOPOY\112520_EE81RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '112520_EE81RT_RIG2\112520_EE81RT_RIG2_TOPOY\112520_EE81RT_RIG2_TOPOY';
% 
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% %% 112420_EE81RN_RIG2  
% 
% n=n+1;
% files(n).subj = 'EE81RN'; %animal name 
% files(n).expt = '112420'; %date of experiment
% files(n).topox= '112420_EE81RN_RIG2\112420_EE81RN_RIG2_TOPOX\112420_EE81RN_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '112420_EE81RN_RIG2\112420_EE81RN_RIG2_TOPOX\112420_EE81RN_RIG2_TOPOX'; %raw data
% files(n).topoy = '112420_EE81RN_RIG2\112420_EE81RN_RIG2_TOPOY\112420_EE81RN_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '112420_EE81RN_RIG2\112420_EE81RN_RIG2_TOPOY\112420_EE81RN_RIG2_TOPOY';
% 
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% %% 112420_EE81LT_RIG2  
% 
% n=n+1;
% files(n).subj = 'EE81LT'; %animal name
% files(n).expt = '112420'; %date of experiment
% files(n).topox= '112420_EE81LT_RIG2\112420_EE81LT_RIG2_TOPOX\112420_EE81LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '112420_EE81LT_RIG2\112420_EE81LT_RIG2_TOPOX\112420_EE81LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '112420_EE81LT_RIG2\112420_EE81LT_RIG2_TOPOY\112420_EE81LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '112420_EE81LT_RIG2\112420_EE81LT_RIG2_TOPOY\112420_EE81LT_RIG2_TOPOY';
% 
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% %% 112420_G6H277LT_RIG2  
% 
% n=n+1;
% files(n).subj = 'G6H277LT'; %animal name
% files(n).expt = '112420'; %date of experiment
% files(n).topox= '112420_G6H277LT_RIG2\112420_G6H277LT_RIG2_TOPOX\112420_G6H277LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '112420_G6H277LT_RIG2\112420_G6H277LT_RIG2_TOPOX\112420_G6H277LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '112420_G6H277LT_RIG2\112420_G6H277LT_RIG2_TOPOY\112420_G6H277LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '112420_G6H277LT_RIG2\112420_G6H277LT_RIG2_TOPOY\112420_G6H277LT_RIG2_TOPOY';
% 
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% %% 111720_G6H277RT_RIG2   
% 
% n=n+1;
% files(n).subj = 'G6H277RT'; %animal name
% files(n).expt = '111720'; %date of experiment
% files(n).topox= '111720_G6H277RT_RIG2\111720_G6H277RT_RIG2_TOPOX\111720_G6H277RT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '111720_G6H277RT_RIG2\111720_G6H277RT_RIG2_TOPOX\111720_G6H277RT_RIG2_TOPOX'; %raw data
% files(n).topoy = '111720_G6H277RT_RIG2\111720_G6H277RT_RIG2_TOPOY\111720_G6H277RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '111720_G6H277RT_RIG2\111720_G6H277RT_RIG2_TOPOY\111720_G6H277RT_RIG2_TOPOY';
% 
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% %% 111620_G6H277TT_RIG2  
% 
% n=n+1;
% files(n).subj = 'G6H277TT'; %animal name
% files(n).expt = '111620'; %date of experiment
% files(n).topox= '111620_G6H277TT_RIG2\111620_G6H277TT_RIG2_TOPOX\111620_G6H277TT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '111620_G6H277TT_RIG2\111620_G6H277TT_RIG2_TOPOX\111620_G6H277TT_RIG2_TOPOX'; %raw data
% files(n).topoy = '111620_G6H277TT_RIG2\111620_G6H277TT_RIG2_TOPOY\111620_G6H277TT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '111620_G6H277TT_RIG2\111620_G6H277TT_RIG2_TOPOY\111620_G6H277TT_RIG2_TOPOY';
% 
% files(n).inject = 'none'; 
% files(n).dose = 'none';
% files(n).virus = 'none'
% files(n).timing = 'none';
% files(n).training = 'naive';
% files(n).area = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'none'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';

%% LP %%

%% CASP3-cre in calb2cre-g6 mice:   4x3y

% %% 050920_CALB2CK2G6_93RT_RIG2 @ 1.0 mg/kg SQ LP    
% 
% % pre
% n=n+1;
% files(n).subj = 'CALB2CK2G6_93RT'; %animal name
% files(n).expt = '052020'; %date of experiment
% files(n).topox= '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOX\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOX\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOY\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOY\052020_CALB2CK2G6_93RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_PRE_FOURXTHREEY\052020_CALB2CK2G6_93RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_PRE_FOURXTHREEY\052020_CALB2CK2G6_93RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg';
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% % post
% n=n+1;
% files(n).subj = 'CALB2CK2G6_93RT'; %animal name
% files(n).expt = '052020'; %date of experiment
% files(n).topox= '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOX\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOX\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOY\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOY\052020_CALB2CK2G6_93RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_POST_FOURXTHREEY\052020_CALB2CK2G6_93RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '052020_CALB2CK2G6_93RT_RIG2\052020_CALB2CK2G6_93RT_RIG2_POST_FOURXTHREEY\052020_CALB2CK2G6_93RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% % files(n).notes = ' ';

%% 050920_CALB2CK2G6_93LN_RIG2 @ 1.0 mg/kg SQ LP    

% pre
% n=n+1;
% files(n).subj = 'CALB2CK2G6_93LN'; %animal name
% files(n).expt = '052020'; %date of experiment
% files(n).topox= '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOX\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOX\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOY\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOY\052020_CALB2CK2G6_93LN_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_PRE_FOURXTHREEY\052020_CALB2CK2G6_93LN_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_PRE_FOURXTHREEY\052020_CALB2CK2G6_93LN_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg';
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% % post
% n=n+1;
% files(n).subj = 'CALB2CK2G6_93LN'; %animal name
% files(n).expt = '052020'; %date of experiment
% files(n).topox= '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOX\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOX\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOY\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOY\052020_CALB2CK2G6_93LN_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_POST_FOURXTHREEY\052020_CALB2CK2G6_93LN_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '052020_CALB2CK2G6_93LN_RIG2\052020_CALB2CK2G6_93LN_RIG2_POST_FOURXTHREEY\052020_CALB2CK2G6_93LN_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% % files(n).notes = ' ';
% 
%% 050920_CALB2CK2G6_95RN_RIG2 @ 1.0 mg/kg SQ LP    

% % pre
% n=n+1;
% files(n).subj = 'CALB2CK2G6_95RN'; %animal name
% files(n).expt = '050920'; %date of experiment
% files(n).topox= '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOX\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOX\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOY\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOY\050920_CALB2CK2G6_95RN_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_PRE_FOURXTHREEY\050920_CALB2CK2G6_95RN_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_PRE_FOURXTHREEY\050920_CALB2CK2G6_95RN_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg';
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'; %def started using 'fix' version before this... shortly after Phil fixed it
% % files(n).notes = ' ';
% 
% % post
% n=n+1;
% files(n).subj = 'CALB2CK2G6_95RN'; %animal name
% files(n).expt = '050920'; %date of experiment
% files(n).topox= '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOX\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOX\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOY\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOY\050920_CALB2CK2G6_95RN_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_POST_FOURXTHREEY\050920_CALB2CK2G6_95RN_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '050920_CALB2CK2G6_95RN_RIG2\050920_CALB2CK2G6_95RN_RIG2_POST_FOURXTHREEY\050920_CALB2CK2G6_95RN_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = ' ';

% %% CALB2CK2G6H83LN - no injection ***this session saw topoy both times (no topox)***
% 
% no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H83LN'; 
% files(n).expt = '030520'; 
% files(n).topox= '030520_CALB2CK2G6H83LN_RIG2\030520_CALB2CK2G6H83LN_RIG2_TOPOX\030520_CALB2CK2G6H83LN_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '030520_CALB2CK2G6H83LN_RIG2\030520_CALB2CK2G6H83LN_RIG2_TOPOX\030520_CALB2CK2G6H83LN_RIG2_TOPOX'; %raw data
% files(n).topoy = '030520_CALB2CK2G6H83LN_RIG2\030520_CALB2CK2G6H83LN_RIG2_TOPOY\030520_CALB2CK2G6H83LN_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '030520_CALB2CK2G6H83LN_RIG2\030520_CALB2CK2G6H83LN_RIG2_TOPOY\030520_CALB2CK2G6H83LN_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '030520_CALB2CK2G6H83LN_RIG2\030520_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\030520_CALB2CK2G6H83LN_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '030520_CALB2CK2G6H83LN_RIG2\030520_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\030520_CALB2CK2G6H83LN_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% % files(n).notes = 'good data';

% 
% %% CALB2CK2G6H92LT - no injection *misnamed this mouse on day of imaging*
% % misnamed date too, was really 3/5
% 
% % no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H83LT'; 
% files(n).expt = '030420'; 
% files(n).topox= '030420_CALB2CK2G6H83LT_RIG2\030420_CALB2CK2G6H83LT_RIG2_TOPOX\030420_CALB2CK2G6H83LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '030420_CALB2CK2G6H83LT_RIG2\030420_CALB2CK2G6H83LT_RIG2_TOPOX\030420_CALB2CK2G6H83LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '030420_CALB2CK2G6H83LT_RIG2\030420_CALB2CK2G6H83LT_RIG2_TOPOY\030420_CALB2CK2G6H83LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '030420_CALB2CK2G6H83LT_RIG2\030420_CALB2CK2G6H83LT_RIG2_TOPOY\030420_CALB2CK2G6H83LT_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '030420_CALB2CK2G6H83LT_RIG2\030420_CALB2CK2G6H83LT_RIG2_FOURXTHREEY\030420_CALB2CK2G6H83LT_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '030420_CALB2CK2G6H83LT_RIG2\030420_CALB2CK2G6H83LT_RIG2_FOURXTHREEY\030420_CALB2CK2G6H83LT_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% % files(n).notes = 'good data';
% 
% %% CALB2CK2G6H83LN - no injection
% 
% % no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H83LN'; 
% files(n).expt = '030420'; 
% files(n).topox= '030420_CALB2CK2G6H83LN_RIG2\030420_CALB2CK2G6H83LN_RIG2_TOPOX\030420_CALB2CK2G6H83LN_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '030420_CALB2CK2G6H83LN_RIG2\030420_CALB2CK2G6H83LN_RIG2_TOPOX\030420_CALB2CK2G6H83LN_RIG2_TOPOX'; %raw data
% files(n).topoy = '030420_CALB2CK2G6H83LN_RIG2\030420_CALB2CK2G6H83LN_RIG2_TOPOY\030420_CALB2CK2G6H83LN_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '030420_CALB2CK2G6H83LN_RIG2\030420_CALB2CK2G6H83LN_RIG2_TOPOY\030420_CALB2CK2G6H83LN_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '030420_CALB2CK2G6H83LN_RIG2\030420_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\030420_CALB2CK2G6H83LN_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '030420_CALB2CK2G6H83LN_RIG2\030420_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\030420_CALB2CK2G6H83LN_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';

% %% CALB2CK2G6H92LT - no injection
% 
% % no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H92LT'; 
% files(n).expt = '030420'; 
% files(n).topox= '030420_CALB2CK2G6H92LT_RIG2\030420_CALB2CK2G6H92LT_RIG2_TOPOX\030420_CALB2CK2G6H92LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '030420_CALB2CK2G6H92LT_RIG2\030420_CALB2CK2G6H92LT_RIG2_TOPOX\030420_CALB2CK2G6H92LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '030420_CALB2CK2G6H92LT_RIG2\030420_CALB2CK2G6H92LT_RIG2_TOPOY\030420_CALB2CK2G6H92LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '030420_CALB2CK2G6H92LT_RIG2\030420_CALB2CK2G6H92LT_RIG2_TOPOY\030420_CALB2CK2G6H92LT_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '030420_CALB2CK2G6H92LT_RIG2\030420_CALB2CK2G6H92LT_RIG2_FOURXTHREEY\030420_CALB2CK2G6H92LT_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '030420_CALB2CK2G6H92LT_RIG2\030420_CALB2CK2G6H92LT_RIG2_FOURXTHREEY\030420_CALB2CK2G6H92LT_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';

%% CALB2CK2G6H83LN - no injection

% no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H83LN'; 
% files(n).expt = '022020'; 
% files(n).topox= '022020_CALB2CK2G6H83LN_RIG2\022020_CALB2CK2G6H83LN_RIG2_TOPOX\022020_CALB2CK2G6H83LN_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '022020_CALB2CK2G6H83LN_RIG2\022020_CALB2CK2G6H83LN_RIG2_TOPOX\022020_CALB2CK2G6H83LN_RIG2_TOPOX'; %raw data
% files(n).topoy = '022020_CALB2CK2G6H83LN_RIG2\022020_CALB2CK2G6H83LN_RIG2_TOPOY\022020_CALB2CK2G6H83LN_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '022020_CALB2CK2G6H83LN_RIG2\022020_CALB2CK2G6H83LN_RIG2_TOPOY\022020_CALB2CK2G6H83LN_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '022020_CALB2CK2G6H83LN_RIG2\022020_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\022020_CALB2CK2G6H83LN_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '022020_CALB2CK2G6H83LN_RIG2\022020_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\022020_CALB2CK2G6H83LN_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';
% 
% %% CALB2CK2G6H92LT - no injection
% 
% % no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H92LT'; 
% files(n).expt = '022020'; 
% files(n).topox= '022020_CALB2CK2G6H92LT_RIG2\022020_CALB2CK2G6H92LT_RIG2_TOPOX\022020_CALB2CK2G6H92LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '022020_CALB2CK2G6H92LT_RIG2\022020_CALB2CK2G6H92LT_RIG2_TOPOX\022020_CALB2CK2G6H92LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '022020_CALB2CK2G6H92LT_RIG2\022020_CALB2CK2G6H92LT_RIG2_TOPOY\022020_CALB2CK2G6H92LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '022020_CALB2CK2G6H92LT_RIG2\022020_CALB2CK2G6H92LT_RIG2_TOPOY\022020_CALB2CK2G6H92LT_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '022020_CALB2CK2G6H92LT_RIG2\022020_CALB2CK2G6H92LT_RIG2_FOURXTHREEY\022020_CALB2CK2G6H92LT_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '022020_CALB2CK2G6H92LT_RIG2\022020_CALB2CK2G6H92LT_RIG2_FOURXTHREEY\022020_CALB2CK2G6H92LT_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';

%% CALB2CK2G6H83LN - no injection

% no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H83LN'; 
% files(n).expt = '022120'; 
% files(n).topox= '022120_CALB2CK2G6H83LN_RIG2\022120_CALB2CK2G6H83LN_RIG2_TOPOX\022120_CALB2CK2G6H83LN_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '022120_CALB2CK2G6H83LN_RIG2\022120_CALB2CK2G6H83LN_RIG2_TOPOX\022120_CALB2CK2G6H83LN_RIG2_TOPOX'; %raw data
% files(n).topoy = '022120_CALB2CK2G6H83LN_RIG2\022120_CALB2CK2G6H83LN_RIG2_TOPOY\022120_CALB2CK2G6H83LN_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '022120_CALB2CK2G6H83LN_RIG2\022120_CALB2CK2G6H83LN_RIG2_TOPOY\022120_CALB2CK2G6H83LN_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '022120_CALB2CK2G6H83LN_RIG2\022120_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\022120_CALB2CK2G6H83LN_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '022120_CALB2CK2G6H83LN_RIG2\022120_CALB2CK2G6H83LN_RIG2_FOURXTHREEY\022120_CALB2CK2G6H83LN_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';
% 
% %% CALB2CK2G6H92LT - no injection
% 
% % no pre-post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H92LT'; 
% files(n).expt = '022120'; 
% files(n).topox= '022120_CALB2CK2G6H92LT_RIG2\022120_CALB2CK2G6H92LT_RIG2_TOPOX\022120_CALB2CK2G6H92LT_RIG2_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '022120_CALB2CK2G6H92LT_RIG2\022120_CALB2CK2G6H92LT_RIG2_TOPOX\022120_CALB2CK2G6H92LT_RIG2_TOPOX'; %raw data
% files(n).topoy = '022120_CALB2CK2G6H92LT_RIG2\022120_CALB2CK2G6H92LT_RIG2_TOPOY\022120_CALB2CK2G6H92LT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '022120_CALB2CK2G6H92LT_RIG2\022120_CALB2CK2G6H92LT_RIG2_TOPOY\022120_CALB2CK2G6H92LT_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '022120_CALB2CK2G6H92LT_RIG2\022120_CALB2CK2G6H92LT_RIG2_FOURXTHREEY\022120_CALB2CK2G6H92LT_RIG2_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '022120_CALB2CK2G6H92LT_RIG2\022120_CALB2CK2G6H92LT_RIG2_FOURXTHREEY\022120_CALB2CK2G6H92LT_RIG2_FOURXTHREEY';
% files(n).inject = 'none'; 
% % files(n).dose = '0.15 mL' 
% files(n).virus = 'caspase3';
% files(n).timing = 'post'; % 'post' only for sake of comparative analysis
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good data';

%% Cre-dep dreadds in calb2cre-ck2-g6 mice:    4x3y

%% 012320_CALB2CK2G6H47RT_RIG2 @ 1.0 mg/kg SQ LP    

% % pre
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47RT'; %animal name
% files(n).expt = '012320'; %date of experiment
% files(n).topox= '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012320_CALB2CK2G6H47RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg';
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';
% 
% % post
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47RT'; %animal name
% files(n).expt = '012320'; %date of experiment
% files(n).topox= '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOX\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOX\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012320_CALB2CK2G6H47RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012320_CALB2CK2G6H47RT_RIG2\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012320_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';

%%  012820_CALB2CK2G6H47RT_RIG2 @ 1.0 mg/kg SQ LP
% NOTE: named 'POST_TOPOX' as 'POST_FOURXTHREEX' by accident
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47RT'; %animal name
% files(n).expt = '012820'; %date of experiment
% files(n).topox= '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H47RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47RT'; %animal name
% files(n).expt = '012820'; %date of experiment
% files(n).topox= '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOX\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEX\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEX'; %raw data
% files(n).topoy = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOY\012820_CALB2CK2G6H47RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H47RT_RIG2\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY\012820_CALB2CK2G6H47RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'calb2cre-ck2-gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';


%% CAV2-cre (V1) + cre-Dreadds (LP) in g6 ck2 mice:


% %% G6H203RT @ 0.15 mL SALINE     4x3y
% 
% % pre
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
% files(n).virus = 'CAV2-cre_cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';
% 
% % post
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
% files(n).virus = 'CAV2-cre_cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good expression';

% %% G6H203RT @ 1.0 mg/kg CLOZ    4x3y
% 
% % pre
% n=n+1;
% files(n).subj = 'G6H203RT'; %animal name
% files(n).expt = '083019'; %date of experiment
% files(n).topox= '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOX\083019_G6H203RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOX\083019_G6H203RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOY\083019_G6H203RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_TOPOY\083019_G6H203RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_FOURXTHREEY\083019_G6H203RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_PRE_FOURXTHREEY\083019_G6H203RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'CAV2-cre_cre-hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good expression';
% 
% % post
% n=n+1;
% files(n).subj = 'G6H203RT'; %animal name
% files(n).expt = '083019'; %date of experiment
% files(n).topox= '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOX\083019_G6H203RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOX\083019_G6H203RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOY\083019_G6H203RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_TOPOY\083019_G6H203RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_FOURXTHREEY\083019_G6H203RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '083019_G6H203RT_RIG2\083019_G6H203RT_RIG2_POST_FOURXTHREEY\083019_G6H203RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg' 
% files(n).virus = 'CAV2-cre_cre-hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat';
% files(n).notes = 'good expression';

% %% non-cre-Dreadds in g6h mice:
% 
% 
% %% *OLD cloz* G6H127RT @ 0.5 mg/kg   patch
% 
% %pre
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '020519'; %date of experiment
% files(n).topox= '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOX\020519_G6H127RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOX\020519_G6H127RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOY\020519_G6H127RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_TOPOY\020519_G6H127RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_PATCHONPATCH\020519_G6H127RT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_PRE_PATCHONPATCH\020519_G6H127RT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).moviename = 'C:\patchonpatch10min';
% files(n).notes = 'old cloz';
% 
% 
% % post
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '020519'; %date of experiment
% files(n).topox= '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOX\020519_G6H127RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOX\020519_G6H127RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOY\020519_G6H127RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_TOPOY\020519_G6H127RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_PATCHONPATCH\020519_G6H127RT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '020519_G6H127RT_RIG2\020519_G6H127RT_RIG2_POST_PATCHONPATCH\020519_G6H127RT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).moviename = 'C:\patchonpatch10min';
% files(n).notes = 'old cloz';
% 
% 
% %% G6H127RT @ (probably) 0.5 mg/kg   patch
% 
% % pre
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '021319'; %date of experiment
% files(n).topox= '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOX\021319_G6H127RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOX\021319_G6H127RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOY\021319_G6H127RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_TOPOY\021319_G6H127RT_RIG2_PRE_TOPOY';
% files(n).patchonpatch =  '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_PATCHONPATCH\021319_G6H127RT_RIG2_PRE_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_PRE_PATCHONPATCH\021319_G6H127RT_RIG2_PRE_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).moviename = 'C:\patchonpatch10min';
% files(n).notes = 'good expression';
% 
% 
% % post
% n=n+1;
% files(n).subj = 'G6H127RT'; %animal name
% files(n).expt = '021319'; %date of experiment
% files(n).topox= '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOX\021319_G6H127RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOX\021319_G6H127RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOY\021319_G6H127RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_TOPOY\021319_G6H127RT_RIG2_POST_TOPOY';
% files(n).patchonpatch =  '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_PATCHONPATCH\021319_G6H127RT_RIG2_POST_PATCHONPATCHmaps.mat';
% files(n).patchonpatchdata = '021319_G6H127RT_RIG2\021319_G6H127RT_RIG2_POST_PATCHONPATCH\021319_G6H127RT_RIG2_POST_PATCHONPATCH';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).moviename = 'C:\patchonpatch10min';
% files(n).notes = 'good expression';
% 
% 
% %% G6H137TT @ 1.0 mg/kg     3x2y    LAND
% 
% %pre
% n=n+1;
% files(n).subj = 'G6H137TT'; %animal name
% files(n).expt = '060819'; %date of experiment
% files(n).topox= '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOX\060819_G6H137TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOX\060819_G6H137TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOY\060819_G6H137TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_TOPOY\060819_G6H137TT_RIG2_PRE_TOPOY';
% files(n).grating3x2y6sf4tf =  '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_THREEXTWOY\060819_G6H137TT_RIG2_PRE_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_PRE_THREEXTWOY\060819_G6H137TT_RIG2_PRE_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good expression';

% post
% n=n+1;
% files(n).subj = 'G6H137TT'; %animal name
% files(n).expt = '060819'; %date of experiment
% files(n).topox= '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOX\060819_G6H137TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOX\060819_G6H137TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOY\060819_G6H137TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_TOPOY\060819_G6H137TT_RIG2_POST_TOPOY';
% files(n).grating3x2y6sf4tf =  '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_THREEXTWOY\060819_G6H137TT_RIG2_POST_THREEXTWOYmaps.mat';
% files(n).grating3x2y6sf4tfdata = '060819_G6H137TT_RIG2\060819_G6H137TT_RIG2_POST_THREEXTWOY\060819_G6H137TT_RIG2_POST_THREEXTWOY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land'; 
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename = 'C:\grating3x2y6sf4tf_1728sec.mat'
% files(n).notes = 'good expression';

% %% G6H137TT @ 1.0 mg/kg      4x3y   VERT
% 
% %pre
% n=n+1;
% files(n).subj = 'G6H137TT'; %animal name
% files(n).expt = '052419'; %date of experiment
% files(n).topox= '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOX\052419_G6H137TT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOX\052419_G6H137TT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOY\052419_G6H137TT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_TOPOY\052419_G6H137TT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_FOURXTHREEY\052419_G6H137TT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_PRE_FOURXTHREEY\052419_G6H137TT_RIG2_PRE_FOURXTHREEY';
% % grating4x3y6sf3tf
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';
% 
% % post
% n=n+1;
% files(n).subj = 'G6H137TT'; %animal name
% files(n).expt = '052419'; %date of experiment
% files(n).topox= '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOX\052419_G6H137TT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOX\052419_G6H137TT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOY\052419_G6H137TT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_TOPOY\052419_G6H137TT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECT\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECTmaps.mat';
% files(n).grating4x3y5sf3tfdata = '052419_G6H137TT_RIG2\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECT\052419_G6H137TT_RIG2_POST_FOURXTHREEYCORRECT';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'lp';
% files(n).rignum = 'rig2';
% files(n).monitor = 'vert';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good expression';

%% CLOZ only, all vert

%% G6H113LT non-dreadds @ 0.5 mg/kg cloz **really 4x3y  VERT
% n=n+1;
% files(n).subj = 'G6H113LT'; %animal name
% files(n).expt = '051719'; %date of experiment
% files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOX\051719_G6H113LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_TOPOY\051719_G6H113LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_PRE_THREEXFOURY\051719_G6H113LT_RIG2_PRE_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
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
% files(n).subj = 'G6H113LT'; %animal name
% files(n).expt = '051719'; %date of experiment
% files(n).topox= '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOX\051719_G6H113LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOX\051719_G6H113LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOY\051719_G6H113LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_TOPOY\051719_G6H113LT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '051719_G6H113LT_RIG2\051719_G6H113LT_RIG2_POST_THREEXFOURY\051719_G6H113LT_RIG2_POST_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '0.5 mg/kg'
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

%% G6H146LT non-dreadds @ 0.1 mg/kg cloz **really 4x3y VERT
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

%% G6H141RT non-dreadds @ 1.0 mg/kg, VERT - here I changed data file name to correctly reflect stim name (4x3y)
% n=n+1;
% files(n).subj = 'G6H141RT'; %animal name
% files(n).expt = '051819'; %date of experiment
% files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOX\051819_G6H141RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_TOPOY\051819_G6H141RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_PRE_FOURXTHREEY\051819_G6H141RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg';
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
% files(n).subj = 'G6H141RT'; %animal name
% files(n).expt = '051819'; %date of experiment
% files(n).topox= '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOX\051819_G6H141RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOX\051819_G6H141RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOY\051819_G6H141RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_TOPOY\051819_G6H141RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '051819_G6H141RT_RIG2\051819_G6H141RT_RIG2_POST_FOURXTHREEY\051819_G6H141RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg/kg';
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

%%  G6H23RT @ 1.0 mg/kg SQ V1 ***virus wrong... should be cav2cre + cre-d dreadds for all V1 mice***
% % NOTE: I named these guys wrong when recording (3x4y) so having to switch
% % that here... the stim was really 4x3y. 
% % NOTE: I also named the mouse 23RT instead of it's real name, 233RT. 
% n=n+1;
% files(n).subj = 'G6H23RT'; %animal name
% files(n).expt = '011720'; %date of experiment
% files(n).topox= '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_PRE_TOPOX\011720_G6H23RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_PRE_TOPOX\011720_G6H23RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_PRE_TOPOY\011720_G6H23RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_PRE_TOPOY\011720_G6H23RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_PRE_THREEXFOURY\011720_G6H23RT_RIG2_PRE_THREEXFOURYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_PRE_THREEXFOURY\011720_G6H23RT_RIG2_PRE_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H23RT'; %animal name
% files(n).expt = '011720'; %date of experiment
% files(n).topox= '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_POST_TOPOX\011720_G6H23RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_POST_TOPOX\011720_G6H23RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_POST_TOPOY\011720_G6H23RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_POST_TOPOY\011720_G6H23RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_POST_THREEXFOURY\011720_G6H23RT_RIG2_POST_THREEXFOURYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '011720_G6H23RT_RIG2\011720_G6H23RT_RIG2_POST_THREEXFOURY\011720_G6H23RT_RIG2_POST_THREEXFOURY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di';
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%%  G6H23RT @ 1.0 mg/kg IP V1
% NOTE: I named the mouse 23RT instead of it's real name, 233RT. 
% n=n+1;
% files(n).subj = 'G6H23RT'; %animal name
% files(n).expt = '012020'; %date of experiment
% files(n).topox= '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_PRE_TOPOX\012020_G6H23RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_PRE_TOPOX\012020_G6H23RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_PRE_TOPOY\012020_G6H23RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_PRE_TOPOY\012020_G6H23RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_PRE_FOURXTHREEY\012020_G6H23RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_PRE_FOURXTHREEY\012020_G6H23RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H23RT'; %animal name
% files(n).expt = '012020'; %date of experiment
% files(n).topox= '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_POST_TOPOX\012020_G6H23RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_POST_TOPOX\012020_G6H23RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_POST_TOPOY\012020_G6H23RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_POST_TOPOY\012020_G6H23RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_POST_FOURXTHREEY\012020_G6H23RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012020_G6H23RT_RIG2\012020_G6H23RT_RIG2_POST_FOURXTHREEY\012020_G6H23RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).virus = 'hM4Di';
% files(n).rignum = 'rig2';
% files(n).area = 'V1';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';

% %%  012920_G6H23RT_RIG2 @ 1.0 mg/kg SQ V1
% 
% n=n+1;
% files(n).subj = 'G6H23RT'; %animal name
% files(n).expt = '012920'; %date of experiment
% files(n).topox= '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_PRE_TOPOX\012920_G6H23RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_PRE_TOPOX\012920_G6H23RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_PRE_TOPOY\012920_G6H23RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_PRE_TOPOY\012920_G6H23RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_PRE_FOURXTHREEY\012920_G6H23RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_PRE_FOURXTHREEY\012920_G6H23RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H23RT'; %animal name
% files(n).expt = '012920'; %date of experiment
% files(n).topox= '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_POST_TOPOX\012920_G6H23RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_POST_TOPOX\012920_G6H23RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_POST_TOPOY\012920_G6H23RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_POST_TOPOY\012920_G6H23RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_POST_FOURXTHREEY\012920_G6H23RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012920_G6H23RT_RIG2\012920_G6H23RT_RIG2_POST_FOURXTHREEY\012920_G6H23RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).virus = 'hM4Di'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).genotype = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';