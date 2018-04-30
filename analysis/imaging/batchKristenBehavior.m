%batchKristenBehavior
dbstop if error
n = 0;

%%langevin path
pathname = '\\langevin\backup\widefield\Kristen\Behavior\';
datapathname = '\\langevin\backup\widefield\Kristen\Behavior\';  
outpathname = '\\langevin\backup\widefield\Kristen\Behavior\';

% % local path
% pathname = 'C:\Users\nlab\Desktop\Data\Kristen\';
% datapathname = 'C:\Users\nlab\Desktop\Data\Kristen\';
% outpathname = 'C:\Users\nlab\Desktop\Data\Kristen\';

% n=n+1;
% files(n).subj = 'WW3RT';
% files(n).expt = '102717';
% files(n).topox= '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOX\102717_WW3RT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOX\102717_WW3RT_RIG1_TOPOX';
% files(n).topoy = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOY\102717_WW3RT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_TOPOY\102717_WW3RT_RIG1_TOPOY';
% files(n).fullflanker = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_FULLFLANKER\102717_WW3RT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '102717_WW3RT_RIG1\102717_WW3RT_RIG1_FULLFLANKER\102717_WW3RT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% n=n+1;
% files(n).subj = 'SS4LT';
% files(n).expt = '110417';
% files(n).topox= '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOX\110417_SS4LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOX\110417_SS4LT_RIG1_TOPOX';
% files(n).topoy = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOY\110417_SS4LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_TOPOY\110417_SS4LT_RIG1_TOPOY';
% files(n).fullflanker = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_FULLFLANKER\110417_SS4LT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '110417_SS4LT_RIG1\110417_SS4LT_RIG1_FULLFLANKER\110417_SS4LT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% n=n+1;
% files(n).subj = 'G62AAA4TT';
% files(n).expt = '111817';
% files(n).topox= '111817_G62AAA4TT_RIG1\111817_G62AAA4TT_RIG1_TOPOX\111817_G62AAA4TT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '111817_G62AAA4TT_RIG1\111817_G62AAA4TT_RIG1_TOPOX\111817_G62AAA4TT_RIG1_TOPOX';
% files(n).topoy = '111817_G62AAA4TT_RIG1\111817_G62AAA4TT_RIG1_TOPOY\111817_G62AAA4TT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '111817_G62AAA4TT_RIG1\111817_G62AAA4TT_RIG1_TOPOY\111817_G62AAA4TT_RIG1_TOPOY';
% files(n).fullflanker = '111817_G62AAA4TT_RIG1\111817_G62AAA4TT_RIG1_FULLFLANKER\111817_G62AAA4TT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '111817_G62AAA4TT_RIG1\111817_G62AAA4TT_RIG1_FULLFLANKER\111817_G62AAA4TT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% n=n+1;
% files(n).subj = 'DDD4LT';
% files(n).expt = '120117';
% files(n).topox= '120117_DDD4LT_RIG1\120117_DDD4LT_RIG1_TOPOX\120117_DDD4LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '120117_DDD4LT_RIG1\120117_DDD4LT_RIG1_TOPOX\120117_DDD4LT_RIG1_TOPOX';
% files(n).topoy = '120117_DDD4LT_RIG1\120117_DDD4LT_RIG1_TOPOY\120117_DDD4LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '120117_DDD4LT_RIG1\120117_DDD4LT_RIG1_TOPOY\120117_DDD4LT_RIG1_TOPOY';
% files(n).fullflanker = '120117_DDD4LT_RIG1\120117_DDD4LT_RIG1_FULLFLANKER\120117_DDD4LT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '120117_DDD4LT_RIG1\120117_DDD4LT_RIG1_FULLFLANKER\120117_DDD4LT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% n=n+1;
% files(n).subj = 'G6H42LT';
% files(n).expt = '121117';
% files(n).topox= '121117_G6H42LT_RIG1\121117_G6H42LT_RIG1_TOPOX\121117_G6H42LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '121117_G6H42LT_RIG1\121117_G6H42LT_RIG1_TOPOX\121117_G6H42LT_RIG1_TOPOX';
% files(n).topoy = '121117_G6H42LT_RIG1\121117_G6H42LT_RIG1_TOPOY\121117_G6H42LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '121117_G6H42LT_RIG1\121117_G6H42LT_RIG1_TOPOY\121117_G6H42LT_RIG1_TOPOY';
% files(n).fullflanker = '121117_G6H42LT_RIG1\121117_G6H42LT_RIG1_FULLFLANKER\121117_G6H42LT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '121117_G6H42LT_RIG1\121117_G6H42LT_RIG1_FULLFLANKER\121117_G6H42LT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% n=n+1;
% files(n).subj = 'G6H42LT';
% files(n).expt = '121217';
% files(n).topox= '121217_G6H42LT_RIG1\121217_G6H42LT_RIG1_TOPOX\121217_G6H42LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '121217_G6H42LT_RIG1\121217_G6H42LT_RIG1_TOPOX\121217_G6H42LT_RIG1_TOPOX';
% files(n).topoy = '121217_G6H42LT_RIG1\121217_G6H42LT_RIG1_TOPOY\121217_G6H42LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '121217_G6H42LT_RIG1\121217_G6H42LT_RIG1_TOPOY\121217_G6H42LT_RIG1_TOPOY';
% files(n).fullflanker = '121217_G6H42LT_RIG1\121217_G6H42LT_RIG1_FULLFLANKER\121217_G6H42LT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '121217_G6H42LT_RIG1\121217_G6H42LT_RIG1_FULLFLANKER\121217_G6H42LT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% n=n+1;
% files(n).subj = 'G6H510LT';
% files(n).expt = '031617';
% files(n).topox= '031617_G6H510LT_RIG1\031617_G6H510LT_RIG1_TOPOX\031617_G6H510LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '031617_G6H510LT_RIG1\031617_G6H510LT_RIG1_TOPOX\031617_G6H510LT_RIG1_TOPOX';
% files(n).topoy = '031617_G6H510LT_RIG1\031617_G6H510LT_RIG1_TOPOY\031617_G6H510LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '031617_G6H510LT_RIG1\031617_G6H510LT_RIG1_TOPOY\031617_G6H510LT_RIG1_TOPOY';
% files(n).fullflanker = '031617_G6H510LT_RIG1\031617_G6H510LT_RIG1_FULLFLANKER\031617_G6H510LT_RIG1_FULLFLANKERmaps.mat';
% files(n).fullflankerdata = '031617_G6H510LT_RIG1\031617_G6H510LT_RIG1_FULLFLANKER\031617_G6H510LT_RIG1_FULLFLANKER';
% files(n).inject = 'none';
% files(n).timing = 'none'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'landscape';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';

% %%
% n=n+1;
% files(n).subj = 'G6H67LT';
% files(n).expt = '031717';
% files(n).topox= '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOX\031717_G6H67LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOX\031717_G6H67LT_RIG1_TOPOX';
% files(n).topoy = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOY\031717_G6H67LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOY\031717_G6H67LT_RIG1_TOPOY';
% files(n).patchgratings = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_GRATING_PRE_CLOZ\031717_G6H67LT_RIG1_GRATING_PREmaps.mat';
% files(n).patchgratingsdata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_GRATING_PRE_CLOZ\031717_G6H67LT_RIG1_GRATING_PRE';
% files(n).cond = 'clozapine';
% files(n).dose = '0.1'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'pre'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).gratingpatchpts = fullfile(outpathname,'031717_G6H67LT_RIG1_gratingpatchpts.mat');
% 
% n=n+1;
% files(n).subj = 'G6H67LT';
% files(n).expt = '031717';
% files(n).topox= '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOX\031717_G6H67LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOX\031717_G6H67LT_RIG1_TOPOX';
% files(n).topoy = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOY\031717_G6H67LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOY\031717_G6H67LT_RIG1_TOPOY';
% files(n).patchgratings = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_GRATING_POST_CLOZ\031717_G6H67LT_RIG1_GRATING_POSTmaps.mat';
% files(n).patchgratingsdata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_GRATING_POST_CLOZ\031717_G6H67LT_RIG1_GRATING_POST';
% files(n).cond = 'clozapine';
% files(n).dose = '0.1'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'post'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).gratingpatchpts = fullfile(outpathname,'031717_G6H67LT_RIG1_gratingpatchpts.mat');
% 
% n=n+1;
% files(n).subj = 'G6H67LT';
% files(n).expt = '031717';
% files(n).topox= '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOX\031717_G6H67LT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOX\031717_G6H67LT_RIG1_TOPOX';
% files(n).topoy = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOY\031717_G6H67LT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_TOPOY\031717_G6H67LT_RIG1_TOPOY';
% files(n).patchgratings = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_GRATING_SUPERPOST_CLOZ\031717_G6H67LT_RIG1_GRATING_SUPERPOSTmaps.mat';
% files(n).patchgratingsdata = '031717_G6H67LT_RIG1\031717_G6H67LT_RIG1_GRATING_SUPERPOST_CLOZ\031717_G6H67LT_RIG1_GRATING_SUPERPOST';
% files(n).cond = 'clozapine';
% files(n).dose = '0.1'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'superpost'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).gratingpatchpts = fullfile(outpathname,'031717_G6H67LT_RIG1_gratingpatchpts.mat');

%% LP gcamp mouse

% pre, grating

n=n+1;
files(n).subj = 'G6H316TT';
files(n).expt = '031817';
files(n).topox= '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOXmaps.mat';
files(n).topoxdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOX';
files(n).topoy = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOYmaps.mat';
files(n).topoydata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOY';
files(n).patchgratings = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_PRE_CLOZ\031817_G6H316TT_RIG1_GRATING_PREmaps.mat';
files(n).patchgratingsdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_PRE_CLOZ\031817_G6H316TT_RIG1_GRATING_PRE';
files(n).cond = 'clozapine';
files(n).dose = '0.1'; %mg/kg
files(n).dreadds = 'lp';
files(n).timing = 'post'; 
files(n).rignum = 'rig1';
files(n).monitor = 'land';
files(n).monitorloc = 'center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).gratingpatchpts = fullfile(outpathname,'032218_G6H112RT_RIG1_gratingpatchpts.mat');

% post, grating

n=n+1;
files(n).subj = 'G6H316TT';
files(n).expt = '031817';
files(n).topox= '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOXmaps.mat';
files(n).topoxdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOX';
files(n).topoy = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOYmaps.mat';
files(n).topoydata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOY';
files(n).patchgratings = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_POST_CLOZ\031817_G6H316TT_RIG1_GRATING_POSTmaps.mat';
files(n).patchgratingsdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_POST_CLOZ\031817_G6H316TT_RIG1_GRATING_POST';
files(n).cond = 'clozapine';
files(n).dose = '0.1'; %mg/kg
files(n).dreadds = 'lp';
files(n).timing = 'pre'; 
files(n).rignum = 'rig1';
files(n).monitor = 'land';
files(n).monitorloc = 'center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).gratingpatchpts = fullfile(outpathname,'032218_G6H112RT_RIG1_gratingpatchpts.mat');
 
% superpost, grating

n=n+1;
files(n).subj = 'G6H316TT';
files(n).expt = '031817';
files(n).topox= '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOXmaps.mat';
files(n).topoxdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOX';
files(n).topoy = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOYmaps.mat';
files(n).topoydata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOY';
files(n).patchgratings = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_SUPERPOST_CLOZ\031817_G6H316TT_RIG1_GRATING_SUPERPOSTmaps.mat';
files(n).patchgratingsdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_SUPERPOST_CLOZ\031817_G6H316TT_RIG1_GRATING_SUPERPOST';
files(n).cond = 'clozapine';
files(n).dose = '0.1'; %mg/kg
files(n).dreadds = 'lp';
files(n).timing = 'pre'; 
files(n).rignum = 'rig1';
files(n).monitor = 'land';
files(n).monitorloc = 'center';
files(n).label = 'camk2 gc6';
files(n).notes = 'good imaging session';
files(n).gratingpatchpts = fullfile(outpathname,'032218_G6H112RT_RIG1_gratingpatchpts.mat');

% NO superpost topox % topoy were done for this guy
% pre, topox & topoy

% n=n+1;
% files(n).subj = 'G6H316TT';
% files(n).expt = '031817';
% files(n).topox= '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOXmaps.mat';
% files(n).topoxdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOX\031817_G6H316TT_RIG1_TOPOX';
% files(n).topoy = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOYmaps.mat';
% files(n).topoydata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_TOPOY\031817_G6H316TT_RIG1_TOPOY';
% files(n).cond = 'clozapine';
% files(n).dose = '0.1'; %mg/kg
% files(n).dreadds = 'lp';
% files(n).timing = 'pre'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'topo only';
% 
% % superpost, topox & topoy
% 
% n=n+1;
% files(n).subj = 'G6H316TT';
% files(n).expt = '031817';
% files(n).topox= '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOX\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOXmaps.mat';
% files(n).topoxdata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOX\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOX';
% files(n).topoy = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOY\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOYmaps.mat';
% files(n).topoydata = '031817_G6H316TT_RIG1\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOY\031817_G6H316TT_RIG1_GRATING_SUPERPOST_TOPOY';
% files(n).cond = 'clozapine';
% files(n).dose = '0.1'; %mg/kg
% files(n).dreadds = 'lp';
% files(n).timing = 'post'; 
% files(n).rignum = 'rig1';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'topo only';

%%

% pre, grating

% n=n+1;
% files(n).subj = 'G6H112RT';
% files(n).expt = '032218';
% files(n).topox= '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOX';
% files(n).topoy = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOY';
% files(n).patchgratings = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_PRE_CLOZ_GRATING\032218_G6H112RT_RIG2_PRE_CLOZ_GRATINGmaps.mat';
% files(n).patchgratingsdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_PRE_CLOZ_GRATING\032218_G6H112RT_RIG2_PRE_CLOZ_GRATING';
% files(n).cond = 'CNO';
% files(n).dose = '10'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'pre'; 
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).gratingpatchpts = fullfile(outpathname,'032218_G6H112RT_RIG2_gratingpatchpts.mat');
% 
% % post, grating
% 
% n=n+1;
% files(n).subj = 'G6H112RT';
% files(n).expt = '032218';
% files(n).topox= '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOX';
% files(n).topoy = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOY';
% files(n).patchgratings = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_POST_CLOZ_GRATING\032218_G6H112RT_RIG2_POST_CLOZ_GRATINGmaps.mat';
% files(n).patchgratingsdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_POST_CLOZ_GRATING\032218_G6H112RT_RIG2_POST_CLOZ_GRATING';
% files(n).cond = 'CNO';
% files(n).dose = '10'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'post'; 
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).gratingpatchpts = fullfile(outpathname,'032218_G6H112RT_RIG2_gratingpatchpts.mat');
% 
% % superpost, grating
% 
% n=n+1;
% files(n).subj = 'G6H112RT';
% files(n).expt = '032218';
% files(n).topox= '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOX';
% files(n).topoy = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOY';
% files(n).patchgratings = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_GRATING\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_GRATINGmaps.mat';
% files(n).patchgratingsdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_GRATING\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_GRATING';
% files(n).cond = 'CNO';
% files(n).dose = '10'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'superpost'; 
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'good imaging session';
% files(n).gratingpatchpts = fullfile(outpathname,'032218_G6H112RT_RIG2_gratingpatchpts.mat');
% 
% % pre, topox & topoy
% 
% n=n+1;
% files(n).subj = 'G6H112RT';
% files(n).expt = '032218';
% files(n).topox= '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOXmaps.mat';
% files(n).topoxdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOX\032218_G6H112RT_RIG2_TOPOX';
% files(n).topoy = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOYmaps.mat';
% files(n).topoydata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_TOPOY\032218_G6H112RT_RIG2_TOPOY';
% files(n).cond = 'CNO';
% files(n).dose = '10'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'pre'; 
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'topo only';
% 
% % superpost, topox & topoy
% 
% n=n+1;
% files(n).subj = 'G6H112RT';
% files(n).expt = '032218';
% files(n).topox= '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOX\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOXmaps.mat';
% files(n).topoxdata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOX\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOX';
% files(n).topoy = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOY\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOYmaps.mat';
% files(n).topoydata = '032218_G6H112RT_RIG2\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOY\032218_G6H112RT_RIG2_SUPERPOST_CLOZ_TOPOY';
% files(n).cond = 'CNO';
% files(n).dose = '10'; %mg/kg
% files(n).dreadds = 'lgn';
% files(n).timing = 'post'; 
% files(n).rignum = 'rig2';
% files(n).monitor = 'land';
% files(n).monitorloc = 'center';
% files(n).label = 'camk2 gc6';
% files(n).notes = 'topo only';
