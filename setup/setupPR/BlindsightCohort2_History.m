%081121 New cohort of rats to be pre-trained for lesions

% FIRST assign the rats to heats in the Oracle database 
% DONE 11/21 9:30PM
% rat	assigned to
% 297   red 1e
% 298	ORANGE 1C
% 299	BLUE 1D
% 300	BLUE 1F
% 301	VIOLET 1C
% 302	VIOLET 1D


%% NOW add rats to rack
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep); 
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'297','298','299','300','301','302'};
addNewSubject(r,subjIDs); %done and successful 11/20/08 10pm

%finally set protocol
setProtocol_BlindsightCoh2(subjIDs); % started/interrupted; ran again 10:15pm

% 11/27 demote 300 and 301 to earned free drinks. not doing trials.
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep); 
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'300','301'};
setProtocol_BlindsightCoh2(subjIDs); %ran 11/27 9:50am..

% 12/4 transfered all the cockpit rats to boxes 
% they succeeded at dots and need to do gotoside/horiz
% thus change to protocolB and demote to step 2
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep); 
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'298','299','301','302'};  
setProtocol_BlindsightCoh2(subjIDs); % run 7:17pm 
