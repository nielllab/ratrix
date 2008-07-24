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


%edf/pv demoting two subjects to stochastic free drinks 08.16.08%
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'279'; '282'};
r = setProtocolPriya(r,subjIDs); %  run at 9am on wed jul 16

