function success = makeMiniDatabase(reloadStepsFromRatrix)


%% set up
if ~exist('reloadStepsFromRatrix','var')
    reloadStepsFromRatrix=0;  %default to 0 because many calls are made to this file during session
    %also, when it slowly trolls all the ratrix db's they could conflict
    %when
    %writing a saving/loading the db.mat, thus ONLY do this when all stations are down
end
success = 0; %
i=0;

%% meaning of steps
%                           1   2   3   4     5          6         7         8       9             10            11           12                 13            14        15     16        17         18          19 
%                           1a  1b  1c  2a    2b         2c        2d        2e      3a            3b            3c           3d                 3e            3f        e1     e2        e3         e4          e5   
%p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,centerOff,linearized,thinner,smaller,dimFlankers,dimmerTarget, strongerFlanker, fullFlankers,flanksToggleToo,varyPosition, vvVH,vvPhases,vvOffsets,vvPhasesOffset,vvVHOffsets})


%% test sample

i=i+1;
database.subject{i}.subjectID='test';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=.1;
database.subject{i}.msPenalty=1001;
%database.subject{i}.currentShapedValue = 0.01; %test wierd values
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='test';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=.1;
database.subject{i}.msPenalty=1001;
%database.subject{i}.currentShapedValue = 0.01; %test wierd values
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='demo1';
database.subject{i}.stepNumber=19;
database.subject{i}.rewardScalar=.1;
database.subject{i}.msPenalty=1001;
database.subject{i}.currentShapedValue = 0.04; %test wierd values
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='test2';
database.subject{i}.stepNumber=2;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%%
i=i+1;
database.subject{i}.subjectID='test_rig1a';
database.subject{i}.stepNumber=1;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='test_rig1b';
database.subject{i}.stepNumber=1;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%%

i=i+1;
database.subject{i}.subjectID='test_l1';
database.subject{i}.stepNumber=16;
database.subject{i}.rewardScalar=.1;
database.subject{i}.msPenalty=1001;
database.subject{i}.currentShapedValue = 0.1;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='test_r1';
database.subject{i}.stepNumber=17;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='test_l2';
database.subject{i}.stepNumber=15;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.currentShapedValue = 0.1;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='test_r2';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='test_l3';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.currentShapedValue = 0.1;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='test_r3';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='rack2test4';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='rack2test5';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='rack2test6';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='rack3test7';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1001;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps
%% each rat

i=i+1;
database.subject{i}.subjectID='102';
database.subject{i}.stepNumber=8;% Graduate to sweep contrast
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='106';
database.subject{i}.stepNumber=8;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='112';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='113';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='114';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=4;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='115';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='116';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=4;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='117';
database.subject{i}.stepNumber=7;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%% 124

i=i+1;
database.subject{i}.subjectID='124';
database.subject{i}.stepNumber=1;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=10;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%%

i=i+1;
database.subject{i}.subjectID='126';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='127';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=300;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='128';
database.subject{i}.stepNumber=10;
database.subject{i}.rewardScalar=6;
database.subject{i}.msPenalty=2000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='129';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='130';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.028 + eps/64; % 0.05 + eps/5.3
database.subject{i}.pctCTs=.1; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='131';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.currentShapedValue = 0.1; %was at 0.4 once
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='132';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=6;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.1;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='133';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=6;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.1;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps



i=i+1;
database.subject{i}.subjectID='134';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.1;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps



i=i+1;
database.subject{i}.subjectID='135';
database.subject{i}.stepNumber=14;
database.subject{i}.rewardScalar=1.5;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='136';
database.subject{i}.stepNumber=10;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=8000;
database.subject{i}.currentShapedValue = 0.5+eps/2; %was at 0.5 once
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='137';
database.subject{i}.stepNumber=10;
database.subject{i}.rewardScalar=1.5;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.6+eps/2; %was at 0.5 once
database.subject{i}.pctCTs=0; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='138';
database.subject{i}.stepNumber=11; % was 10, 13, 11 mix, 11 blocked
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=6000;
%database.subject{i}.currentShapedValue = 0.8;
database.subject{i}.pctCTs=0.1; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='139';
database.subject{i}.stepNumber=6; % was 9, 13, 11blocked, 8 to be easy,
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=10000;
%database.subject{i}.currentShapedValue = 0.4
database.subject{i}.pctCTs=0; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='140';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='141';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=5;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='142';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='143';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=4;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='144';
database.subject{i}.stepNumber=7;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='145';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=5;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='146';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=5;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='147';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=3;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='148';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=4;
database.subject{i}.msPenalty=10000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%% 162 & 164

i=i+1;
database.subject{i}.subjectID='162';
database.subject{i}.stepNumber=1;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=4000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='164';
database.subject{i}.stepNumber=1;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=4000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%%

%pmm is not not supporting adams rats
% i=i+1;
% database.subject{i}.subjectID='195';
% database.subject{i}.stepNumber=2; %found flunked from 5 nov 14. 2008
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=2000;
% database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='196';
database.subject{i}.stepNumber=4;  %found flunked from 7 nov 14. 2008
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=2000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='213';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='214';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='215';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='216';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='217';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='218';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='219';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='220';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='221';
database.subject{i}.stepNumber=4;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='222';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


% i=i+1;
% database.subject{i}.subjectID='223';
% database.subject{i}.stepNumber=3;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;
% 
% i=i+1;
% database.subject{i}.subjectID='224';
% database.subject{i}.stepNumber=5;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;

% i=i+1;
% database.subject{i}.subjectID='225';
% database.subject{i}.stepNumber=2;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;
% 
% i=i+1;
% database.subject{i}.subjectID='226';
% database.subject{i}.stepNumber=3;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;

i=i+1;
database.subject{i}.subjectID='227';
database.subject{i}.stepNumber=17; % was 9, 11, 12
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.4;
database.subject{i}.pctCTs=0; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='228';
database.subject{i}.stepNumber=6; % was 9,13,11blocked, flunked to 8
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.4;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='229';
database.subject{i}.stepNumber=17; % 12
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.8;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='230';
database.subject{i}.stepNumber=17; % was 10,11,12
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=1000;
database.subject{i}.currentShapedValue = 0.8; %was at 0.3 once
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='231';
database.subject{i}.stepNumber=18; %was 10, then 12,14,12, 15, 16,17,18
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=6000;
%database.subject{i}.currentShapedValue = 0.7 + eps/ 2;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='232';
database.subject{i}.stepNumber=17; % was 10, 13,12
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=1000;
%database.subject{i}.currentShapedValue = 0.5 + eps/ 2;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='233';
database.subject{i}.stepNumber=17; %was 9 then 12,13,11,12
database.subject{i}.rewardScalar=1.2;
database.subject{i}.msPenalty=1000;
%database.subject{i}.currentShapedValue = 0.4;% - eps/2;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='234';
database.subject{i}.stepNumber=18; % was 10,14,12,16,18
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.6  + eps/ 2;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='235';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='236';
database.subject{i}.stepNumber=5;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='237';

database.subject{i}.stepNumber=12; % was 10,11
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.7 +eps/2;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='238';
database.subject{i}.stepNumber=6;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=6000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


%DAN TOOK OVER THESE RATS
% i=i+1;  
% database.subject{i}.subjectID='239';
% database.subject{i}.stepNumber=4;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;

% i=i+1;
% database.subject{i}.subjectID='240';
% database.subject{i}.stepNumber=3;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;
% 
% i=i+1;
% database.subject{i}.subjectID='241';
% database.subject{i}.stepNumber=5;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=6000;
% 
% i=i+1;
% database.subject{i}.subjectID='242';
% database.subject{i}.stepNumber=5;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=6000;




i=i+1;
database.subject{i}.subjectID='271';
database.subject{i}.stepNumber=1; % gone, now set to 1
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='272';
database.subject{i}.stepNumber=11; % was 9
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.currentShapedValue = 0.4
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='273';
database.subject{i}.stepNumber=1;  % gone, now set to 1
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='274';
database.subject{i}.stepNumber=14; %was 7==10
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=10000;
database.subject{i}.currentShapedValue = 0.5 + eps/ 2;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='275';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=1000;
database.subject{i}.currentShapedValue = 0.2;
database.subject{i}.pctCTs=[0.1]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='276';
database.subject{i}.stepNumber=1;  % gone, now set to 1
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=1000;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='277';
database.subject{i}.stepNumber=11;
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=1000;
database.subject{i}.currentShapedValue=0.1;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps


i=i+1;
database.subject{i}.subjectID='278';
database.subject{i}.stepNumber=12; 
database.subject{i}.rewardScalar=2;
database.subject{i}.msPenalty=1000;
database.subject{i}.currentShapedValue = 0.4; %+ eps/ 4;
database.subject{i}.pctCTs=[]; %if not empty overrides all steps


% i=i+1;  % probably never used - false appendage
% database.subject{i}.subjectID='297';
% database.subject{i}.stepNumber=2;
% database.subject{i}.rewardScalar=1;
% database.subject{i}.msPenalty=1000;
% % database.subject{i}.currentShapedValue = 0.4; %+ eps/ 4;
% database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='296';
database.subject{i}.stepNumber=11;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=4000;
database.subject{i}.currentShapedValue = 0.1;% 3 + eps/ 4; %+ eps/ 4;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps


% i=i+1;
% database.subject{i}.subjectID='303';
% database.subject{i}.stepNumber=5;
% database.subject{i}.rewardScalar=0.2;
% database.subject{i}.msPenalty=1000;
% % database.subject{i}.currentShapedValue = 0.4; %+ eps/ 4;
% database.subject{i}.pctCTs=[]; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='304';
database.subject{i}.stepNumber=8;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=4000;
% database.subject{i}.currentShapedValue = 0.4; %+ eps/ 4;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='305';
database.subject{i}.stepNumber=9;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=4000;
database.subject{i}.currentShapedValue = 0.2; %+ eps/ 4;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps

i=i+1;
database.subject{i}.subjectID='306';
database.subject{i}.stepNumber=11;
database.subject{i}.rewardScalar=1;
database.subject{i}.msPenalty=4000;
database.subject{i}.currentShapedValue = 0.1; %0.3+eps/4; %+ eps/ 4;
database.subject{i}.pctCTs=.1; %if not empty overrides all steps
%% reloadStepsFromRatrix
%make sure to get the current steps with getStepNumFromRemoteRatrix or
%getStepNumFromRecords

stepsLeftTheSame = 0;
shapingValuesChanged = 0;
totalShapingValuesFound=0;
numStepsChanged =0;

if reloadStepsFromRatrix
    %steps=getStepNumFromRemoteRatrix;
    serverPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData','ServerData',filesep);
    load([serverPath 'db.mat'])
    state=getBasicFacts(r,0);
    %state2=getStepStateFromRecords;  %uses smallData...
%     error('confirm that currentShapedValue change detector actually works');
    %testStep=cell2mat(steps(strcmp('test',steps(:,1)),2));
    %twoMethodsTheSame=all(cell2mat(steps(:,2))'==[cell2mat(steps2(:,2))' testStep]) %confirmed it works pmm080203
    for i=1:size(database.subject,2)
        for j=1:size(state,1)
            if strcmp(state(j,1),database.subject{i}.subjectID)
                
                if database.subject{i}.stepNumber~=cell2mat(state(j,2))
                    disp(sprintf('changing %s''s step from listed %d to ratrix defined %d', database.subject{i}.subjectID,database.subject{i}.stepNumber,cell2mat(state(j,2))))
                    database.subject{i}.stepNumber=cell2mat(state(j,2));
                    numStepsChanged=numStepsChanged+1;
                else
                    stepsLeftTheSame=stepsLeftTheSame+1;
                end
                
                
                %
                f = fields(database.subject{i});
                if( ismember('currentShapedValue',f))
                    if database.subject{i}.currentShapedValue~=cell2mat(state(j,9))
                        disp(sprintf('changing %s''s shapingValue from listed %2.2g to ratrix defined %2.2g', database.subject{i}.subjectID,database.subject{i}.currentShapedValue,cell2mat(state(j,9))))
                        diff=-(database.subject{i}.currentShapedValue-cell2mat(state(j,9)));
                        diffSubj=database.subject{i}.subjectID;
                        diffSubjID=i;
                        if diff<0.000001
                            disp(sprintf('in %s''s shapingValue there is a difference of %2.6g, use %2.2g + eps/%2.2g ',diffSubj,diff,database.subject{diffSubjID}.currentShapedValue,eps/diff))
                        end
                        database.subject{i}.currentShapedValue=cell2mat(state(j,9));
                        shapingValuesChanged = shapingValuesChanged + 1;
                    else
                        %do nothing
                    end
                    totalShapingValuesFound=totalShapingValuesFound+1;
                else
                    if ~isempty(cell2mat(state(j,9)))
                        %database.subject{i}
                        disp(sprintf('need to add ''database.subject{i}.currentShapedValue = %2.2g'' for %s',cell2mat(state(j,9)),database.subject{i}.subjectID))
                    end
                end
            end
        end
    end
    %stepsLeftTheSame=stepsLeftTheSame
    %totalRats=size(state,1)
    totalShapingValuesFound
    shapingValuesChanged = shapingValuesChanged
    numStepsChanged=numStepsChanged
else

    %if not getting steps from ratrix, get the
end


%%

save miniDatabase.mat database;

success = 1;
