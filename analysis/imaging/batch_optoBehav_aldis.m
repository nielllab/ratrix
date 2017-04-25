%batch_optoBehav_aldis


clear all
close all
dbstop if error
%trialRecpathname = '\\lee\Users\nlab\Desktop\ballData2\PermanentTrialRecordStore\';  
trialRecpathname = '\\langevin\backup\ballData2\PermanentTrialRecordStore\';  

%outpathname = '';
n=0;




%pvchr4b3ttLt
n=n+1;
files(n).subj = 'pvchr4b3ttL';
files(n).expt = '041217';
files(n).trialRec =  'trialRecords_1-232_20170412T092700-20170412T103036.mat';
files(n).power = '11mw';
files(n).task = 'GTS';
files(n).geno = 'Pv ChR2';
files(n).notes = 'good session'; %
files(n).monitor = 'vert';
files(n).SilenceArea = 'full window';



% 
% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).trialRec =  '';
% files(n).power = '';
% files(n).task = '';
% files(n).geno = 'pv chr2';
% files(n).notes = 'good session'; 
% files(n).monitor = 'vert';
% files(n).SilenceArea = '';


