%%% batchBrettWidefield
dbstop if error

pathname = 'D:\Brett\';
datapathname = 'D:\Brett\';  
outpathname = 'D:\Brett\';

n=0; %%%start counting sessions

%% control
n=n+1;
files(n).subj = 'SERT-CK2-G6-2P2-TT'; %animal name
files(n).expt = '030620'; %%date
files(n).topox= '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness =  '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_CONTROL\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_CONTROLmaps.mat';
files(n).darknessdata = '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_CONTROL\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_CONTROL';
files(n).stepbinary = '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_CONTROL\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_CONTROLmaps.mat';
files(n).stepbinarydata =  '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_CONTROL\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_CONTROL';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'SERT-CK2-G6';
files(n).notes = 'good imaging session';
files(n).cond = 'control'; %control or opto
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';

%% opto
n=n+1;
files(n).subj = 'SERT-CK2-G6-2P2-TT'; %animal name
files(n).expt = '030620'; %%date
files(n).topox= '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness =  '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_OPTOG\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_OPTOGmaps.mat';
files(n).darknessdata = '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_OPTOG\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_DARKNESS_OPTOG';
files(n).stepbinary = '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_OPTOG\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_OPTOGmaps.mat';
files(n).stepbinarydata =  '030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_OPTOG\030620_SERT-CK2-G6-2P2-TT_DRNOPTO_RIG2_STEPBINARY_OPTOG';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'SERT-CK2-G6';
files(n).notes = 'good imaging session';
files(n).cond = 'opto'; %control or opto
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';

%% control
n=n+1;
files(n).subj = 'SERT-CK2-G6-4P2-LN'; %animal name
files(n).expt = '030620'; %%date
files(n).topox= '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness =  '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_CONTROL\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_CONTROLmaps.mat';
files(n).darknessdata = '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_CONTROL\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_CONTROL';
files(n).stepbinary = '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_CONTROL\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_CONTROLmaps.mat';
files(n).stepbinarydata =  '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_CONTROL\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_CONTROL';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'SERT-CK2-G6';
files(n).notes = 'good imaging session';
files(n).cond = 'control'; %control or opto
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';

%% opto
n=n+1;
files(n).subj = 'SERT-CK2-G6-4P2-LN'; %animal name
files(n).expt = '030620'; %%date
files(n).topox= '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness =  '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_OPTOG\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_OPTOGmaps.mat';
files(n).darknessdata = '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_OPTOG\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_DARKNESS_OPTOG';
files(n).stepbinary = '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_OPTOG\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_OPTOGmaps.mat';
files(n).stepbinarydata =  '030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_OPTOG\030620_SERT-CK2-G6-4P2-LN_DRNOPTO_RIG2_STEPBINARY_OPTOG';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'SERT-CK2-G6';
files(n).notes = 'good imaging session';
files(n).cond = 'opto'; %control or opto
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';


%% control
n=n+1;
files(n).subj = 'SERT-CK2-G6-2P2-RT'; %animal name
files(n).expt = '031020'; %%date
files(n).topox= '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness =  '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_CONTROL\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_CONTROLmaps.mat';
files(n).darknessdata = '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_CONTROL\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_CONTROL';
files(n).stepbinary = '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_CONTROL\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_CONTROLmaps.mat';
files(n).stepbinarydata =  '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_CONTROL\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_CONTROL';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'SERT-CK2-G6';
files(n).notes = 'good imaging session';
files(n).cond = 'control'; %control or opto
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';

%% opto
n=n+1;
files(n).subj = 'SERT-CK2-G6-2P2-RT'; %animal name
files(n).expt = '031020'; %%date
files(n).topox= '';
files(n).topoxdata = '';
files(n).topoy = '';
files(n).topoydata = '';
files(n).darkness =  '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_OPTOG\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_OPTOGmaps.mat';
files(n).darknessdata = '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_OPTOG\031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_DARKNESS_OPTOG';
files(n).stepbinary = '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_OPTOG\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_OPTOGmaps.mat';
files(n).stepbinarydata =  '031020_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_OPTOG\030620_SERT-CK2-G6-2P2-RT_DRNOPTO_RIG2_STEPBINARY_OPTOG';
files(n).imagerate = 10; %imaging rate in Hz (usually 10)
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'SERT-CK2-G6';
files(n).notes = 'good imaging session';
files(n).cond = 'opto'; %control or opto
files(n).ptsfile = 'F:\Mandi\EnrichmentWidefield\CrisPts.mat';