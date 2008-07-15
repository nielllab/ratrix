%% quick inspect - simple user interface

close all

heatViewed=       [0];  %1-6; filters which heat    (RED =1 etc),   0 allows all rats and weeklyReports
stationViewed=     0;  %1-6; filters which station (stationA=1 etc), 0 allows all stations
daysBackAnalyzed= 600;  %at least 8 if using weeklyReport
seeBW=             0;  %1 if you want to see body weights, 0 otherwise
justOne=           0;  %0 is default, 1 to view a single rat
whichOne={'162'};      %only used ifjustOne=1
more=              0;  %see more plots
rackNum=           1;  %male =1, female=2; gingers=3; rig=101;

suppressUpdates=   1;  %don't update - server does that! can cause collisions with mulitple users

subjects=getCurrentSubjects(rackNum); %this will always be the active list of rats in that rack
%subjects=whichOne;
doQuickInspect(subjects,heatViewed,stationViewed,daysBackAnalyzed,suppressUpdates,seeBW,justOne,whichOne,more,rackNum);
%pmmInspect