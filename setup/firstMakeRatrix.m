function r = firstMakeRatrix()

[pathstr, name, ext, versn] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

rackID=getRackIDFromIP;

permanentStore=getSubDirForRack(rackID);
r=createRatrixWithStationsForRack(rackID,'localTimed');
r=setPermanentStorePath(r,permanentStore);
r=addRatsForRack(rackID,'edf');