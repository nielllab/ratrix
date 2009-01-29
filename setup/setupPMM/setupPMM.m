function r=setupPMM(r,subjects,mode,firstTime,serverName)
%sets protocol of all pmm rats;
%also does setup if firstTime=true      (default is false)
%only defines one rat if mode='testing' (default is 'defineAll')
% r=setupPMM(getRatrix,subjects)          % normal addition to ratrix
% r=setupPMM(getRatrix,{'227','228'})     % example
% r=setupPMM(getRatrix,[],'defineAll')    % smart enough to add all the rats to this *server*
% r=setupPMM(getRatrix,[],'defineAllMale')% useful to define on Rack1Temp, only PMM rats, not pam's
% r=setupPMM(getRatrix,{'test_l1','test_l2','test_l3','test_r1','test_r2','test_r3'})   % redefine only test rats
%
%or the follwing setups- ALL WIPE OUT EXISTING RATRIX
% r=setupPMM([],[],'testing',true,'103')  % setup first time and test one rat on the defined rack
% r=setupPMM([],[],'defineAll',true)       % redefine all PMM from scratch
% r=setupPMM([],{'ttt'},[],true,'103')    % redefine all PMM from scratch


%%
%cd ('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
%setupEnvironment

%%
auth='pmm';

if ~exist('firstTime','var')
    firstTime=false;
end

if ~exist('mode','var')
    mode='defineAll';
end

if ~exist('serverName','var')
    serverName=getServerNameFromIP;
end

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);

if ~exist('r','var') || isempty(r)
    if firstTime
        %build it
        rewardMethod= 'localTimed';
        if ismember(serverName,{'server-01-male-pmm-154','server-02-female-pmm-156'})
            %r=createRatrixWithStationsForRack(rackID,rewardMethod);
            %r=addRatsForRack(rackID,auth);
            firstMakeRatrix(rewardMethod);
        else
            [suc mac]=getMACaddress();
            machines={{'1U',mac,[1 1 1]}};
            r=createRatrixWithDefaultStations(machines,dataPath, rewardMethod,false);
            %subs=createSubjectsFromDB(subjects);
            %for i=1:length(subs)
            %    r=addSubject(r,subs(i),auth);
            %end
            if ismember(serverName,{'101','103'})
                ID=str2num(serverName);
                r=setStandAlonePath(r,getCommonSubjectDir(ID));
            else
                isempty(serverName)
                serverName
                error('unknown serverName')
            end
        end
    else
        %get it
        r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
    end
end

if ~exist('subjects','var') || isempty(subjects)
    
    switch mode
        case 'testing'
            %subjects={'rack2test4','rack2test5','rack2test6'}; %femmes
            %subjects={'rack3test7'}; %femmes, rack3=4
            subjects={'test_r1'}
            %             if firstTime
            %                 r=addTestRats(subjects,auth);
            %             end
            r=setShapingPMM(r,subjects, 'goToLeftDetection', '2_3')
            return
        case 'defineAllFemale'
            %             subjects={'296','303','304','305','306','rack3test7'}
            %
        case 'defineAllMale'
            subjects={'102','117','130','136','137','138','139','227','228','232','229',...
                '230','234','237','272','275','277','274','278','231','233',...
                'test_l1','test_r1','test_l2','test_r2','test_l3','test_r3'}   % plus tests
            %flunked oct 2008: '271','273','276'
            %subjects=createSubjectsFromDB(ids) %see addRatsForRack, but would have to remove pams...?
        case 'defineAll' %everybody in the ratrix gets defined
            subjects=getSubjectIDs(r);
        otherwise
            error('bad mode')
    end
end


%% define all subjects

for i=1:length(subjects)
    disp(sprintf('doing subject %s''s protocol',subjects{i}))
    switch subjects{i}
        case {'test_l1','test_r1','demo1'}
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '2_5validate');
        case {'test_l2','test_r2','test_l3','test_r3','rack2test4','rack2test5','rack2test6','rack3test7'}
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '2_3');
        case {'102'} %127 head fixed
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '1_3');
        case {'117'}
            r=setShapingPMM(r,subjects(i), 'tiltDiscrim', '2_0');
        case {'130'}
            r=setShapingPMM(r,subjects(i), 'tiltDiscrim', '2_0');
        case {'136','137'} %'131' head fixed
            r=setShapingPMM(r,subjects(i), 'goToSide', '1_7');
            %case {'195','196'} pam removed, no longer supported in PMM
            %r=setCoherentDotSteps(r,subjects(i));
        case {'none'} %xfered: '138','139'
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '1_9');
        case {'none'} %removed '235','236','214','219' xfered: 231,232,228,227
            r=setShapingPMM(r,subjects(i), 'goToLeftDetection',  '1_9');
        case {'none'} %removed '238' xfered: 233,'234','230','229','237'
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '1_9');
        case {'271',} %271 flunked oct 2008, xfered '272'
            r=setShapingPMM(r,subjects(i), 'goToLeftDetection',  '2_1');
        case {'275','277'}
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '2_1');
        case {'273'} %xfered: '274'
            r=setShapingPMM(r,subjects(i), 'goToLeftDetection',  '2_2');
        case {'276'} %xfered: '278'
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '2_2');
        case {'231','274','232','228','227','272'}
            r=setShapingPMM(r,subjects(i), 'goToLeftDetection',  '2_3');
        case {'233','234','138','139','230','229','237','278'}
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '2_3');
        case {'303','305','rack3test7'}
            r=setShapingPMM(r,subjects(i), 'goToRightDetection', '2_4');
        case {'296','304','306'}
            r=setShapingPMM(r,subjects(i), 'goToLeftDetection', '2_4');
        otherwise
            if  isHumanSubjectID(subjects{i})
                % is three letters (and maybe numbers follwoing), considered a human subject!
                
                if rem(sum(double(subjects{i}(1:3))),2) % choose half of subjects using odd-valued initial sums
                    r=setHumanExpt(r,subjects(i), 'goToLeftDetection', '2_4',[],false);
                else
                    r=setHumanExpt(r,subjects(i), 'goToRightDetection', '2_4',[],false);
                end
            else
                subjects(i)
                error('that subject is not defined in this setup file')
            end
    end
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


%% old records


%     r=setShapingPMM(r,{'213'}, 'goToLeftDetection', '1_1');
%     r=setCoherentDotSteps(r,{'195'});
%     r=setAcuity(r,{'117'},'tiltDiscrim','1_0');
%     r=setShapingPMM(r,{'131'}, 'goToSide', '1_4');

%     r=setShapingPMM(r,{'135'}, 'goToSide','1_3'); % failed july 21,2008
%     r=setShapingPMM(r,{'144'}, 'tiltDiscrim', '2_0');  % failed july 21,2008
%     r=setShapingPMM(r,{'213','215'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'216'}, 'goToRightDetection', '1_1');  r=setCoherentDotSteps(r,{'195'}); r=setShapingPMM(r,{'144'}, 'tiltDiscrim', '1_1');
%     r=setShapingPMM(r,{'214','219','217'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'218','220'}, 'goToRightDetection', '1_1');  %r=setShapingPMM(r,{'145','146','147','148','129'}, 'tiltDiscrim', '1_2')
%     r=setShapingPMM(r,{'221'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'222'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'106','102'}, 'goToRightDetection', '1_3'); r=setCoherentDotSteps(r,{'196'}); %r=setShapingPMM(r,{'112','126','102','106'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'127'}, 'goToRightDetection', '1_3');  r=setShapingPMM(r,{'116','130','115'}, 'tiltDiscrim', '1_0'); r=setAcuity(r,{'117'},'tiltDiscrim','1_0');   %removed: 114
%     r=setShapingPMM(r,{'138','139'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'132','133'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'134','135'},
%     'goToSide','1_3');%r=setShapingPMM(r,{'136','137','131'}, 'goToSide', '1_4');

%     r=setShapingPMM(r,{'213','215'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'216'}, 'goToRightDetection', '1_1');  r=setCoherentDotSteps(r,{'195'}); r=setShapingPMM(r,{'144'}, 'tiltDiscrim', '1_1');
%     r=setShapingPMM(r,{'214','219','217'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'218','220'}, 'goToRightDetection', '1_1');  %r=setShapingPMM(r,{'145','146','147','148','129'}, 'tiltDiscrim', '1_2')
%     r=setShapingPMM(r,{'221'}, 'goToLeftDetection', '1_1'); r=setShapingPMM(r,{'222'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'106','102'}, 'goToRightDetection', '1_3'); r=setCoherentDotSteps(r,{'196'}); %r=setShapingPMM(r,{'112','126','102','106'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'127'}, 'goToRightDetection', '1_3');  r=setShapingPMM(r,{'116','130','115'}, 'tiltDiscrim', '1_0'); r=setAcuity(r,{'117'},'tiltDiscrim','1_0');   %removed: 114
%     r=setShapingPMM(r,{'138','139'}, 'goToRightDetection', '1_1'); r=setShapingPMM(r,{'132','133','128'}, 'goToRightDetection', '1_3');
%     r=setShapingPMM(r,{'134','135'}, 'goToSide','1_3');%r=setShapingPMM(r,{'136','137','131'}, 'goToSide', '1_4');

