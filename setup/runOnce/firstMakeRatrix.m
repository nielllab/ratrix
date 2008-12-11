function r = firstMakeRatrix(rewardMethod)

if ~exist('rewardMethod','var') || isempty(rewardMethod)
    rewardMethod='localTimed';
end

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

rackID=getRackIDFromIP;

permanentStore=getSubDirForRack(rackID);
r=createRatrixWithStationsForRack(rackID,rewardMethod);
r=setPermanentStorePath(r,permanentStore);
r=addRatsForRack(rackID,'edf');