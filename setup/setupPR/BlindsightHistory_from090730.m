%new log for new tag 1.0.2
% history of setProtocol commands run for all blindsight rats startig
% 7/30/09 (look on 0.8, 1.0 and 1.01 for logs saved under other tags!)

ValidRats={'307','309','297','298','299','302'};  
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') %   
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep); 
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs= {}; % for all use subjIDs=ValidRats;
r=setProtocolAdvancedVisionBattery090730(r, subjIDs);  
% sets all rats to step 1 of a revised, image rec protocol


