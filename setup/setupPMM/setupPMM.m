function setupPMM(firstTime)
%sets protocol of all pmm rats;  also does setup if firsTime=true

%%

%cd ('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
%setupEnvironment

auth='pmm';

if ~exist('firstTime','var')
    firstTime=false;
end

if firstTime
    rackID=1;
    r=createRatrixWithStationsForRack(rackID);
    r=addRatsForRack(rackID,auth);
    %numTestRats=3;
    %r=addTestRats(numTestRats,auth);
    r=setPermanentStorePath(r,getSubDirForRack(rackID))
else
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
    r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
end

%%
testSubjects={'l','r','s','t','u','v'};

testSubjects={'t','u','v'};
% r=addTestRats(testSubjects,auth) %maybe defined in oracle db
% r=setShapingPMM(r,testSubjects, 'tiltDiscrim', '1_5');




r=setShapingPMM(r,testSubjects, 'goToSide', '1_0');
%r=setShapingPMM(r,{'213'}, 'goToLeftDetection', '1_1');
%  r=setCoherentDotSteps(r,{'195'});
%  r=setAcuity(r,{'117'},'tiltDiscrim','1_0');
%  r=setShapingPMM(r,{'131'}, 'goToSide', '1_4');
 %r=setShapingPMM(r,{'t'},'goToRightDetection', '1_8')



if 1

     r=setShapingPMM(r,{'144'}, 'tiltDiscrim', '2_0');

     r=setShapingPMM(r,{'117'},'tiltDiscrim','2_0'); 
     r=setShapingPMM(r,{'138','139'}, 'goToRightDetection', '1_9'); 
     r=setShapingPMM(r,{'135'}, 'goToSide','1_3'); 
     r=setShapingPMM(r,{'136','137','131'}, 'goToSide', '1_7');
     r=setCoherentDotSteps(r,{'195','196'});
     
     r=setShapingPMM(r,{'130'}, 'tiltDiscrim', '2_0');
     r=setShapingPMM(r,{'102','127'}, 'goToRightDetection', '1_3'); 
     r=setShapingPMM(r,{'227','228','231','232'}, 'goToLeftDetection', '1_9'); %removed '235','236','214','219' 
     r=setShapingPMM(r,{'229','230','233','234','237','238'}, 'goToRightDetection', '1_9');
     
     r=setShapingPMM(r,{'271','272'}, 'goToLeftDetection', '2_1');
     r=setShapingPMM(r,{'275','277'}, 'goToRightDetection', '2_1');
     
     r=setShapingPMM(r,{'273','274'}, 'goToLeftDetection', '2_2');
     r=setShapingPMM(r,{'276','278'}, 'goToRightDetection', '2_2');


%     r=setShapingPMM(r,{'213','215'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'216'}, 'goToRightDetection', '1_1');  r=setCoherentDotSteps(r,{'195'}); r=setShapingPMM(r,{'144'}, 'tiltDiscrim', '1_1');
%     r=setShapingPMM(r,{'214','219','217'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'218','220'}, 'goToRightDetection', '1_1');  %r=setShapingPMM(r,{'145','146','147','148','129'}, 'tiltDiscrim', '1_2')
%     r=setShapingPMM(r,{'221'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'222'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'106','102'}, 'goToRightDetection', '1_3'); r=setCoherentDotSteps(r,{'196'}); %r=setShapingPMM(r,{'112','126','102','106'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'127'}, 'goToRightDetection', '1_3');  r=setShapingPMM(r,{'116','130','115'}, 'tiltDiscrim', '1_0'); r=setAcuity(r,{'117'},'tiltDiscrim','1_0');   %removed: 114
%     r=setShapingPMM(r,{'138','139'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'132','133'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'134','135'}, 'goToSide','1_3');%r=setShapingPMM(r,{'136','137','131'}, 'goToSide', '1_4');
end




%% DOUBLE CHECK BEFORE DEPLOYING
%miniDataBase location away from test location find  'miniDatabasePath ='
%defining rat per station
%force quit (or confirm overwrite doesn't send ratSubjectInit)
%force initialization
%state of default reloadStepsFromRatrix in makeMiniDatabase
% Confirm minidatabase/rig1/minidatabase.mat does not interfere! 08/02/07


%% Upon adding new rats

%getCurrentSubjects -- active list of heats
%findStationsForSubject -- subject station pairing
%RatSubjectInit -- protocol defined
%makeMiniDatabase -- define starting values

%     r=setShapingPMM(r,{'213','215'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'216'}, 'goToRightDetection', '1_1');  r=setCoherentDotSteps(r,{'195'}); r=setShapingPMM(r,{'144'}, 'tiltDiscrim', '1_1');
%     r=setShapingPMM(r,{'214','219','217'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'218','220'}, 'goToRightDetection', '1_1');  %r=setShapingPMM(r,{'145','146','147','148','129'}, 'tiltDiscrim', '1_2')
%     r=setShapingPMM(r,{'221'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'222'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'106','102'}, 'goToRightDetection', '1_3'); r=setCoherentDotSteps(r,{'196'}); %r=setShapingPMM(r,{'112','126','102','106'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'127'}, 'goToRightDetection', '1_3');  r=setShapingPMM(r,{'116','130','115'}, 'tiltDiscrim', '1_0'); r=setAcuity(r,{'117'},'tiltDiscrim','1_0');   %removed: 114
%     r=setShapingPMM(r,{'138','139'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'132','133','128'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'134','135'}, 'goToSide','1_3');%r=setShapingPMM(r,{'136','137','131'}, 'goToSide', '1_4');

