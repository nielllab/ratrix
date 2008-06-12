function out=isGoodNonpersistedSingleStationRatrix(r)
out=true;

%there is at least one subject
sids=getSubjectIDs(r);
out=out && ~isempty(sids);
if ~out
    getSubjectIDs(r)
    warning('no subjects')
end

%there is only one box
bids=getBoxIDs(r);
out=out && length(bids)==1;
if ~out
    length(bids)
    warning('more than one box')
end

%box is not empty and is not running
out=out && ~boxIDEmpty(r,bids(1)) && ~boxIDRunning(r,bids(1));
if ~out
    boxIDEmpty(r,bids(1))
    boxIDRunning(r,bids(1))
    warning('box empty or running')
end

%all subjects in same box
for i=1:length(sids)
    out = out && bids(1)==getBoxIDForSubjectID(r,sids{i});
end
if ~out
    getBoxIDForSubjectID(r,sids{i})
    warning('subjects not all in same box')
end

%there is only one station and it is not running
st=getStationsForBoxID(r,bids(1));
out = out && length(st)==1 && ~stationIDsRunning(r,getID(st));
if ~out
    length(st)
    stationIDsRunning(r,getID(st))
    warning('more than one station or station is running')
end

out