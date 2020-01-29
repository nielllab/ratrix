%% batch V1 4X3Y

n = 0;
pathname = 'F:\Kristen\V1_Imaging_20\'
% pathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% pathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% pathname = 'D:\Kristen\'
datapathname = 'F:\Kristen\V1_Imaging_20\'
% datapathname = '\\LANGEVIN\backup\Kristen\winter_19\';  
% datapathname = 'D:\Kristen\LGN_Dreadds_WF_Imaging\'
% datapathname = 'D:\Kristen\'
outpathname = 'F:\Kristen\V1_Imaging_20\'
% outpathname = '\\langevin\backup\Kristen\output_LGN_Dreadds_WF_Imaging\'
% outpathname = '\\LANGEVIN\backup\Kristen\winter_19\';
% outpathname = 'D:\Kristen\'

%%  G6H23RT @ 1.0 mg/kg SQ V1
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
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
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
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
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
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
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
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%%  G6H233LT @ 1.0 mg/kg SQ V1
% n=n+1;
% files(n).subj = 'G6H233LT'; %animal name
% files(n).expt = '012020'; %date of experiment
% files(n).topox= '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_PRE_TOPOX\012020_G6H233LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_PRE_TOPOX\012020_G6H233LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_PRE_TOPOY\012020_G6H233LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_PRE_TOPOY\012020_G6H233LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_PRE_FOURXTHREEY\012020_G6H233LT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_PRE_FOURXTHREEY\012020_G6H233LT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H233LT'; %animal name
% files(n).expt = '012020'; %date of experiment
% files(n).topox= '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_POST_TOPOX\012020_G6H233LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_POST_TOPOX\012020_G6H233LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_POST_TOPOY\012020_G6H233LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_POST_TOPOY\012020_G6H233LT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_POST_FOURXTHREEY\012020_G6H233LT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012020_G6H233LT_RIG2\012020_G6H233LT_RIG2_POST_FOURXTHREEY\012020_G6H233LT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%%  G6H233RN @ 1.0 mg/kg --> SQ V1
% n=n+1;
% files(n).subj = 'G6H233RN'; %animal name
% files(n).expt = '012020'; %date of experiment
% files(n).topox= '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_PRE_TOPOX\012020_G6H233RN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_PRE_TOPOX\012020_G6H233RN_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_PRE_TOPOY\012020_G6H233RN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_PRE_TOPOY\012020_G6H233RN_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_PRE_FOURXTHREEY\012020_G6H233RN_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_PRE_FOURXTHREEY\012020_G6H233RN_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'G6H233RN'; %animal name
% files(n).expt = '012020'; %date of experiment
% files(n).topox= '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_POST_TOPOX\012020_G6H233RN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_POST_TOPOX\012020_G6H233RN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_POST_TOPOY\012020_G6H233RN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_POST_TOPOY\012020_G6H233RN_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_POST_FOURXTHREEY\012020_G6H233RN_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012020_G6H233RN_RIG2\012020_G6H233RN_RIG2_POST_FOURXTHREEY\012020_G6H233RN_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'V1';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
%%  012220_CALB2CK2G6H53RT_RIG2 @ 1.0 mg/kg SQ LP
% n=n+1;
% files(n).subj = 'CALB2CK2G6H53RT'; %animal name
% files(n).expt = '012220'; %date of experiment
% files(n).topox= '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012220_CALB2CK2G6H53RT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP;
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'CALB2CK2G6H53RT'; %animal name
% files(n).expt = '012220'; %date of experiment
% files(n).topox= '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOX\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOX\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOY\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOY\012220_CALB2CK2G6H53RT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012220_CALB2CK2G6H53RT_RIG2\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY\012220_CALB2CK2G6H53RT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% %
%% 012220_CALB2CK2G6H47LT_RIG2 @ 1.0 mg/kg SQ LP
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
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
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
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% %
%% 012320_CALB2CK2G6H47RT_RIG2 @ 1.0 mg/kg SQ LP
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
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
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
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';
%%  012720_CALB2CK2G6H47LT_RIG2 @ 1.0 mg/kg SQ LP
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47LT'; %animal name
% files(n).expt = '012720'; %date of experiment
% files(n).topox= '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOX\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOX\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOX'; %raw data
% files(n).topoy = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOY\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOY\012720_CALB2CK2G6H47LT_RIG2_PRE_TOPOY';
% files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47LT'; %animal name
% files(n).expt = '012720'; %date of experiment
% files(n).topox= '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOX\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOX\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOY\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOY\012720_CALB2CK2G6H47LT_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47LT_RIG2\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47LT_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
%
%%  012720_CALB2CK2G6H47RN_RIG2 @ 1.0 mg/kg SQ LP
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47RN'; %animal name
% files(n).expt = '012720'; %date of experiment
% files(n).topox= '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOX\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_TOPOX\012720_CALB2CK2G6H47RN_RIG2_TOPOX'; %raw data
% files(n).topoy = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOY\012720_CALB2CK2G6H47RN_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_TOPOY\012720_CALB2CK2G6H47RN_RIG2_TOPOY';
% files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_PRE_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no';
% files(n).timing = 'pre';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';
% 
% % post
% 
% n=n+1;
% files(n).subj = 'CALB2CK2G6H47RN'; %animal name
% files(n).expt = '012720'; %date of experiment
% files(n).topox= '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOX\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOXmaps.mat'; %where to put dfof
% files(n).topoxdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOX\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOX'; %raw data
% files(n).topoy = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOY\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOYmaps.mat';
% files(n).topoydata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOY\012720_CALB2CK2G6H47RN_RIG2_POST_TOPOY';
% files(n).grating4x3y5sf3tf =  '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEYmaps.mat';
% files(n).grating4x3y5sf3tfdata = '012720_CALB2CK2G6H47RN_RIG2\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEY\012720_CALB2CK2G6H47RN_RIG2_POST_FOURXTHREEY';
% files(n).inject = 'CLOZ'; 
% files(n).dose = '1.0 mg_kg'
% files(n).controlvirus = 'no'
% files(n).timing = 'post';
% files(n).training = 'naive';
% files(n).area = 'LP';
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).label = 'camk2 gc6';
% files(n).imagerate = 10;
% files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
% files(n).notes = 'good data';

%%  012820_CALB2CK2G6H47RT_RIG2 @ 1.0 mg/kg SQ LP
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
files(n).controlvirus = 'no';
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
files(n).controlvirus = 'no'
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

n=n+1;
files(n).subj = 'CALB2CK2G6H53RT'; %animal name
files(n).expt = '012820'; %date of experiment
files(n).topox= '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOX\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOXmaps.mat'; %where to put dfof
files(n).topoxdata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_TOPOX\012820_CALB2CK2G6H53RT_RIG2_TOPOX'; %raw data
files(n).topoy = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOY\012820_CALB2CK2G6H53RT_RIG2_PRE_TOPOYmaps.mat';
files(n).topoydata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_TOPOY\012820_CALB2CK2G6H53RT_RIG2_TOPOY';
files(n).grating4x3y5sf3tf =  '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEYmaps.mat';
files(n).grating4x3y5sf3tfdata = '012820_CALB2CK2G6H53RT_RIG2\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY\012820_CALB2CK2G6H53RT_RIG2_PRE_FOURXTHREEY';
files(n).inject = 'CLOZ'; 
files(n).dose = '1.0 mg_kg'
files(n).controlvirus = 'no';
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
files(n).controlvirus = 'no'
files(n).timing = 'post';
files(n).training = 'naive';
files(n).area = 'LP';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).imagerate = 10;
files(n).moviename4x3y = 'C:\grating4x3y5sf3tf_short011315.mat'
files(n).notes = 'good data';