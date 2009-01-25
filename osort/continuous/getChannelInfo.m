%
%find info about channel (gain, bandpass) for a given channel in a specific session.
%reads the headerInfos.mat file that needs to be created first (and extended for every session)
%
%urut/june06
function [exists, infos, isGround] = getChannelInfo( headerInfos, sessionID, channelNr )
exists=0;
infos=[];


ind = find( headerInfos(:,1) == sessionID & headerInfos(:,2) == channelNr );

%chanel found
if length(ind)>0
    exists = headerInfos(ind,3);
    
    if exists
       infos = headerInfos(ind,4:7);
    end
end

isGround = isGroundWire( sessionID, channelNr );
