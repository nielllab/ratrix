dbstop if error
pathname = 'C:\Users\nlab\Desktop\Mapping for 2p\';
datapathname = 'C:\Users\nlab\Desktop\Mapping for 2p\';  
outpathname = 'C:\Users\nlab\Desktop\Mapping for 2p\';
n = 0;

% dbstop if error
% pathname = '\\langevin\backup\widefield\Phil\Mapping_2p\';
% datapathname = '\\langevin\backup\widefield\Phil\Mapping_2p\';  
% outpathname = '\\langevin\backup\widefield\Phil\Mapping_2p\';
% n = 0;
% % 
% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoxdata = '';
% files(n).topoy =  '';
% files(n).topoydata = '';
% files(n).inject = 'none';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'portrait'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% 
% 
% n=n+1;
% files(n).subj = 'G62CC5RT';
% files(n).expt = '053116';
% files(n).topox =  '053116_G62CC5RT_RIG2_NONE\053116_G62CC5RT_RIG2_NONE_TOPOX\053116_G62CC5RT_RIG2_NONE_TOPOXmaps.mat';
% files(n).topoxdata = '053116_G62CC5RT_RIG2_NONE\053116_G62CC5RT_RIG2_NONE_TOPOX\053116_G62CC5RT_RIG2_NONE_TOPOX';
% files(n).topoy =  '053116_G62CC5RT_RIG2_NONE\053116_G62CC5RT_RIG2_NONE_TOPOY\053116_G62CC5RT_RIG2_NONE_TOPOYmaps.mat';
% files(n).topoydata = '053116_G62CC5RT_RIG2_NONE\053116_G62CC5RT_RIG2_NONE_TOPOY\053116_G62CC5RT_RIG2_NONE_TOPOY';
% files(n).inject = 'none';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% 
% n=n+1;
% files(n).subj = 'G62CC5TT';
% files(n).expt = '053116';
% files(n).topox =  '053116_G62CC5TT_RIG2_NONE\053116_G62CC5TT_RIG2_NONE_TOPOX\053116_G62CC5TT_RIG2_NONE_TOPOXmaps.mat';
% files(n).topoxdata = '053116_G62CC5TT_RIG2_NONE\053116_G62CC5TT_RIG2_NONE_TOPOX\053116_G62CC5TT_RIG2_NONE_TOPOX';
% files(n).topoy =  '053116_G62CC5TT_RIG2_NONE\053116_G62CC5TT_RIG2_NONE_TOPOY\053116_G62CC5TT_RIG2_NONE_TOPOYmaps.mat';
% files(n).topoydata = '053116_G62CC5TT_RIG2_NONE\053116_G62CC5TT_RIG2_NONE_TOPOY\053116_G62CC5TT_RIG2_NONE_TOPOY';
% files(n).inject = 'none';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% 
% n=n+1;
% files(n).subj = 'G62TX1.8RT';
% files(n).expt = '053116';
% files(n).topox =  '053116_G62TX1.8LT_RIG2_NONE\053116_G62TX1.8LT_RIG2_NONE_TOPOX\053116_G62TX1.8LT_RIG2_NONE_TOPOXmaps.mat';
% files(n).topoxdata = '053116_G62TX1.8LT_RIG2_NONE\053116_G62TX1.8LT_RIG2_NONE_TOPOX\053116_G62TX1.8LT_RIG2_NONE_TOPOX';
% files(n).topoy =  '053116_G62TX1.8LT_RIG2_NONE\053116_G62TX1.8LT_RIG2_NONE_TOPOY\053116_G62TX1.8LT_RIG2_NONE_TOPOYmaps.mat';
% files(n).topoydata = '053116_G62TX1.8LT_RIG2_NONE\053116_G62TX1.8LT_RIG2_NONE_TOPOY\053116_G62TX1.8LT_RIG2_NONE_TOPOY';
% files(n).inject = 'none';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% %naming screwed up in files
% 
% n=n+1;
% files(n).subj = 'G62TX1.8LT';
% files(n).expt = '053116';
% files(n).topox =  '053116_G62TX1.8RT_RIG2_NONE\053116_G62TX1.8RT_RIG2_NONE_TOPOX\053116_G62TX1.8RT_RIG2_NONE_TOPOXmaps.mat';
% files(n).topoxdata = '053116_G62TX1.8RT_RIG2_NONE\053116_G62TX1.8RT_RIG2_NONE_TOPOX\053116_G62TX1.8RT_RIG2_NONE_TOPOX';
% files(n).topoy =  '053116_G62TX1.8RT_RIG2_NONE\053116_G62TX1.8RT_RIG2_NONE_TOPOY\053116_G62TX1.8RT_RIG2_NONE_TOPOYmaps.mat';
% files(n).topoydata = '053116_G62TX1.8RT_RIG2_NONE\053116_G62TX1.8RT_RIG2_NONE_TOPOY\053116_G62TX1.8RT_RIG2_NONE_TOPOY';
% files(n).inject = 'none';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% %naming screwed up in files
% 
% n=n+1;
% files(n).subj = 'G62TX1.9LN';
% files(n).expt = '053116';
% files(n).topox =  '053116_G62TX1.9LNT_RIG2_NONE\053116_G62TX1.9LNT_RIG2_NONE_TOPOX\053116_G62TX1.9LNT_RIG2_NONE_TOPOXmaps.mat';
% files(n).topoxdata = '053116_G62TX1.9LNT_RIG2_NONE\053116_G62TX1.9LNT_RIG2_NONE_TOPOX\053116_G62TX1.9LNT_RIG2_NONE_TOPOX';
% files(n).topoy =  '053116_G62TX1.9LNT_RIG2_NONE\053116_G62TX1.9LNT_RIG2_NONE_TOPOY\053116_G62TX1.9LNT_RIG2_NONE_TOPOYmaps.mat';
% files(n).topoydata = '053116_G62TX1.9LNT_RIG2_NONE\053116_G62TX1.9LNT_RIG2_NONE_TOPOY\053116_G62TX1.9LNT_RIG2_NONE_TOPOY';
% files(n).inject = 'none';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% %naming screwed up in files
% 
% n=n+1;
% files(n).subj = 'G62TX1.9LT';
% files(n).expt = '053116';
% files(n).topox =  '053116_G62TX1.9LT_RIG2_NONE\053116_G62TX1.9LT_RIG2_NONE_TOPOX\053116_G62TX1.9LT_RIG2_NONE_TOPOXmaps.mat';
% files(n).topoxdata = '053116_G62TX1.9LT_RIG2_NONE\053116_G62TX1.9LT_RIG2_NONE_TOPOX\053116_G62TX1.9LT_RIG2_NONE_TOPOX';
% files(n).topoy =  '053116_G62TX1.9LT_RIG2_NONE\053116_G62TX1.9LT_RIG2_NONE_TOPOY\053116_G62TX1.9LT_RIG2_NONE_TOPOYmaps.mat';
% files(n).topoydata = '053116_G62TX1.9LT_RIG2_NONE\053116_G62TX1.9LT_RIG2_NONE_TOPOY\053116_G62TX1.9LT_RIG2_NONE_TOPOY';
% files(n).inject = 'none';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% 
% n=n+1;
% files(n).subj = 'G62AA3TT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62AA3TT_2PMAP_RIG2\062616_G62AA3TT_2PMAP_RIG2_TOPOY\062616_G62AA3TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62AA3TT_2PMAP_RIG2\062616_G62AA3TT_2PMAP_RIG2_TOPOY\062616_G62AA3TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62AA3TT_2PMAP_RIG2\062616_G62AA3TT_2PMAP_RIG2_TOPOX\062616_G62AA3TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62AA3TT_2PMAP_RIG2\062616_G62AA3TT_2PMAP_RIG2_TOPOX\062616_G62AA3TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';     
% 
% n=n+1;
% files(n).subj = 'G62BB6RT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62BB6RT_2PMAP_RIG2\062616_G62BB6RT_2PMAP_RIG2_TOPOY\062616_G62BB6RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62BB6RT_2PMAP_RIG2\062616_G62BB6RT_2PMAP_RIG2_TOPOY\062616_G62BB6RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62BB6RT_2PMAP_RIG2\062616_G62BB6RT_2PMAP_RIG2_TOPOX\062616_G62BB6RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62BB6RT_2PMAP_RIG2\062616_G62BB6RT_2PMAP_RIG2_TOPOX\062616_G62BB6RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';     
% 
% n=n+1;
% files(n).subj = 'G62BB8TT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62BB8TT_2PMAP_RIG2\062616_G62BB8TT_2PMAP_RIG2_TOPOY\062616_G62BB8TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62BB8TT_2PMAP_RIG2\062616_G62BB8TT_2PMAP_RIG2_TOPOY\062616_G62BB8TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62BB8TT_2PMAP_RIG2\062616_G62BB8TT_2PMAP_RIG2_TOPOX\062616_G62BB8TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62BB8TT_2PMAP_RIG2\062616_G62BB8TT_2PMAP_RIG2_TOPOX\062616_G62BB8TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';     
% 
% n=n+1;
% files(n).subj = 'G62EE6LT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62EE6LT_2PMAP_RIG2\062616_G62EE6LT_2PMAP_RIG2_TOPOY\062616_G62EE6LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62EE6LT_2PMAP_RIG2\062616_G62EE6LT_2PMAP_RIG2_TOPOY\062616_G62EE6LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62EE6LT_2PMAP_RIG2\062616_G62EE6LT_2PMAP_RIG2_TOPOX\062616_G62EE6LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62EE6LT_2PMAP_RIG2\062616_G62EE6LT_2PMAP_RIG2_TOPOX\062616_G62EE6LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';     
% 
% n=n+1;
% files(n).subj = 'G62EE8TT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62EE8TT_2PMAP_RIG2\062616_G62EE8TT_2PMAP_RIG2_TOPOY\062616_G62EE8TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62EE8TT_2PMAP_RIG2\062616_G62EE8TT_2PMAP_RIG2_TOPOY\062616_G62EE8TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62EE8TT_2PMAP_RIG2\062616_G62EE8TT_2PMAP_RIG2_TOPOX\062616_G62EE8TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62EE8TT_2PMAP_RIG2\062616_G62EE8TT_2PMAP_RIG2_TOPOX\062616_G62EE8TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';     
% 
% n=n+1;
% files(n).subj = 'G62TX210TT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62TX210TT_2PMAP_RIG2\062616_G62TX210TT_2PMAP_RIG2_TOPOY\062616_G62TX210TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62TX210TT_2PMAP_RIG2\062616_G62TX210TT_2PMAP_RIG2_TOPOY\062616_G62TX210TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62TX210TT_2PMAP_RIG2\062616_G62TX210TT_2PMAP_RIG2_TOPOX\062616_G62TX210TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62TX210TT_2PMAP_RIG2\062616_G62TX210TT_2PMAP_RIG2_TOPOX\062616_G62TX210TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';     
% 
% n=n+1;
% files(n).subj = 'G62Y9RT';
% files(n).expt = '062616';
% files(n).topox= '062616_G62Y9RT_2PMAP_RIG2\062616_G62Y9RT_2PMAP_RIG2_TOPOY\062616_G62Y9RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062616_G62Y9RT_2PMAP_RIG2\062616_G62Y9RT_2PMAP_RIG2_TOPOY\062616_G62Y9RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062616_G62Y9RT_2PMAP_RIG2\062616_G62Y9RT_2PMAP_RIG2_TOPOX\062616_G62Y9RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062616_G62Y9RT_2PMAP_RIG2\062616_G62Y9RT_2PMAP_RIG2_TOPOX\062616_G62Y9RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';   

% n=n+1;
% files(n).subj = 'CG42TT';
% files(n).expt = '110416';
% files(n).topox= '110416_CG42TT_2PMAP_RIG2\110416_CG42TT_2PMAP_RIG2_TOPOY\110416_CG42TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '110416_CG42TT_2PMAP_RIG2\110416_CG42TT_2PMAP_RIG2_TOPOY\110416_CG42TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '110416_CG42TT_2PMAP_RIG2\110416_CG42TT_2PMAP_RIG2_TOPOX\110416_CG42TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '110416_CG42TT_2PMAP_RIG2\110416_CG42TT_2PMAP_RIG2_TOPOX\110416_CG42TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'CG43LN';
% files(n).expt = '110416';
% files(n).topox= '110416_CG43LN_2PMAP_RIG2\110416_CG43LN_2PMAP_RIG2_TOPOY\110416_CG43LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '110416_CG43LN_2PMAP_RIG2\110416_CG43LN_2PMAP_RIG2_TOPOY\110416_CG43LN_2PMAP_RIG2_TOPOY';
% files(n).topoy = '110416_CG43LN_2PMAP_RIG2\110416_CG43LN_2PMAP_RIG2_TOPOX\110416_CG43LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '110416_CG43LN_2PMAP_RIG2\110416_CG43LN_2PMAP_RIG2_TOPOX\110416_CG43LN_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'CG46RT';
% files(n).expt = '110416';
% files(n).topox= '110416_CG46RT_2PMAP_RIG2\110416_CG46RT_2PMAP_RIG2_TOPOY\110416_CG46RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '110416_CG46RT_2PMAP_RIG2\110416_CG46RT_2PMAP_RIG2_TOPOY\110416_CG46RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '110416_CG46RT_2PMAP_RIG2\110416_CG46RT_2PMAP_RIG2_TOPOX\110416_CG46RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '110416_CG46RT_2PMAP_RIG2\110416_CG46RT_2PMAP_RIG2_TOPOX\110416_CG46RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';

% n=n+1;
% files(n).subj = 'CG33LN';
% files(n).expt = '112016';
% files(n).topox =  '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOX\112016_CG33LN_SALINE_RIG2_PRE_TOPOXmaps.mat';
% files(n).topoxdata = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOX\112016_CG33LN_SALINE_RIG2_PRE_TOPOX';
% files(n).topoy =  '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOY\112016_CG33LN_SALINE_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOY\112016_CG33LN_SALINE_RIG2_PRE_TOPOY';
% files(n).sizeselect =  '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_SIZESELECT\112016_CG33LN_SALINE_RIG2_PRE_SIZESELECTmaps.mat';
% files(n).sizeselectdata = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_SIZESELECT\112016_CG33LN_SALINE_RIG2_PRE_SIZESELECT';
% files(n).darkness = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_DARKNESS\112016_CG33LN_SALINE_RIG2_PRE_DARKNESS';
% files(n).darknessdata = '';
% files(n).inject = 'saline';%%% 'doi' or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'vert'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'pre';  %%% or 'pre' 
% files(n).flipxdim = 0; %if screen was upside down map will be backwards
% 
% n=n+1;
% files(n).subj = 'CG33LN';
% files(n).expt = '112016';
% files(n).topox =  '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOX\112016_CG33LN_SALINE_RIG2_PRE_TOPOXmaps.mat';
% files(n).topoxdata = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOX\112016_CG33LN_SALINE_RIG2_PRE_TOPOX';
% files(n).topoy =  '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOY\112016_CG33LN_SALINE_RIG2_PRE_TOPOYmaps.mat';
% files(n).topoydata = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_PRE_TOPOY\112016_CG33LN_SALINE_RIG2_PRE_TOPOY';
% files(n).sizeselect =  '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_POST_SIZESELECT\112016_CG33LN_SALINE_RIG2_POST_SIZESELECTmaps.mat';
% files(n).sizeselectdata = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_POST_SIZESELECT\112016_CG33LN_SALINE_RIG2_POST_SIZESELECT';
% files(n).darkness = '112016_CG33LN_SALINE_RIG2\112016_CG33LN_SALINE_RIG2_POST_DARKNESS\112016_CG33LN_SALINE_RIG2_POST_DARKNESS';
% files(n).darknessdata = '';
% files(n).inject = 'saline';%%% 'doi' or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'vert'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'post';  %%% or 'pre' 
% files(n).flipxdim = 0; %if screen was upside down map will be backwards
% 
% n=n+1;
% files(n).subj = 'TX26LT';
% files(n).expt = '011817';
% files(n).topox= '011817_TX26LT_2PMAP_RIG2\011817_TX26LT_2PMAP_RIG2_TOPOY\011817_TX26LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '011817_TX26LT_2PMAP_RIG2\011817_TX26LT_2PMAP_RIG2_TOPOY\011817_TX26LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '011817_TX26LT_2PMAP_RIG2\011817_TX26LT_2PMAP_RIG2_TOPOX\011817_TX26LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '011817_TX26LT_2PMAP_RIG2\011817_TX26LT_2PMAP_RIG2_TOPOX\011817_TX26LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62W9RT';
% files(n).expt = '011817';
% files(n).topox= '011817_G62W9RT_2PMAP_RIG2\011817_G62W9RT_2PMAP_RIG2_TOPOY\011817_G62W9RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '011817_G62W9RT_2PMAP_RIG2\011817_G62W9RT_2PMAP_RIG2_TOPOY\011817_G62W9RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '011817_G62W9RT_2PMAP_RIG2\011817_G62W9RT_2PMAP_RIG2_TOPOX\011817_G62W9RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '011817_G62W9RT_2PMAP_RIG2\011817_G62W9RT_2PMAP_RIG2_TOPOX\011817_G62W9RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62TT1LT';
% files(n).expt = '011817';
% files(n).topox= '011817_G62TT1LT_2PMAP_RIG2\011817_G62TT1LT_2PMAP_RIG2_TOPOY\011817_G62TT1LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '011817_G62TT1LT_2PMAP_RIG2\011817_G62TT1LT_2PMAP_RIG2_TOPOY\011817_G62TT1LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '011817_G62TT1LT_2PMAP_RIG2\011817_G62TT1LT_2PMAP_RIG2_TOPOX\011817_G62TT1LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '011817_G62TT1LT_2PMAP_RIG2\011817_G62TT1LT_2PMAP_RIG2_TOPOX\011817_G62TT1LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62QQ2LT';
% files(n).expt = '011817';
% files(n).topox= '011817_G62QQ2LT_2PMAP_RIG2\011817_G62QQ2LT_2PMAP_RIG2_TOPOY\011817_G62QQ2LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '011817_G62QQ2LT_2PMAP_RIG2\011817_G62QQ2LT_2PMAP_RIG2_TOPOY\011817_G62QQ2LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '011817_G62QQ2LT_2PMAP_RIG2\011817_G62QQ2LT_2PMAP_RIG2_TOPOX\011817_G62QQ2LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '011817_G62QQ2LT_2PMAP_RIG2\011817_G62QQ2LT_2PMAP_RIG2_TOPOX\011817_G62QQ2LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62FF8RT';
% files(n).expt = '011817';
% files(n).topox= '011817_G62FF8RT_2PMAP_RIG2\011817_G62FF8RT_2PMAP_RIG2_TOPOY\011817_G62FF8RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '011817_G62FF8RT_2PMAP_RIG2\011817_G62FF8RT_2PMAP_RIG2_TOPOY\011817_G62FF8RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '011817_G62FF8RT_2PMAP_RIG2\011817_G62FF8RT_2PMAP_RIG2_TOPOX\011817_G62FF8RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '011817_G62FF8RT_2PMAP_RIG2\011817_G62FF8RT_2PMAP_RIG2_TOPOX\011817_G62FF8RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'TX26RT';
% files(n).expt = '011817';
% files(n).topox= '011817_TX26RT_2PMAP_RIG2\011817_TX26RT_2PMAP_RIG2_TOPOY\011817_TX26RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '011817_TX26RT_2PMAP_RIG2\011817_TX26RT_2PMAP_RIG2_TOPOY\011817_TX26RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '011817_TX26RT_2PMAP_RIG2\011817_TX26RT_2PMAP_RIG2_TOPOX\011817_TX26RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '011817_TX26RT_2PMAP_RIG2\011817_TX26RT_2PMAP_RIG2_TOPOX\011817_TX26RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'CG48LN';
% files(n).expt = '053117';
% files(n).topox= '053117_CG48LN_2PMAP_RIG2\053117_CG48LN_2PMAP_RIG2_TOPOY\053117_CG48LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_CG48LN_2PMAP_RIG2\053117_CG48LN_2PMAP_RIG2_TOPOY\053117_CG48LN_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_CG48LN_2PMAP_RIG2\053117_CG48LN_2PMAP_RIG2_TOPOX\053117_CG48LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_CG48LN_2PMAP_RIG2\053117_CG48LN_2PMAP_RIG2_TOPOX\053117_CG48LN_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'CG49LT';
% files(n).expt = '053117';
% files(n).topox= '053117_CG49LT_2PMAP_RIG2\053117_CG49LT_2PMAP_RIG2_TOPOY\053117_CG49LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_CG49LT_2PMAP_RIG2\053117_CG49LT_2PMAP_RIG2_TOPOY\053117_CG49LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_CG49LT_2PMAP_RIG2\053117_CG49LT_2PMAP_RIG2_TOPOX\053117_CG49LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_CG49LT_2PMAP_RIG2\053117_CG49LT_2PMAP_RIG2_TOPOX\053117_CG49LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62AAA5LT';
% files(n).expt = '053117';
% files(n).topox= '053117_G62AAA5LT_2PMAP_RIG2\053117_G62AAA5LT_2PMAP_RIG2_TOPOY\053117_G62AAA5LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_G62AAA5LT_2PMAP_RIG2\053117_G62AAA5LT_2PMAP_RIG2_TOPOY\053117_G62AAA5LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_G62AAA5LT_2PMAP_RIG2\053117_G62AAA5LT_2PMAP_RIG2_TOPOX\053117_G62AAA5LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_G62AAA5LT_2PMAP_RIG2\053117_G62AAA5LT_2PMAP_RIG2_TOPOX\053117_G62AAA5LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62FFF1RT';
% files(n).expt = '053117';
% files(n).topox= '053117_G62FFF1RT_2PMAP_RIG2\053117_G62FFF1RT_2PMAP_RIG2_TOPOY\053117_G62FFF1RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_G62FFF1RT_2PMAP_RIG2\053117_G62FFF1RT_2PMAP_RIG2_TOPOY\053117_G62FFF1RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_G62FFF1RT_2PMAP_RIG2\053117_G62FFF1RT_2PMAP_RIG2_TOPOX\053117_G62FFF1RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_G62FFF1RT_2PMAP_RIG2\053117_G62FFF1RT_2PMAP_RIG2_TOPOX\053117_G62FFF1RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62GGG1LT';
% files(n).expt = '053117';
% files(n).topox= '053117_G62GGG1LT_2PMAP_RIG2\053117_G62GGG1LT_2PMAP_RIG2_TOPOY\053117_G62GGG1LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_G62GGG1LT_2PMAP_RIG2\053117_G62GGG1LT_2PMAP_RIG2_TOPOY\053117_G62GGG1LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_G62GGG1LT_2PMAP_RIG2\053117_G62GGG1LT_2PMAP_RIG2_TOPOX\053117_G62GGG1LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_G62GGG1LT_2PMAP_RIG2\053117_G62GGG1LT_2PMAP_RIG2_TOPOX\053117_G62GGG1LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62GGG3LT';
% files(n).expt = '053117';
% files(n).topox= '053117_G62GGG3LT_2PMAP_RIG2\053117_G62GGG3LT_2PMAP_RIG2_TOPOY\053117_G62GGG3LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_G62GGG3LT_2PMAP_RIG2\053117_G62GGG3LT_2PMAP_RIG2_TOPOY\053117_G62GGG3LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_G62GGG3LT_2PMAP_RIG2\053117_G62GGG3LT_2PMAP_RIG2_TOPOX\053117_G62GGG3LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_G62GGG3LT_2PMAP_RIG2\053117_G62GGG3LT_2PMAP_RIG2_TOPOX\053117_G62GGG3LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62RR4LT';
% files(n).expt = '053117';
% files(n).topox= '053117_G62RR4LT_2PMAP_RIG2\053117_G62RR4LT_2PMAP_RIG2_TOPOY\053117_G62RR4LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_G62RR4LT_2PMAP_RIG2\053117_G62RR4LT_2PMAP_RIG2_TOPOY\053117_G62RR4LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_G62RR4LT_2PMAP_RIG2\053117_G62RR4LT_2PMAP_RIG2_TOPOX\053117_G62RR4LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_G62RR4LT_2PMAP_RIG2\053117_G62RR4LT_2PMAP_RIG2_TOPOX\053117_G62RR4LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62UU3RT';
% files(n).expt = '053117';
% files(n).topox= '053117_G62UU3RT_2PMAP_RIG2\053117_G62UU3RT_2PMAP_RIG2_TOPOY\053117_G62UU3RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053117_G62UU3RT_2PMAP_RIG2\053117_G62UU3RT_2PMAP_RIG2_TOPOY\053117_G62UU3RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053117_G62UU3RT_2PMAP_RIG2\053117_G62UU3RT_2PMAP_RIG2_TOPOX\053117_G62UU3RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053117_G62UU3RT_2PMAP_RIG2\053117_G62UU3RT_2PMAP_RIG2_TOPOX\053117_G62UU3RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';

% n=n+1;
% files(n).subj = 'G62YY5LN';
% files(n).expt = '061117';
% files(n).topox= '061117_G62YY5LN_2PMAP_RIG2\061117_G62YY5LN_2PMAP_RIG2_TOPOY\061117_G62YY5LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '061117_G62YY5LN_2PMAP_RIG2\061117_G62YY5LN_2PMAP_RIG2_TOPOY\061117_G62YY5LN_2PMAP_RIG2_TOPOY';
% files(n).topoy = '061117_G62YY5LN_2PMAP_RIG2\061117_G62YY5LN_2PMAP_RIG2_TOPOX\061117_G62YY5LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '061117_G62YY5LN_2PMAP_RIG2\061117_G62YY5LN_2PMAP_RIG2_TOPOX\061117_G62YY5LN_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62YY5RN';
% files(n).expt = '061117';
% files(n).topox= '061117_G62YY5RN_2PMAP_RIG2\061117_G62YY5RN_2PMAP_RIG2_TOPOY\061117_G62YY5RN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '061117_G62YY5RN_2PMAP_RIG2\061117_G62YY5RN_2PMAP_RIG2_TOPOY\061117_G62YY5RN_2PMAP_RIG2_TOPOY';
% files(n).topoy = '061117_G62YY5RN_2PMAP_RIG2\061117_G62YY5RN_2PMAP_RIG2_TOPOX\061117_G62YY5RN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '061117_G62YY5RN_2PMAP_RIG2\061117_G62YY5RN_2PMAP_RIG2_TOPOX\061117_G62YY5RN_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62YY5RT';
% files(n).expt = '061117';
% files(n).topox= '061117_G62YY5RT_2PMAP_RIG2\061117_G62YY5RT_2PMAP_RIG2_TOPOY\061117_G62YY5RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '061117_G62YY5RT_2PMAP_RIG2\061117_G62YY5RT_2PMAP_RIG2_TOPOY\061117_G62YY5RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '061117_G62YY5RT_2PMAP_RIG2\061117_G62YY5RT_2PMAP_RIG2_TOPOX\061117_G62YY5RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '061117_G62YY5RT_2PMAP_RIG2\061117_G62YY5RT_2PMAP_RIG2_TOPOX\061117_G62YY5RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62YY5TT';
% files(n).expt = '061117';
% files(n).topox= '061117_G62YY5TT_2PMAP_RIG2\061117_G62YY5TT_2PMAP_RIG2_TOPOY\061117_G62YY5TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '061117_G62YY5TT_2PMAP_RIG2\061117_G62YY5TT_2PMAP_RIG2_TOPOY\061117_G62YY5TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '061117_G62YY5TT_2PMAP_RIG2\061117_G62YY5TT_2PMAP_RIG2_TOPOX\061117_G62YY5TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '061117_G62YY5TT_2PMAP_RIG2\061117_G62YY5TT_2PMAP_RIG2_TOPOX\061117_G62YY5TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';

% 
% n=n+1;
% files(n).subj = 'G62QQ8RT';
% files(n).expt = '063017';
% files(n).topox= '063017_G62QQ8RT_2PMAP_RIG2\063017_G62QQ8RT_2PMAP_RIG2_TOPOY\063017_G62QQ8RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '063017_G62QQ8RT_2PMAP_RIG2\063017_G62QQ8RT_2PMAP_RIG2_TOPOY\063017_G62QQ8RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '063017_G62QQ8RT_2PMAP_RIG2\063017_G62QQ8RT_2PMAP_RIG2_TOPOX\063017_G62QQ8RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '063017_G62QQ8RT_2PMAP_RIG2\063017_G62QQ8RT_2PMAP_RIG2_TOPOX\063017_G62QQ8RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62XX1RT';
% files(n).expt = '063017';
% files(n).topox= '063017_G62XX1RT_2PMAP_RIG2\063017_G62XX1RT_2PMAP_RIG2_TOPOY\063017_G62XX1RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '063017_G62XX1RT_2PMAP_RIG2\063017_G62XX1RT_2PMAP_RIG2_TOPOY\063017_G62XX1RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '063017_G62XX1RT_2PMAP_RIG2\063017_G62XX1RT_2PMAP_RIG2_TOPOX\063017_G62XX1RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '063017_G62XX1RT_2PMAP_RIG2\063017_G62XX1RT_2PMAP_RIG2_TOPOX\063017_G62XX1RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62TT1LT';
% files(n).expt = '062917';
% files(n).topox= '062917_G62TT1LT_2PMAP_RIG2\062917_G62TT1LT_2PMAP_RIG2_TOPOY\062917_G62TT1LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062917_G62TT1LT_2PMAP_RIG2\062917_G62TT1LT_2PMAP_RIG2_TOPOY\062917_G62TT1LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062917_G62TT1LT_2PMAP_RIG2\062917_G62TT1LT_2PMAP_RIG2_TOPOX\062917_G62TT1LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062917_G62TT1LT_2PMAP_RIG2\062917_G62TT1LT_2PMAP_RIG2_TOPOX\062917_G62TT1LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62KK12RT';
% files(n).expt = '062917';
% files(n).topox= '062917_G62KK12RT_2PMAP_RIG2\062917_G62KK12RT_2PMAP_RIG2_TOPOY\062917_G62KK12RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062917_G62KK12RT_2PMAP_RIG2\062917_G62KK12RT_2PMAP_RIG2_TOPOY\062917_G62KK12RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062917_G62KK12RT_2PMAP_RIG2\062917_G62KK12RT_2PMAP_RIG2_TOPOX\062917_G62KK12RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062917_G62KK12RT_2PMAP_RIG2\062917_G62KK12RT_2PMAP_RIG2_TOPOX\062917_G62KK12RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62AA3LT';
% files(n).expt = '062917';
% files(n).topox= '062917_G62AA3LT_2PMAP_RIG2\062917_G62AA3LT_2PMAP_RIG2_TOPOY\062917_G62AA3LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062917_G62AA3LT_2PMAP_RIG2\062917_G62AA3LT_2PMAP_RIG2_TOPOY\062917_G62AA3LT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062917_G62AA3LT_2PMAP_RIG2\062917_G62AA3LT_2PMAP_RIG2_TOPOX\062917_G62AA3LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062917_G62AA3LT_2PMAP_RIG2\062917_G62AA3LT_2PMAP_RIG2_TOPOX\062917_G62AA3LT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62QQ1RT';
% files(n).expt = '062817';
% files(n).topox= '062817_G62QQ1RT_2PMAP_RIG2\062817_G62QQ1RT_2PMAP_RIG2_TOPOY\062817_G62QQ1RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062817_G62QQ1RT_2PMAP_RIG2\062817_G62QQ1RT_2PMAP_RIG2_TOPOY\062817_G62QQ1RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062817_G62QQ1RT_2PMAP_RIG2\062817_G62QQ1RT_2PMAP_RIG2_TOPOX\062817_G62QQ1RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062817_G62QQ1RT_2PMAP_RIG2\062817_G62QQ1RT_2PMAP_RIG2_TOPOX\062817_G62QQ1RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62KK10TT';
% files(n).expt = '062817';
% files(n).topox= '062817_G62KK10TT_2PMAP_RIG2\062817_G62KK10TT_2PMAP_RIG2_TOPOY\062817_G62KK10TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062817_G62KK10TT_2PMAP_RIG2\062817_G62KK10TT_2PMAP_RIG2_TOPOY\062817_G62KK10TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062817_G62KK10TT_2PMAP_RIG2\062817_G62KK10TT_2PMAP_RIG2_TOPOX\062817_G62KK10TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062817_G62KK10TT_2PMAP_RIG2\062817_G62KK10TT_2PMAP_RIG2_TOPOX\062817_G62KK10TT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
% 
% n=n+1;
% files(n).subj = 'G62JJ2RT';
% files(n).expt = '062817';
% files(n).topox= '062817_G62JJ2RT_2PMAP_RIG2\062817_G62JJ2RT_2PMAP_RIG2_TOPOY\062817_G62JJ2RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '062817_G62JJ2RT_2PMAP_RIG2\062817_G62JJ2RT_2PMAP_RIG2_TOPOY\062817_G62JJ2RT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '062817_G62JJ2RT_2PMAP_RIG2\062817_G62JJ2RT_2PMAP_RIG2_TOPOX\062817_G62JJ2RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '062817_G62JJ2RT_2PMAP_RIG2\062817_G62JJ2RT_2PMAP_RIG2_TOPOX\062817_G62JJ2RT_2PMAP_RIG2_TOPOX';
% files(n).inject = 'none';
% files(n).rignum = 'rig2';
% files(n).monitor = 'portrait';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).timing = 'pre';
