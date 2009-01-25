%
%returns: -1: unkown; 0 no, 1 yes
%
function wireStatus = isGroundWire( sessionID, channelNr )
wireStatus=-1;

groundWires = getGroundWires();
inds1 = find( groundWires(:,1)==sessionID );

if length(inds1>1) %this session does have a ground wire definition    
    inds2 = find( groundWires(inds1,2)==channelNr);
    if length(inds2)>0         
        wireStatus=1;
    else
        wireStatus=0;
    end
end
