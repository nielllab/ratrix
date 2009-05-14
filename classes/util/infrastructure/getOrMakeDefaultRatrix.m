function rx = getOrMakeDefaultRatrix(makeNew)
% gets the default ratrix OR if doesn't exist, makes a default
% flag 'makeNew' forces creation of new ratrix object

if ~exist('makeNew','var') || isempty(makeNew)
    makeNew=false;
end

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
defaultLoc=fullfile(dataPath, 'ServerData');
d=dir(fullfile(defaultLoc, 'db.mat'));

if length(d)==1 && ~makeNew
    rx=ratrix(defaultLoc,0);
    fprintf('loaded ratrix from default location\n')
else
    try
        [success mac]=getMACaddress();
        if ~success
            mac='000000000000';
        end
    catch
        mac='000000000000';
    end

    machines={{'1U',mac,[1 1 1]}};
    rx=createRatrixWithDefaultStations(machines,dataPath,'localTimed');
    permStorePath=fullfile(dataPath,'PermanentTrialRecordStore');
    mkdir(permStorePath);
    rx=setStandAlonePath(rx,permStorePath);
    fprintf('created new ratrix\n')
end