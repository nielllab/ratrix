%% batchEmmalyn2pMapping

% dbstop if error
% pathname = 'F:\Emmalyn\2pMapping\';
% datapathname = 'F:\Emmalyn\2pMapping\';  
% outpathname = 'F:\Emmalyn\2pMapping\';
% n = 0;


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

% n=n+1;
% files(n).subj = 'G6H19p1RN';
% files(n).expt = '072319';
% files(n).topox =  '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOX\072319_G6H19p1RN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOX\072319_G6H19p1RN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOY\072319_G6H19p1RN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '072319_G6H19p1RN_2PMAP_RIG2\072319_G6H19p1RN_2PMAP_RIG2_TOPOY\072319_G6H19p1RN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p2LT';
% files(n).expt = '080119';
% files(n).topox =  '080119_Calb23p2LT_2PMAP_RIG2\080119_Calb23p2LT_2PMAP_RIG2_TOPOX\080119_Calb23p2LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '080119_Calb23p2LT_2PMAP_RIG2\080119_Calb23p2LT_2PMAP_RIG2_TOPOX\080119_Calb23p2LT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '080119_Calb23p2LT_2PMAP_RIG2\080119_Calb23p2LT_2PMAP_RIG2_TOPOY\080119_Calb23p2LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '080119_Calb23p2LT_2PMAP_RIG2\080119_Calb23p2LT_2PMAP_RIG2_TOPOY\080119_Calb23p2LT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p3RN';
% files(n).expt = '080119';
% files(n).topox =  '080119_Calb23p3RN_2PMAP_RIG2\080119_Calb23p3RN_2PMAP_RIG2_TOPOX\080119_Calb23p3RN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '080119_Calb23p3RN_2PMAP_RIG2\080119_Calb23p3RN_2PMAP_RIG2_TOPOX\080119_Calb23p3RN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '080119_Calb23p3RN_2PMAP_RIG2\080119_Calb23p3RN_2PMAP_RIG2_TOPOY\080119_Calb23p3RN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '080119_Calb23p3RN_2PMAP_RIG2\080119_Calb23p3RN_2PMAP_RIG2_TOPOY\080119_Calb23p3RN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% % n=n+1;
% % files(n).subj = 'G6H15p11RT';
% % files(n).expt = '080519';
% % files(n).topox =  '080519_G6H15p11RT_2PMAP_RIG2\080519_G6H15p11RT_2PMAP_RIG2_TOPOX\080519_G6H15p11RT_2PMAP_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '080519_G6H15p11RT_2PMAP_RIG2\080519_G6H15p11RT_2PMAP_RIG2_TOPOX\080519_G6H15p11RT_2PMAP_RIG2_TOPOX';
% % files(n).topoy =  '080519_G6H15p11RT_2PMAP_RIG2\080519_G6H15p11RT_2PMAP_RIG2_TOPOY\080519_G6H15p11RT_2PMAP_RIG2_TOPOYmaps.mat';
% % files(n).topoydata = '080519_G6H15p11RT_2PMAP_RIG2\080519_G6H15p11RT_2PMAP_RIG2_TOPOY\080519_G6H15p11RT_2PMAP_RIG2_TOPOY';
% % files(n).rignum = 'rig2'; %%% or 'rig1'
% % files(n).monitor = 'land'; %%% for topox and y
% % files(n).label = 'camk2 gc6'; %%% or 'calb2'
% 
% % n=n+1;
% % files(n).subj = 'G6H16p9RT';
% % files(n).expt = '080519';
% % files(n).topox =  '080519_G6H16p9RT_2PMAP_RIG2\080519_G6H16p9RT_2PMAP_RIG2_TOPOX\080519_G6H16p9RT_2PMAP_RIG2_TOPOXmaps.mat';
% % files(n).topoxdata = '080519_G6H16p9RT_2PMAP_RIG2\080519_G6H16p9RT_2PMAP_RIG2_TOPOX\080519_G6H16p9RT_2PMAP_RIG2_TOPOX';
% % files(n).topoy =  '080519_G6H16p9RT_2PMAP_RIG2\080519_G6H16p9RT_2PMAP_RIG2_TOPOY\080519_G6H16p9RT_2PMAP_RIG2_TOPOYmaps.mat';
% % files(n).topoydata = '080519_G6H16p9RT_2PMAP_RIG2\080519_G6H16p9RT_2PMAP_RIG2_TOPOY\080519_G6H16p9RT_2PMAP_RIG2_TOPOY';
% % files(n).rignum = 'rig2'; %%% or 'rig1'
% % files(n).monitor = 'land'; %%% for topox and y
% % files(n).label = 'camk2 gc6'; %%% or 'calb2'
% 
% n=n+1;
% files(n).subj = 'Calb2CK22p3LT';
% files(n).expt = '081419';
% files(n).topox =  '081419_Calb2CK22p3LT_2PMAP_RIG2\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOX\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '081419_Calb2CK22p3LT_2PMAP_RIG2\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOX\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '081419_Calb2CK22p3LT_2PMAP_RIG2\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOY\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '081419_Calb2CK22p3LT_2PMAP_RIG2\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOY\081419_Calb2CK22p3LT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p4LT';
% files(n).expt = '081419';
% files(n).topox =  '081419_Calb23p4LT_2PMAP_RIG2\081419_Calb23p4LT_2PMAP_RIG2_TOPOX\081419_Calb23p4LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '081419_Calb23p4LT_2PMAP_RIG2\081419_Calb23p4LT_2PMAP_RIG2_TOPOX\081419_Calb23p4LT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '081419_Calb23p4LT_2PMAP_RIG2\081419_Calb23p4LT_2PMAP_RIG2_TOPOY\081419_Calb23p4LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '081419_Calb23p4LT_2PMAP_RIG2\081419_Calb23p4LT_2PMAP_RIG2_TOPOY\081419_Calb23p4LT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p5LT';
% files(n).expt = '081419';
% files(n).topox =  '081419_Calb23p5LT_2PMAP_RIG2\081419_Calb23p5LT_2PMAP_RIG2_TOPOX\081419_Calb23p5LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '081419_Calb23p5LT_2PMAP_RIG2\081419_Calb23p5LT_2PMAP_RIG2_TOPOX\081419_Calb23p5LT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '081419_Calb23p5LT_2PMAP_RIG2\081419_Calb23p5LT_2PMAP_RIG2_TOPOY\081419_Calb23p5LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '081419_Calb23p5LT_2PMAP_RIG2\081419_Calb23p5LT_2PMAP_RIG2_TOPOY\081419_Calb23p5LT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'Calb23p7LT';
% files(n).expt = '082919';
% files(n).topox =  '082919_Calb23p7LT_2PMAP_RIG2\082919_Calb23p7LT_2PMAP_RIG2_TOPOX\082919_Calb23p7LT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '082919_Calb23p7LT_2PMAP_RIG2\082919_Calb23p7LT_2PMAP_RIG2_TOPOX\082919_Calb23p7LT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '082919_Calb23p7LT_2PMAP_RIG2\082919_Calb23p7LT_2PMAP_RIG2_TOPOY\082919_Calb23p7LT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '082919_Calb23p7LT_2PMAP_RIG2\082919_Calb23p7LT_2PMAP_RIG2_TOPOY\082919_Calb23p7LT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'
% 


% n=n+1;
% files(n).subj = 'Calb24P5LN';
% files(n).expt = '082919';
% files(n).topox =  '082919_Calb24P5LN_2PMAP_RIG2\082919_Calb24P5LN_2PMAP_RIG2_TOPOX\082919_Calb24P5LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '082919_Calb24P5LN_2PMAP_RIG2\082919_Calb24P5LN_2PMAP_RIG2_TOPOX\082919_Calb24P5LN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '082919_Calb24P5LN_2PMAP_RIG2\082919_Calb24P5LN_2PMAP_RIG2_TOPOY\082919_Calb24P5LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '082919_Calb24P5LN_2PMAP_RIG2\082919_Calb24P5LN_2PMAP_RIG2_TOPOY\082919_Calb24P5LN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'calb2'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H15p9LN';
% files(n).expt = '090319';
% files(n).topox =  '090319_G6H15p9LN_2PMAP_RIG2\090319_G6H15p9LN_2PMAP_RIG2_TOPOX\090319_G6H15p9LN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '090319_G6H15p9LN_2PMAP_RIG2\090319_G6H15p9LN_2PMAP_RIG2_TOPOX\090319_G6H15p9LN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '090319_G6H15p9LN_2PMAP_RIG2\090319_G6H15p9LN_2PMAP_RIG2_TOPOY\090319_G6H15p9LN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '090319_G6H15p9LN_2PMAP_RIG2\090319_G6H15p9LN_2PMAP_RIG2_TOPOY\090319_G6H15p9LN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H15p9RT';
% files(n).expt = '090319';
% files(n).topox =  '090319_G6H15p9RT_2PMAP_RIG2\090319_G6H15p9RT_2PMAP_RIG2_TOPOX\090319_G6H15p9RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '090319_G6H15p9RT_2PMAP_RIG2\090319_G6H15p9RT_2PMAP_RIG2_TOPOX\090319_G6H15p9RT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '090319_G6H15p9RT_2PMAP_RIG2\090319_G6H15p9RT_2PMAP_RIG2_TOPOY\090319_G6H15p9RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '090319_G6H15p9RT_2PMAP_RIG2\090319_G6H15p9RT_2PMAP_RIG2_TOPOY\090319_G6H15p9RT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H15p9RN';
% files(n).expt = '090319';
% files(n).topox =  '090319_G6H15p9RN_2PMAP_RIG2\090319_G6H15p9RN_2PMAP_RIG2_TOPOX\090319_G6H15p9RN_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '090319_G6H15p9RN_2PMAP_RIG2\090319_G6H15p9RN_2PMAP_RIG2_TOPOX\090319_G6H15p9RN_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '090319_G6H15p9RN_2PMAP_RIG2\090319_G6H15p9RN_2PMAP_RIG2_TOPOY\090319_G6H15p9RN_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '090319_G6H15p9RN_2PMAP_RIG2\090319_G6H15p9RN_2PMAP_RIG2_TOPOY\090319_G6H15p9RN_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H19p9RT';
% files(n).expt = '092019';
% files(n).topox =  '092019_G6H19p9RT_2PMAP_RIG2\092019_G6H19p9RT_2PMAP_RIG2_TOPOX\092019_G6H19p9RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '092019_G6H19p9RT_2PMAP_RIG2\092019_G6H19p9RT_2PMAP_RIG2_TOPOX\092019_G6H19p9RT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '092019_G6H19p9RT_2PMAP_RIG2\092019_G6H19p9RT_2PMAP_RIG2_TOPOY\092019_G6H19p9RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '092019_G6H19p9RT_2PMAP_RIG2\092019_G6H19p9RT_2PMAP_RIG2_TOPOY\092019_G6H19p9RT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'G6H19p9TT';
% files(n).expt = '092019';
% files(n).topox =  '092019_G6H19p9TT_2PMAP_RIG2\092019_G6H19p9TT_2PMAP_RIG2_TOPOX\092019_G6H19p9TT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '092019_G6H19p9TT_2PMAP_RIG2\092019_G6H19p9TT_2PMAP_RIG2_TOPOX\092019_G6H19p9TT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '092019_G6H19p9TT_2PMAP_RIG2\092019_G6H19p9TT_2PMAP_RIG2_TOPOY\092019_G6H19p9TT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '092019_G6H19p9TT_2PMAP_RIG2\092019_G6H19p9TT_2PMAP_RIG2_TOPOY\092019_G6H19p9TT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% 
% % % n=n+1;
% % % files(n).subj = 'J514LT';
% % % files(n).expt = '030220';
% % % files(n).topox =  '030220_J514LT_2PMAP_RIG2\030220_J514LT_2PMAP_RIG2_TOPOX\030220_J514LT_2PMAP_RIG2_TOPOXmaps.mat';
% % % files(n).topoxdata = '030220_J514LT_2PMAP_RIG2\030220_J514LT_2PMAP_RIG2_TOPOX\030220_J514LT_2PMAP_RIG2_TOPOX';
% % % files(n).topoy =  '030220_J514LT_2PMAP_RIG2\030220_J514LT_2PMAP_RIG2_TOPOY\030220_J514LT_2PMAP_RIG2_TOPOYmaps.mat';
% % % files(n).topoydata = '030220_J514LT_2PMAP_RIG2\030220_J514LT_2PMAP_RIG2_TOPOY\030220_J514LT_2PMAP_RIG2_TOPOY';
% % % files(n).rignum = 'rig2'; %%% or 'rig1'
% % % files(n).monitor = 'land'; %%% for topox and y
% % % files(n).label = 'camk2 gc6'; %%% or 'calb2'
% n=n+1;
% files(n).subj = 'J514RT';
% files(n).expt = '071720';
% files(n).topox =  '071720_J514RT_2PMAP_RIG2\071720_J514RT_2PMAP_RIG2_TOPOX\071720_J514RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '071720_J514RT_2PMAP_RIG2\071720_J514RT_2PMAP_RIG2_TOPOX\071720_J514RT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '071720_J514RT_2PMAP_RIG2\071720_J514RT_2PMAP_RIG2_TOPOY\071720_J514RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '071720_J514RT_2PMAP_RIG2\071720_J514RT_2PMAP_RIG2_TOPOY\071720_J514RT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'

% n=n+1;
% files(n).subj = 'J515RT';
% files(n).expt = '072720';
% files(n).topox =  '072720_J515RT_2PMAP_RIG2\072720_J515RT_2PMAP_RIG2_TOPOX\072720_J515RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '072720_J515RT_2PMAP_RIG2\072720_J515RT_2PMAP_RIG2_TOPOX\072720_J515RT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '072720_J515RT_2PMAP_RIG2\072720_J515RT_2PMAP_RIG2_TOPOY\072720_J515RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '072720_J515RT_2PMAP_RIG2\072720_J515RT_2PMAP_RIG2_TOPOY\072720_J515RT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'


% n=n+1;
% files(n).subj = 'JTT4841P4RT';
% files(n).expt = '081420';
% files(n).topox =  '081420_JTT4841P4RT_2PMAP_RIG2\081420_JTT4841P4RT_2PMAP_RIG2_TOPOX\081420_JTT4841P4RT_2PMAP_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '081420_JTT4841P4RT_2PMAP_RIG2\081420_JTT4841P4RT_2PMAP_RIG2_TOPOX\081420_JTT4841P4RT_2PMAP_RIG2_TOPOX';
% files(n).topoy =  '081420_JTT4841P4RT_2PMAP_RIG2\081420_JTT4841P4RT_2PMAP_RIG2_TOPOY\081420_JTT4841P4RT_2PMAP_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '081420_JTT4841P4RT_2PMAP_RIG2\081420_JTT4841P4RT_2PMAP_RIG2_TOPOY\081420_JTT4841P4RT_2PMAP_RIG2_TOPOY';
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'


n=n+1;
files(n).subj = 'JTT4841P4LT';
files(n).expt = '081420';
files(n).topox =  'JTT4841P4LT_2PMAP_RIG2\JTT4841P4LT_2PMAP_RIG2_TOPOX\JTT4841P4LT_2PMAP_RIG2_TOPOXmaps.mat';
files(n).topoxdata = 'JTT4841P4LT_2PMAP_RIG2\JTT4841P4LT_2PMAP_RIG2_TOPOX\JTT4841P4LT_2PMAP_RIG2_TOPOX';
files(n).topoy =  'JTT4841P4LT_2PMAP_RIG2\JTT4841P4LT_2PMAP_RIG2_TOPOY\JTT4841P4LT_2PMAP_RIG2_TOPOYmaps.mat';
files(n).topoydata = 'JTT4841P4LT_2PMAP_RIG2\JTT4841P4LT_2PMAP_RIG2_TOPOY\JTT4841P4LT_2PMAP_RIG2_TOPOY';
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
