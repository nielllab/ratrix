%% quick inspect - simple user interface

%close all

serverID=          3;  %male =1, female=3?; rig=101;
heatViewed=        0;  %1-6; filters which heat    (RED =1 etc),   0 allows all rats and weeklyReports
stationViewed=     0;  %1-6; filters which station (stationA=1 etc), 0 allows all stations
justSome=          1;  %0 is default heat & station defined, 1 to view explicit list
suppressUpdates=   1;  %don't update - server does that! can cause collisions with mulitple users
%manual compile: compileDetailedRecords('server-01-male-pmm-154')

daysBackAnalyzed=  900;  %at least 8 if using weeklyReport
seeBW=             1;  %1 if you want to see body weights, 0 otherwise
more=              0;  %see more plots

%whichOnes={'230','227','229','237','232','233','139','228','234','231','275','277','278','138','130'}; %males
%whichOnes={'test_r1'}; 
%whichOnes={'232','234'}
%whichOnes={'303'}; 
whichOnes={'304','305','306','296'};  % corrupt file
%whichOnes={%'137','275','277','136','139'};   %low body weight
%whichOnes={'228','130','102','277','136','237'} %riskier BW
%whichOnes={'273','232','274','137','275','139'} % less risky BW
%whichOnes={'138','139','227','228'}; % CTs off
%whichOnes={'227','228','229','234','237','274'}; % penaltyIncresed?
%whichOnes={'231','234','274'}; % orientationSweep
%whichOnes={'138','139','228','232','233'}; %varyPosition
%whichOnes={'227','229','230','237'}; % constant test%
%whichOnes={'102','275','278'}% oddballs

subjects=getCurrentSubjects(serverID); %this will always be the active list of rats in that rack
doQuickInspect(subjects,heatViewed,stationViewed,daysBackAnalyzed,suppressUpdates,seeBW,justSome,whichOnes,more,serverID);
%pmmInspect



