%% batchIan2pMapping
dbstop if error
pathname = 'D:\Ian\Widefield_Mapping\';
datapathname = 'D:\Ian\Widefield_Mapping\';  
outpathname = 'D:\Ian\Widefield_Mapping\';
n = 0;

%%
% n=n+1;
% files(n).subj = 'G6H12p13LN';
% files(n).expt = '053119';
% files(n).topox= '053119_G6H12p13LN_2PMAP_RIG2\053119_G6H12p13LN_2PMAP_RIG2_TOPOY\053119_G6H12p13LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '053119_G6H12p13LN_2PMAP_RIG2\053119_G6H12p13LN_2PMAP_RIG2_TOPOY\053119_G6H12p13LN_2PMAP_RIG2_TOPOY';
% files(n).topoy = '053119_G6H12p13LN_2PMAP_RIG2\053119_G6H12p13LN_2PMAP_RIG2_TOPOX\053119_G6H12p13LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '053119_G6H12p13LN_2PMAP_RIG2\053119_G6H12p13LN_2PMAP_RIG2_TOPOX\053119_G6H12p13LN_2PMAP_RIG2_TOPOX';
% files(n).rignum = 'rig2'; %rig1 (old) or rig2 (new)
% files(n).monitor = 'vert'; %vert or land for portrait or landscape

% %%
% n=n+1;
% files(n).subj = 'G6H12p13TT';
% files(n).expt = '060519';
% files(n).topox= '060519_G6H12p13TT_2PMAP_RIG2\060519_G6H12p13TT_2PMAP_RIG2_TOPOY\060519_G6H12p13TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '060519_G6H12p13TT_2PMAP_RIG2\060519_G6H12p13TT_2PMAP_RIG2_TOPOY\060519_G6H12p13TT_2PMAP_RIG2_TOPOY';
% files(n).topoy = '060519_G6H12p13TT_2PMAP_RIG2\060519_G6H12p13TT_2PMAP_RIG2_TOPOX\060519_G6H12p13TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '060519_G6H12p13TT_2PMAP_RIG2\060519_G6H12p13TT_2PMAP_RIG2_TOPOX\060519_G6H12p13TT_2PMAP_RIG2_TOPOX';
% files(n).rignum = 'rig2'; %rig1 (old) or rig2 (new)
% files(n).monitor = 'land'; %vert or land for portrait or landscape
% 
% %%
% n=n+1;
% files(n).subj = 'G6H12p13NN';
% files(n).expt = '060519';
% files(n).topox= '060519_G6H12p13NN_2PMAP_RIG2\060519_G6H12p13NN_2PMAP_RIG2_TOPOY\060519_G6H12p13NN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoxdata = '060519_G6H12p13NN_2PMAP_RIG2\060519_G6H12p13NN_2PMAP_RIG2_TOPOY\060519_G6H12p13NN_2PMAP_RIG2_TOPOY';
% files(n).topoy = '060519_G6H12p13NN_2PMAP_RIG2\060519_G6H12p13NN_2PMAP_RIG2_TOPOX\060519_G6H12p13NN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoydata = '060519_G6H12p13NN_2PMAP_RIG2\060519_G6H12p13NN_2PMAP_RIG2_TOPOX\060519_G6H12p13NN_2PMAP_RIG2_TOPOX';
% files(n).rignum = 'rig2'; %rig1 (old) or rig2 (new)
% files(n).monitor = 'land'; %vert or land for portrait or landscape

%%
n=n+1;
files(n).subj = 'G6H15p5RT';
files(n).expt = '062819';
files(n).topox= '062819_G6H15p5RT_2PMAP_RIG2\062819_G6H15p5RT_2PMAP_RIG2_TOPOY\062819_G6H15p5RT_2PMAP_RIG2_TOPOYmaps.mat';
files(n).topoxdata = '062819_G6H15p5RT_2PMAP_RIG2\062819_G6H15p5RT_2PMAP_RIG2_TOPOY\062819_G6H15p5RT_2PMAP_RIG2_TOPOY';
files(n).topoy = '062819_G6H15p5RT_2PMAP_RIG2\062819_G6H15p5RT_2PMAP_RIG2_TOPOX\062819_G6H15p5RT_2PMAP_RIG2_TOPOXmaps.mat';
files(n).topoydata = '062819_G6H15p5RT_2PMAP_RIG2\062819_G6H15p5RT_2PMAP_RIG2_TOPOX\062819_G6H15p5RT_2PMAP_RIG2_TOPOX';
files(n).rignum = 'rig2'; %rig1 (old) or rig2 (new)
files(n).monitor = 'land'; %vert or land for portrait or landscape






