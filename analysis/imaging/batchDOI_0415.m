clear all
close all
dbstop if error
pathname = 'I:\compiled behavior\';
pathname = 'C:\data\imaging\DOI experiments\';
datapathname = 'D:\Widefield (12-10-12+)\data 62713+\';  
outpathname = 'C:\data\imaging\topos\';
n=0;


n=n+1;
files(n).subj = '';
files(n).expt = '';
files(n).topox =  '';
files(n).topoxdata = '';
files(n).topoy =  '';
files(n).topoydata = '';
files(n).darkness = '';
files(n).darknessdata='';
files(n).background3x2yBlank = '';
files(n).backgroundData = '';
files(n).grating4x3y6sf3tf = '';
files(n).grating4x3ydata = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).timing = 'pre';  %%% or 'post'
files(n).doi = 'doi'; %%% or 'saline'
files(n).monitor = 'vert'; %%% for topox and y


n=n+1;
files(n).subj = '';
files(n).expt = '';
files(n).topox =  '';
files(n).topoxdata = '';
files(n).topoy =  '';
files(n).topoydata = '';
files(n).darkness = '';
files(n).darknessdata='';
files(n).background3x2yBlank = '';
files(n).backgroundData = '';
files(n).grating4x3y6sf3tf = '';
files(n).grating4x3ydata = '';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session'; 
files(n).timing = 'post';  %%% or 'post'
files(n).doi = 'doi'; %%% or 'saline'
files(n).monitor = 'vert'; %%% for topox and y

