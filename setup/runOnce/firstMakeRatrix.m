function r = firstMakeRatrix(rewardMethod)
% now uses server architecture instead of rack-based

if ~exist('rewardMethod','var') || isempty(rewardMethod)
    rewardMethod='localTimed';
end

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

server_name=getServerNameFromIP;

% permanentStore=getSubDirForRack(rackID); % no more rack-specific permanent store path
r=createRatrixWithStationsForServer(server_name,rewardMethod);
% r=setPermanentStorePath(r,permanentStore);
r=addRatsForServer(server_name,'edf');