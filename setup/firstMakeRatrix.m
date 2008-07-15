function r = firstMakeRatrix()

rackID=getRackIDFromIP;

permanentStore=getSubDirForRack(rackID);
r=createRatrixWithStationsForRack(rackID);
r=setPermanentStorePath(r,permanentStore);
r=addRatsForRack(rackID,'edf');