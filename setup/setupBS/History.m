cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment;
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subjIDs={'267'; '268'; '269'; '270'};
r = setProtocolBS(r,subjIDs); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adding new rats to setupBS: 
% 159,161,180,186 => these were previously on the same rack under eflister 
% 181,182,187,188 => rats to be added from rack 3.

cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment;
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subIDs={'267';'268';'269';'270';'181';'182';'187';'188'};
    r = setProtocolBS(r,subIDs); 


%still to be added: '159';'161';'180';'186';

% doe to make reward durarion 30 muL
cd('C:\Documents and Settings\rlab\Desktop\Ratrix\bootstrap')
setupEnvironment;
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file
subIDs={'267';'268';'269';'270';'181';'182';'187';'188'};
    r = setProtocolBS(r,subIDs); 