clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = '\\lorentz\backup\widefield\RIG_TESTING\';
datapathname = '\\lorentz\backup\widefield\RIG_TESTING\';  
outpathname = '\\lorentz\backup\widefield\RIG_TESTING\';
n = 0;

% 
% % n=n+1;
% % files(n).subj = '';
% % files(n).expt = '';
% % files(n).topox =  '';
% % files(n).topoxdata = '';
% % files(n).topoy =  '';
% % files(n).topoydata = '';
% % files(n).grating4x3y6sf3tf = '';
% % files(n).grating4x3ydata = '';
% % files(n).background3x2yBlank = '';
% % files(n).backgroundData = '';
% % files(n).darkness = '';
% % files(n).darknessdata='';
% % files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
% % files(n).rignum = 'rig2'; %%% or 'rig1'
% % files(n).monitor = 'land'; %%% for topox and y
% % files(n).label = 'camk2 gc6'; %%% or 'calb2'
% % files(n).notes = 'good imaging session'; 
% % files(n).timing = 'post';  %%% or 'pre' 


n=n+1;
files(n).subj = 'G62TX1RT';
files(n).expt = '080615';
files(n).topox= '080615_G62TX1RT_RIG1_NONE\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOX\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOX_maps.mat';
files(n).topoxdata = '080615_G62TX1RT_RIG1_NONE\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOX\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOX';
files(n).topoy = '080615_G62TX1RT_RIG1_NONE\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOY\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOY_maps.mat';
files(n).topoydata = '080615_G62TX1RT_RIG1_NONE\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOY\080615_G62TX1RT_RIG1_HEADSTRAIGHT_TOPOY';
files(n).grating4x3y6sf3tf =  '080615_G62TX1RT_RIG1_NONE\080615_G62TX1RT_RIG1_HEADSTRAIGHT_4X3Y\080615_G62TX1RT_RIG1_HEADSTRAIGHT_maps.mat';
files(n).grating4x3ydata = '080615_G62TX1RT_RIG1_NONE\080615_G62TX1RT_RIG1_HEADSTRAIGHT_4X3Y\080615_G62TX1RT_RIG1_HEADSTRAIGHT';
% files(n).background3x2yBlank =  '072315_G62TX3TT_RIG2_LISURIDE\072315_G62TX3TT_RIG2_LISURIDE_PRE_BKGRAT\072315_G62TX3TT_RIG2_LISURIDE_PRE_BKGRATmaps.mat';
% files(n).backgroundData = '072315_G62TX3TT_RIG2_LISURIDE\072315_G62TX3TT_RIG2_LISURIDE_PRE_BKGRAT\072315_G62TX3TT_RIG2_LISURIDE_PRE_BKGRAT';
% files(n).darkness =  '072315_G62TX3TT_RIG2_LISURIDE\072315_G62TX3TT_RIG2_LISURIDE_PRE_DARK\072315_G62TX3TT_RIG2_LISURIDE_PRE_DARKmaps.mat';
% files(n).darknessdata = '072315_G62TX3TT_RIG2_LISURIDE\072315_G62TX3TT_RIG2_LISURIDE_PRE_DARK\072315_G62TX3TT_RIG2_LISURIDE_PRE_DARK';
files(n).inject = 'none';
files(n).rignum = 'rig1';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).timing = 'pre'; 