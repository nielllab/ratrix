dbstop if error
pathname = 'C:\Users\nlab\Desktop\Widefield Data\DOI\';
datapathname = 'C:\Users\nlab\Desktop\Widefield Data\DOI\';  
outpathname = 'C:\Users\nlab\Desktop\Widefield Data\DOI\';
n = 0;

% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).topox =  '';
% files(n).topoxdata = '';
% files(n).topoy =  '';
% files(n).topoydata = '';
% files(n).grating4x3y6sf3tf = '';
% files(n).grating4x3ydata = '';
% files(n).background3x2yBlank = '';
% files(n).backgroundData = '';
% files(n).darkness = '';
% files(n).darknessdata='';
% files(n).masking =  '';
% files(n).maskingdata = '';
% files(n).sizeselect =  '';
% files(n).sizeselectdata = '';
% files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
% files(n).rignum = 'rig2'; %%% or 'rig1'
% files(n).monitor = 'land'; %%% for topox and y
% files(n).label = 'camk2 gc6'; %%% or 'calb2'
% files(n).notes = 'good imaging session'; 
% files(n).timing = 'post';  %%% or 'pre' 


n=n+1;
files(n).subj = 'G6BLIND3B12LT';
files(n).expt = '112315';
files(n).topox= '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '';
files(n).grating4x3ydata = '';
files(n).background3x2yBlank = '';
files(n).backgroundData = '';
files(n).darkness =  '';
files(n).darknessdata = '';
files(n).masking =  '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING\112315_G6BLIND3B12LT_RIG2_DOI_PRE_MASKINGmaps.mat';
files(n).maskingdata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING\112315_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING';
files(n).sizeselect =  '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT\112315_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECTmaps.mat';
files(n).sizeselectdata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT\112315_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT';
files(n).inject = 'doi';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).timing = 'pre'; 

n=n+1;
files(n).subj = 'G6BLIND3B12LT';
files(n).expt = '112315';
files(n).topox= '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\112315_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '';
files(n).grating4x3ydata = '';
files(n).background3x2yBlank = '';
files(n).backgroundData = '';
files(n).darkness =  '';
files(n).darknessdata = '';
files(n).masking =  '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_POST_MASKING2\112315_G6BLIND3B12LT_RIG2_DOI_POST_MASKING2maps.mat';
files(n).maskingdata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_POST_MASKING2\112315_G6BLIND3B12LT_RIG2_DOI_POST_MASKING2';
files(n).sizeselect =  '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT\112315_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECTmaps.mat';
files(n).sizeselectdata = '112315_G6BLIND3B12LT_RIG2_DOI\112315_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT\112315_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT';
files(n).inject = 'doi';
files(n).rignum = 'rig2';
files(n).monitor = 'land';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).timing = 'post'; 


n=n+1;
files(n).subj = 'G6BLIND3B1LT';
files(n).expt = '121815';
files(n).topox =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Y\121815_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Y\121815_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Y';
files(n).background3x2yBlank = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATS\121815_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATSmaps.mat';
files(n).backgroundData = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATS\121815_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_MASKING\121815_G6BLIND3B1LT_RIG2_DOI_PRE_MASKINGmaps.mat';
files(n).maskingdata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_MASKING\121815_G6BLIND3B1LT_RIG2_DOI_PRE_MASKING';
files(n).sizeselect =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECT\121815_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECTmaps.mat';
files(n).sizeselectdata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECT\121815_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'pre';  %%% or 'pre' 

n=n+1;
files(n).subj = 'G6BLIND3B1LT';
files(n).expt = '121815';
files(n).topox =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Y\121815_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Y\121815_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Y';
files(n).background3x2yBlank = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATS\121815_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATSmaps.mat';
files(n).backgroundData = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATS\121815_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_MASKING\121815_G6BLIND3B1LT_RIG2_DOI_POST_MASKINGmaps.mat';
files(n).maskingdata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_MASKING\121815_G6BLIND3B1LT_RIG2_DOI_POST_MASKING';
files(n).sizeselect =  '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECT\121815_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECTmaps.mat';
files(n).sizeselectdata = '121815_G6BLIND3B1LT_RIG2_DOI\121815_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECT\121815_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'post';  %%% or 'pre' 

% 
n=n+1;
files(n).subj = 'G6BLIND3B12LT';
files(n).expt = '121815';
files(n).topox =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Y\121815_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Y\121815_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Y';
files(n).background3x2yBlank = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATS\121815_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATSmaps.mat';
files(n).backgroundData = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATS\121815_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING\121815_G6BLIND3B12LT_RIG2_DOI_PRE_MASKINGmaps.mat';
files(n).maskingdata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING\121815_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING';
files(n).sizeselect =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT\121815_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECTmaps.mat';
files(n).sizeselectdata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT\121815_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'pre';  %%% or 'pre' 

n=n+1;
files(n).subj = 'G6BLIND3B12LT';
files(n).expt = '121815';
files(n).topox =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\121815_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Y\121815_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Y\121815_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Y';
files(n).background3x2yBlank = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATS\121815_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATSmaps.mat';
files(n).backgroundData = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATS\121815_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_MASKING\121815_G6BLIND3B12LT_RIG2_DOI_POST_MASKINGmaps.mat';
files(n).maskingdata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_MASKING\121815_G6BLIND3B12LT_RIG2_DOI_POST_MASKING';
files(n).sizeselect =  '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT\121815_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECTmaps.mat';
files(n).sizeselectdata = '121815_G6BLIND3B12LT_RIG2_DOI\121815_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT\121815_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'post';  %%% or 'pre' 


n=n+1;
files(n).subj = 'G6BLIND3B1LT';
files(n).expt = '122115';
files(n).topox =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Y\122115_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Y\122115_G6BLIND3B1LT_RIG2_DOI_PRE_GRAT4X3Y';
files(n).background3x2yBlank = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATS\122115_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATSmaps.mat';
files(n).backgroundData = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATS\122115_G6BLIND3B1LT_RIG2_DOI_PRE_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_MASKING\122115_G6BLIND3B1LT_RIG2_DOI_PRE_MASKINGmaps.mat';
files(n).maskingdata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_MASKING\122115_G6BLIND3B1LT_RIG2_DOI_PRE_MASKING';
files(n).sizeselect =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECT\122115_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECTmaps.mat';
files(n).sizeselectdata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECT\122115_G6BLIND3B1LT_RIG2_DOI_PRE_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'pre';  %%% or 'pre' 

n=n+1;
files(n).subj = 'G6BLIND3B1LT';
files(n).expt = '122115';
files(n).topox =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B1LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Y\122115_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Y\122115_G6BLIND3B1LT_RIG2_DOI_POST_GRAT4X3Y';
files(n).background3x2yBlank = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATS\122115_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATSmaps.mat';
files(n).backgroundData = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATS\122115_G6BLIND3B1LT_RIG2_DOI_POST_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_MASKING\122115_G6BLIND3B1LT_RIG2_DOI_POST_MASKINGmaps.mat';
files(n).maskingdata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_MASKING\122115_G6BLIND3B1LT_RIG2_DOI_POST_MASKING';
files(n).sizeselect =  '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECT\122115_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECTmaps.mat';
files(n).sizeselectdata = '122115_G6BLIND3B1LT_RIG2_DOI\122115_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECT\122115_G6BLIND3B1LT_RIG2_DOI_POST_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'post';  %%% or 'pre' 

% 
n=n+1;
files(n).subj = 'G6BLIND3B12LT';
files(n).expt = '122115';
files(n).topox =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Y\122115_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Y\122115_G6BLIND3B12LT_RIG2_DOI_PRE_GRAT4X3Y';
files(n).background3x2yBlank = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATS\122115_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATSmaps.mat';
files(n).backgroundData = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATS\122115_G6BLIND3B12LT_RIG2_DOI_PRE_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING\122115_G6BLIND3B12LT_RIG2_DOI_PRE_MASKINGmaps.mat';
files(n).maskingdata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING\122115_G6BLIND3B12LT_RIG2_DOI_PRE_MASKING';
files(n).sizeselect =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT\122115_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECTmaps.mat';
files(n).sizeselectdata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT\122115_G6BLIND3B12LT_RIG2_DOI_PRE_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'pre';  %%% or 'pre' 

n=n+1;
files(n).subj = 'G6BLIND3B12LT';
files(n).expt = '122115';
files(n).topox =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOXmaps.mat';
files(n).topoxdata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOX';
files(n).topoy =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOYmaps.mat';
files(n).topoydata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY\122115_G6BLIND3B12LT_RIG2_DOI_PRE_TOPOY';
files(n).grating4x3y6sf3tf = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Y\122115_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Ymaps.mat';
files(n).grating4x3ydata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Y\122115_G6BLIND3B12LT_RIG2_DOI_POST_GRAT4X3Y';
files(n).background3x2yBlank = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATS\122115_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATSmaps.mat';
files(n).backgroundData = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATS\122115_G6BLIND3B12LT_RIG2_DOI_POST_BKGRATS';
files(n).darkness = '';
files(n).darknessdata='';
files(n).masking =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_MASKING\122115_G6BLIND3B12LT_RIG2_DOI_POST_MASKINGmaps.mat';
files(n).maskingdata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_MASKING\122115_G6BLIND3B12LT_RIG2_DOI_POST_MASKING';
files(n).sizeselect =  '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT\122115_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECTmaps.mat';
files(n).sizeselectdata = '122115_G6BLIND3B12LT_RIG2_DOI\122115_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT\122115_G6BLIND3B12LT_RIG2_DOI_POST_SIZESELECT';
files(n).inject = 'doi';%%% or 'lisuride' or 'saline'
files(n).rignum = 'rig2'; %%% or 'rig1'
files(n).monitor = 'land'; %%% for topox and y
files(n).label = 'camk2 gc6'; %%% or 'calb2'
files(n).notes = 'good imaging session'; 
files(n).timing = 'post';  %%% or 'pre' 