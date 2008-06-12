function [r priming]=startPrime(r,stationID,portID)
if isempty(r.primeClient)
    potentialPrimeClient=getClientForStationID(r,stationID);
    if clientIsRegistered(r,potentialPrimeClient)
        r.primeClient={potentialPrimeClient, portID};
        fprintf('priming: station %d port %d\n',stationID,portID);
        priming=true;
    else
        fprintf('current priming target (station %d port %d) is not yet registered.  ignoring priming request.\n',stationID,portID);
        priming=false;
    end
else
    error('already priming someone -- must stop before you prime someone else')
end