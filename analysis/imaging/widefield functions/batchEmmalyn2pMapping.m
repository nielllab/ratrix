%% batchEmmalyn2pMapping

dbstop if error
pathname = 'F:\Emmalyn\2pMapping\';
datapathname = 'F:\Emmalyn\2pMapping\';  
outpathname = 'F:\Emmalyn\2pMapping\';
n = 0;

%%
% n=n+1;
% files(n).subj = 'G6H19p3TT';
% files(n).expt = '062719';
% files(n).topox =  '062719_G6H19p3TT_2PMAP_RIG2\062719_G6H19p3TT_2PMAP_RIG2_TOPOX\062719_G6H19p3TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '062719_G6H19p3TT_2PMAP_RIG2\062719_G6H19p3TT_2PMAP_RIG2_TOPOX\062719_G6H19p3TT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '062719_G6H19p3TT_2PMAP_RIG2\062719_G6H19p3TT_2PMAP_RIG2_TOPOY\062719_G6H19p3TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '062719_G6H19p3TT_2PMAP_RIG2\062719_G6H19p3TT_2PMAP_RIG2_TOPOY\062719_G6H19p3TT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

%%
% n=n+1;
% files(n).subj = 'G6H19p3LN';
% files(n).expt = '062819';
% files(n).topox =  '062819_G6H19p3LN_2PMAP_RIG2\062819_G6H19p3LN_2PMAP_RIG2_TOPOX\062819_G6H19p3LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '062819_G6H19p3LN_2PMAP_RIG2\062819_G6H19p3LN_2PMAP_RIG2_TOPOX\062819_G6H19p3LN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '062819_G6H19p3LN_2PMAP_RIG2\062819_G6H19p3LN_2PMAP_RIG2_TOPOY\062819_G6H19p3LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '062819_G6H19p3LN_2PMAP_RIG2\062819_G6H19p3LN_2PMAP_RIG2_TOPOY\062819_G6H19p3LN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% 
% n=n+1;
% files(n).subj = 'G6H19p3LN';
% files(n).expt = '070319';
% files(n).topox =  '070319_G6H19p3LN_2PMAP_RIG2\070319_G6H19p3LN_2PMAP_RIG2_TOPOX\070319_G6H19p3LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '070319_G6H19p3LN_2PMAP_RIG2\070319_G6H19p3LN_2PMAP_RIG2_TOPOX\070319_G6H19p3LN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '070319_G6H19p3LN_2PMAP_RIG2\070319_G6H19p3LN_2PMAP_RIG2_TOPOY\070319_G6H19p3LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '070319_G6H19p3LN_2PMAP_RIG2\070319_G6H19p3LN_2PMAP_RIG2_TOPOY\070319_G6H19p3LN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H19p4TT';
% files(n).expt = '070919';
% files(n).topox =  '070919_G6H19p4TT_2PMAP_RIG2\070919_G6H19p4TT_2PMAP_RIG2_TOPOX\070919_G6H19p4TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '070919_G6H19p4TT_2PMAP_RIG2\070919_G6H19p4TT_2PMAP_RIG2_TOPOX\070919_G6H19p4TT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '070919_G6H19p4TT_2PMAP_RIG2\070919_G6H19p4TT_2PMAP_RIG2_TOPOY\070919_G6H19p4TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '070919_G6H19p4TT_2PMAP_RIG2\070919_G6H19p4TT_2PMAP_RIG2_TOPOY\070919_G6H19p4TT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H19p4LN';
% files(n).expt = '070919';
% files(n).topox =  '070919_G6H19p4LN_2PMAP_RIG2\070919_G6H19p4LN_2PMAP_RIG2_TOPOX\070919_G6H19p4LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '070919_G6H19p4LN_2PMAP_RIG2\070919_G6H19p4LN_2PMAP_RIG2_TOPOX\070919_G6H19p4LN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '070919_G6H19p4LN_2PMAP_RIG2\070919_G6H19p4LN_2PMAP_RIG2_TOPOY\070919_G6H19p4LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '070919_G6H19p4LN_2PMAP_RIG2\070919_G6H19p4LN_2PMAP_RIG2_TOPOY\070919_G6H19p4LN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p6';
% files(n).expt = '071519';
% files(n).topox =  '071519_Calb23p6_2PMAP_RIG2\071519_Calb23p6_2PMAP_RIG2_TOPOX\071519_Calb23p6_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '071519_Calb23p6_2PMAP_RIG2\071519_Calb23p6_2PMAP_RIG2_TOPOX\071519_Calb23p6_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '071519_Calb23p6_2PMAP_RIG2\071519_Calb23p6_2PMAP_RIG2_TOPOY\071519_Calb23p6_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '071519_Calb23p6_2PMAP_RIG2\071519_Calb23p6_2PMAP_RIG2_TOPOY\071519_Calb23p6_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p6RT';
% files(n).expt = '071519';
% files(n).topox =  '071519_Calb23p6RT_2PMAP_RIG2\071519_Calb23p6RT_2PMAP_RIG2_TOPOX\071519_Calb23p6RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '071519_Calb23p6RT_2PMAP_RIG2\071519_Calb23p6RT_2PMAP_RIG2_TOPOX\071519_Calb23p6RT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '071519_Calb23p6RT_2PMAP_RIG2\071519_Calb23p6RT_2PMAP_RIG2_TOPOY\071519_Calb23p6RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '071519_Calb23p6RT_2PMAP_RIG2\071519_Calb23p6RT_2PMAP_RIG2_TOPOY\071519_Calb23p6RT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

n=n+1;
files(n).subj = 'G6H19p1RN';
files(n).expt = '072319';
files(n).topox =  '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOX\072319_G6H19p1RN_2PMAP_RIG2_TOPOXmaps.mat';
files(n).topoxdata = '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOX\072319_G6H19p1RN_2PMAP_RIG2_TOPOX';
files(n).topoy =  '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOY\072319_G6H19p1RN_2PMAP_RIG2_TOPOYmaps.mat';
files(n).topoydata = '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOY\072319_G6H19p1RN_2PMAP_RIG2_TOPOY';
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
