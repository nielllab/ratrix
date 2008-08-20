%% Priya History Script %%
% record of commands run on ratrix for rats 279-282
% object recognition task as pilot for perirhinal lesions

% 080707 assignments made in DB
% 279 = rack 3 D, red
% 280 = rack 3 G, red
% 281 = rack 3 H, red
% 282 = rack 3 I, red

% 080707 first time creating ratrix on rack 3
% ran setupEnvironment and firstMakeRatrix - EF

% 080707 call setupPriya for first time
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'; '281'; '282'};
r = setProtocolPriya(r,subjIDs); % NB run as NOT a test

% note: use checkSettings to verify / not working at the moment
%080707 test the stimulus
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'rack3test2','rack3test3','rack3test4','rack3test5','rack3test6','rack3test7','rack3test8','rack3test9'};
r = setProtocolPriya(r,subjIDs, 1); % test mode, quick graduation


% concern: stations hiss because water in ports, rats unhappy
% 080707 call setupPriya again after making stoch free drinks silent
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'; '281'; '282'};
r = setProtocolPriya(r,subjIDs); %  run at 4:40pm

% 080710 reload new version of setprotocolpriya with many changes
% due to change in how images finds files - now a list is provided as an
% argument
% NOTE only training steps ts3 and ts4 are in the protocol
% because ts1 and ts2 are past, and ts 5 and 6 are not working right
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'; '281'; '282'};
r = setProtocolPriya(r,subjIDs); %  run at 11:30am on thurs jul 10


%demoting two subjects to free drinks %
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'};
r = setProtocolPriya(r,subjIDs); %  run at 12:10pm on fri jul 11


%update protocols to include the paintbrush/flashlight tasks
% note two groups, different targets
% note each rat beginning at a different training step
% but now all trainingsteps remain defined, so step index = ts#
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'; '281'; '282'};
r = setProtocolPriya(r,subjIDs); %  run 7/22/08  at 10pm PR



%07.24.08
%edf added msPuff=0 to your reinforcement managers and 
%svnRevision={'svn://132.239.158.177/projects/ratrix/tags/v0.6'}
%to your trainingSteps in setProtocolPriya in order to get you on board
%with the merge.  ran the following:
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'; '281'; '282'};
r = setProtocolPriya(r,subjIDs); 


%update protocols to change performanc criteria and demote rats
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '280'; '281'; '282'};
r = setProtocolPriya(r,subjIDs); %  run 7/29/08  PR

%demote rat 282 to step 4 and disable automatic graduation from step 4
% due to suspicious premature graduation
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'282'};
r = setProtocolPriya(r,subjIDs); %  run 8/8/08  PR

%add rat 283 to protocol
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'283'};
r = setProtocolPriya(r,subjIDs); %  run 8/8/08  PV

%increase time out to 8000ms and decrease reward size to 40ms for rat 282
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'282'};
r = setProtocolPriya(r,subjIDs); %  run 8/15/08  PV

%increase time out to 16000ms, standard reward size rat 282
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'282'};
r = setProtocolPriya(r,subjIDs); %  run 8/15/08  PV