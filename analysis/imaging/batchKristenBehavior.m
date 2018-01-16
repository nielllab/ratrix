%batchKristenBehavior
dbstop if error
n = 0;

% %%langevin path
% pathname = '\\langevin\backup\widefield\Kristen\Behavior\';
% datapathname = '\\langevin\backup\widefield\Kristen\Behavior\';  
% outpathname = '\\langevin\backup\widefield\Kristen\Behavior\';

% local path
pathname = 'C:\Users\nlab\Desktop\Data\Kristen\';
datapathname = 'C:\Users\nlab\Desktop\Data\Kristen\';
outpathname = 'C:\Users\nlab\Desktop\Data\Kristen\';


n=n+1;
files(n).subj = 'SS4LT';
files(n).expt = '110417';
files(n).topox= '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOX\110417_SS4LT_RIG1_TOPOXmaps.mat';
files(n).topoxdata = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOX\110417_SS4LT_RIG1_TOPOX';
files(n).topoy = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOY\110417_SS4LT_RIG1_TOPOYmaps.mat';
files(n).topoydata = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOY\110417_SS4LT_RIG1_TOPOY';
files(n).fullflanker = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_FULLFLANKER\110417_SS4LT_RIG1_FULLFLANKERmaps.mat';
files(n).fullflankerdata = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_FULLFLANKER\110417 _SS4LT_RIG1_FULLFLANKER';
files(n).inject = 'none';
files(n).timing = 'none'; 
files(n).rignum = 'rig1';
files(n).monitor = 'landscape';
files(n).monitorloc = 'center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';




