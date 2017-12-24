%batchKristenBehavior
dbstop if error
n = 0;

%%langevin path
pathname = '\\langevin\backup\widefield\Kristen\Behavior\';
datapathname = '\\langevin\backup\widefield\Kristen\Behavior\';  
outpathname = '\\langevin\backup\widefield\Kristen\Behavior\';

% %%%local path
% pathname = 'C:\Users\nlab\Desktop\Data\Kristen\';
% datapathname = 'C:\Users\nlab\Desktop\Data\Kristen\';
% outpathname = 'C:\Users\nlab\Desktop\Data\Kristen\';


n=n+1;
files(n).subj = 'WW3RT';
files(n).expt = '102717';
files(n).topox= '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOX\102717_WW3RT_RIG1_TOPOXmaps.mat';
files(n).topoxdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOX\102717_WW3RT_RIG1_TOPOX';
files(n).topoy = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOY\102717_WW3RT_RIG1_TOPOYmaps.mat';
files(n).topoydata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOY\102717_WW3RT_RIG1_TOPOY';
files(n).fullflanker = '102717_WW3RT_RIG1\102717_G62WW3RT_RIG1_FULLFLANKER\102717_G62WW3RT_RIG1_FULLFLANKERmaps.mat';
files(n).fullflankerdata = '102717_WW3RT_RIG1\102717_G62WW3RT_RIG1_FULLFLANKER\102717_G62WW3RT_RIG1_FULLFLANKER';
files(n).inject = 'none';
files(n).timing = 'none'; 
files(n).rignum = 'rig1';
files(n).monitor = 'landscape';
files(n).monitorloc = 'center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';

n=n+1;
files(n).subj = 'G62AAA4TT';
files(n).expt = '102717';
files(n).topox= '102717_G62AAA4TT_RIG1\102717_G62AAA4TT_RIG1_TOPOX\102717_G62AAA4TT_RIG1_TOPOXmaps.mat';
files(n).topoxdata = '102717_G62AAA4TT_RIG1\102717_G62AAA4TT_RIG1_TOPOX\102717_G62AAA4TT_RIG1_TOPOX';
files(n).topoy = '102717_G62AAA4TT_RIG1\102717_G62AAA4TT_RIG1_TOPOY\102717_G62AAA4TT_RIG1_TOPOYmaps.mat';
files(n).topoydata = '102717_G62AAA4TT_RIG1\102717_G62AAA4TT_RIG1_TOPOY\102717_G62AAA4TT_RIG1_TOPOY';
files(n).fullflanker = '102717_G62AAA4TT_RIG1\102717_G62AAA4TT_RIG1_FULLFLANKER\102717_G62AAA4TT_RIG1_FULLFLANKERmaps.mat';
files(n).fullflankerdata = '102717_G62AAA4TT_RIG1\102717_G62AAA4TT_RIG1_FULLFLANKER\102717_G62AAA4TT_RIG1_FULLFLANKER';
files(n).inject = 'none';
files(n).timing = 'none'; 
files(n).rignum = 'rig1';
files(n).monitor = 'landscape';
files(n).monitorloc = 'center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';


