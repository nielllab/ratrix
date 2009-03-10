function r = firstMakeRatrix(rewardMethod,serverName)
% now uses server architecture instead of rack-based

if ~exist('rewardMethod','var') || isempty(rewardMethod)
    rewardMethod='localTimed';
end

if ~exist('serverName','var') || isempty(serverName)
    serverName=getServerNameFromIP;
end

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

% permanentStore=getSubDirForRack(rackID); % no more rack-specific permanent store path
r=createRatrixWithStationsForServer(serverName,rewardMethod);
% r=setPermanentStorePath(r,permanentStore);
r=addRatsForServer(serverName,'edf');