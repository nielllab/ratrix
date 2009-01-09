%080825 New cohort of rats to be pre-trained for LGN lesions
% COHORT 1 BLINDSIGHT PROJECT
% NB running on male ratrix under the rack1Temp tag

% FIRST assign the rats to heats in the Oracle database 
% DONE 9/8/2008 after red heat has already run.
% 284, 285 -> Red1A,B
% 286, 287 -> Red1C,D **cockpits**
% 288, 289 -> Red1E,F
% 290, 291 -> Blue1F, Violet 1C (cockpit)

% NOTE the protocol has NOT been tested on testrats yet
% and the rats have NOT been assigned to protocol on the server yet

%on pam's desktop
%cd('C:\Documents and Settings\PREINAGEL\Desktop\Rack1Temp\bootstrap')

%these lines run on 9/9/08 at 11am PR
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
reportSettings % verify new rats are listed but "none" for step
%% NOW add rats to rack
r=addRatsForRack(1,'pmm') %?? gets rats from oracle database and creates if not there?
%%% DID NOT WORK because DOBs not in database
% try again later
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% after updating oracle database...
r=addRatsForRack(1,'pmm') %?? gets rats from oracle database and creates if not there?
% worked for first six rats (red heat) but then seemed to crash because
% it tried to add rat 225 which already existed. probably no harm done to
% other heats but the later rats  in blue and violet were not added.



% BEFORE testing on rats try on test subjects
% need to assign these to the test heat on oracle DB
%9/10/08 resume debugging
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'l',    'r',    's' ,   't' ,   'u'  , 'v'}; % 6 TEST rats
% subjIDs={'23',    '24',    '25' ,   '19' ,   '20'  , '21'}; % 6 TEST rats
setProtocol_VisionBattery1(subjIDs); % worked but I can't assign those rats to heats at the moment
% just try with my rats now, test other steps later!

% this protocol contains 10 training steps starting with free drinks, 
% then coherent dots, go to side, go to horizontal
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'284','285','286','287','288','289'}; % '290', '291' NOT DONE 8 naive male rats
setProtocol_VisionBattery1(subjIDs); %
% RAN 9/10/08 at 2pm. ready to try rats!!
% FAILED at ts3, "non-existent field 'correctionTrial'."
% test if code exactly as per Adam's rats will work; changed ts3 only 
% note standalonetest isn't working so I can only test on the ratrix!
% note 

%%attempted changes to ts3 (for rats) and move test rat to ts2
% run 9/13 at 8am
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'284','285','286','287','288','289'}; % '290', '291' NOT DONE 8 naive male rats
setProtocol_VisionBattery1(subjIDs); % apply the ts3 update
%subjIDs={'23',    '24',    '25' ,   '19' ,   '20'  , '21'}; % 6 TEST rats
subjIDs={'l',    'r',    's' ,   't' ,   'u'  , 'v'}; % 6 TEST rats
setProtocol_VisionBattery1(subjIDs); %  

% use new function addNewSubject (which relies on createSubjectsFromDB)
% to add 290 and 291 (failed above)
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'290', '291'};
r = addNewSubject(r,subjIDs); % worked!
setProtocol_VisionBattery1(subjIDs); % should set step to 1 when no records found. UNTESTED
reportSettings % verify new rats are listed at step 1
% DONE 9/13/08 at 10am PR

% as of 9/17 step3 is still not working for unknown reasons - TRY a
% possible fix
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'284','285','286','287','288','289','290', '291'}; 
setProtocol_VisionBattery1(subjIDs); % should persist steps
reportSettings % verify most listed at step 3
%this does not work - debug later

%9/18 mysteriously ts5 works now try ts3 yes both work. restart all at ts2
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'284','285','286','287','288','289','290', '291'}; 
setProtocol_VisionBattery1(subjIDs); % modified to set step to 2 for all
 
 
%9/19 fixed bug in calcstim for coherent dots - reinstantiate the
%protocols
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'284','285','286','287','288','289','290', '291'}; 
setProtocol_VisionBattery1(subjIDs); % should persist steps
 
%9/22/08 demote several rats to earned free drinks (not doing any trials;
%poor coaching by weekend swappers)
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'284','288','289','290', '291'}; 
setProtocol_VisionBattery1(subjIDs);% modify to set step=2 for the called subjects
% DONE 1:45pm 9/22/08 PR

%10/24/09 reassign rat 286 to step5 (has totally failed random dots but may
%learn go to side?) NOTE same day move from cockpit to box!
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'286'}; 
setProtocol_VisionBattery1(subjIDs);

% 10/30 stop training, free water, inject IBO in LGN, allow time for cell death...
% start restricting and no-visual free drinks by hand (Yuli) 11/10

% 11/12/08 after lesions:
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','286','287','290'}; 
VisionBatteryTEST(subjIDs); % set to start all at step 1

% 11/20/08 HAND GRADUATION of 290 only
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'290'}; %'285','286','287',
VisionBatteryTEST(subjIDs); % graduate 290 to step 3
%% strangely, this didn't work! rat ran on step 2 again the next day. 
% try again, and introduce automatic logging of step changes
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'290'}; %'285','286','287',
VisionBatteryTEST(subjIDs); % graduate 290 to step 3

% 12/4/08 define NEW protocol and reassign remaining rats to new steps
% caution, p2 protocol has 6 steps and tasks are in different order.
% 285 and 287 to step3 which is now gotoside; gotohor will be next
% 290 is getting SC lesion, set to step1 to repeat free drinks followed by
% step2 motion task with high coherence as re-test post 2nd lesion.
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','287','290'}; 
VisionBatteryTEST(subjIDs); % run 12/4 at 7:21pm

% 12/6 290 is ok postlesion but too long on free drinks
%hand graduate to motion steo
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'290'}; 
VisionBatteryTEST(subjIDs); % run 12/6 at 9:30am

% 12/9 and 12/10 off ratrix hand train upstairs on image recognition
% see separate data files!!

% 12/11 resume ratrix to get spatial frequency and contrast tuning curves
% on go to side?
% rat 285 was on step 3 go to side on p2 protocol (never did go to horiz)
% rat 287 was on step 4 go to horizontal on p2 protocol
% hand grad both to step 7 go to side parametric
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','287'}; 
VisionBatteryTEST(subjIDs); %  ran 12/11 at 9:30am, restart heat new session

% parameters WAY too hard. ease up and redo
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','287'}; 
VisionBatteryTEST(subjIDs); %  ran 12/11 at 9:45am, restart heat new session

% NO gratings visible!!! demote to step 3 and debug offline!!

clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','287'}; 
VisionBatteryTEST(subjIDs); %  ran 12/11 at 9:58am, restart heat new session


% 12/12/08 apparently no trials done for two days. !!!
% rebuilt the protocol to correct error in stim manager,
% demote to gotoside, varying contrast (Step 7 now)
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','287'}; 
VisionBatteryTEST(subjIDs); % ran apparently successfully 11pm 12/12/08


% ack. bad protocol still. one last version one training step 
clear
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')  
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {'285','287'}; 
VisionBatteryTEST(subjIDs); %  ran during red heat 12/13

