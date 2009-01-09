function setupMaleRoom()

%%
rackID=1;
r=createRatrixWithStationsForRack(rackID);
r=addRatsForRack(rackID,'pmm');
setPermanentStorePath(r,getSubDirForRack(rackID));

%%
setProtocolPR({'243','244','245','246','247','248'});
setProtocolDFP('male room',{'225','226','239','241'}) %removed '223','224' before dan left, failed 240 $ 242 after dan left july 21




%%
%before running setupPMM, is the miniDataBase up to date? To check this:
%makeMiniDatabase(1)

% if the male room ever needs to be redefined, the appropriate functions is setupMaleRoom. 
% before running this function, the values must be correct in makeMiniDatabase. To check their current state, 
% run:
%       edit makeMiniDatabase
%       makeMiniDatabase(true); 
% 
% and see if any lines are printed out and look like this:
% 
%       'changing (rat ID)'s step from listed (stepNum) to ratrix defined (stepNum)'
%       'changing (rat ID)'s shapingValue from listed (value) to ratrix defined (value)'
%       'need to add 'database.subject{i}.currentShapedValue = (value)' for (ratID)'
% 
% if you want to mannually check things:
% 
%     dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
%     r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
%     getBasicfacts(r)
%     
% this will indicate the step or shaping value that should be listed in makeMiniDatabase before redefining 
% (note: this function relies on the current db.mat containing the relevent information, so get these values 
% before redefining the whole thing).  After saving the changes, those
% lines won't appear anymore. Sorry for the hassle.

% your task in changing the miniDatabase is done when you get, from the
% output of makeMiniDatabase(true) 
%
%   shapingValuesChanged = 0
%   numStepsChanged = 0

% -phil 081907

setupPMM %no longer persisting Adam's rats
%%


% testSubjects={'l','r'};
% setProtocolPR(testSubjects);

