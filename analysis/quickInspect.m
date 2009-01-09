%% quick inspect - simple user interface

close all

heatViewed=        0;  %1-6; filters which heat    (RED =1 etc),   0 allows all rats and weeklyReports
stationViewed=     0;  %1-6; filters which station (stationA=1 etc), 0 allows all stations
daysBackAnalyzed= 20;  %at least 8 if using weeklyReport
seeBW=             0;  %1 if you want to see body weights, 0 otherwise
justOne=           1;  %0 is default, 1 to view a single rat
whichOne={'237'}; 
%whichOne={'296','304','304','305','306'}; 
%whichOne={%'137','275','277','136','139'};   %low body weight
%whichOne={'228','130','102','277','136','237'} %riskier BW
%whichOne={'273','232','274','137','275','139'} % less risky BW
%whichOne={'138','139','227','228'}; % CTs off
%whichOne={'227','228','229','234','237','274'}; % penaltyIncresed?
%whichOne={'231','234','274'}; % orientationSweep
whichOne={'138','139','228','232','233'}; %varyPosition
%whichOne={'227','229','230','237'}; % constant test%
%whichOne={'272', '136', '229', '275', '231','274'}% recommended getting rid of
%whichOne={'234', '278', '233'} % recommended getting rid of
more=              0;  %see more plots
rackNum=           1;  %male =1, female=2; gingers=3; rig=101;

suppressUpdates=   1;  %don't update - server does that! can cause collisions with mulitple users

subjects=getCurrentSubjects(rackNum); %this will always be the active list of rats in that rack
%subjects=whichOne;
doQuickInspect(subjects,heatViewed,stationViewed,daysBackAnalyzed,suppressUpdates,seeBW,justOne,whichOne,more,rackNum);
%pmmInspect



