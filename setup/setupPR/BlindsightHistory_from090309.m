%090309
% history of setProtocol commands run for all blindsight rats for Pam's new
% server in the Male room.

ValidRats={'307','309','297','298','299','302'};  

% FIRST RATS assigned to Pam's new server
% run March 10, 2009, 7:33am
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap') % refers to rack1Temp tag
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep); 
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs=ValidRats;
%add these rats to the ratrix
r=addNewSubject(r,subjIDs); 
%run setprotocol for these rats
r=setProtocolAdvancedVisionBattery(r, subjIDs); % assign these rats to step 1 of image task

% notes to self regarding later training steps:
% 299 completed all of the earlier protocol; needs object, psychophysics of
% motion and orientation tasks
% 297 still needs to do "hard motion" step 8 of previous protocol
% 298 still needs more time on "hard motion" step 8 of previous protocol
% 302 still needs more time on "hard motion" step 8 of previous protocol
% 307 needs to start motion on easiest level (step 6 of prvious protocol)
% 309 needs to start motion on easiest level (step 6 of prvious protocol)


