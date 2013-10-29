function [responseDetails timestamps] = ...
    saveMissedFrameData(tm, responseDetails, frameNum, timingCheckPct, ifi, timestamps)

debug=false;
type='';
thisIFI=timestamps.vbl-timestamps.lastFrameTime;

if timestamps.missed>0
    type='caught';
    responseDetails.numMisses=responseDetails.numMisses+1;
    
    if  responseDetails.numMisses<responseDetails.numDetailedDrops
        
        responseDetails.misses(responseDetails.numMisses)=frameNum;
        responseDetails.afterMissTimes(responseDetails.numMisses)=GetSecs();
        responseDetails.missIFIs(responseDetails.numMisses)=thisIFI;
        if tm.saveDetailedFramedrops
            responseDetails.missTimestamps(responseDetails.numMisses)=timestamps; %need to figure out: Error: Subscripted assignment between dissimilar structures
        end
    else
        responseDetails.numUnsavedMisses=responseDetails.numUnsavedMisses+1;
    end
    
else
    thisIFIErrorPct = abs(1-thisIFI/ifi);
    if  thisIFIErrorPct > timingCheckPct
        type='unnoticed';
        
        responseDetails.numApparentMisses=responseDetails.numApparentMisses+1;
        
        if responseDetails.numApparentMisses<responseDetails.numDetailedDrops
            responseDetails.apparentMisses(responseDetails.numApparentMisses)=frameNum;
            responseDetails.afterApparentMissTimes(responseDetails.numApparentMisses)=GetSecs();
            responseDetails.apparentMissIFIs(responseDetails.numApparentMisses)=thisIFI;
            if tm.saveDetailedFramedrops
                responseDetails.apparentMissTimestamps(responseDetails.numApparentMisses)=timestamps; %need to figure out: Error: Subscripted assignment between dissimilar structures
            end
        else
            responseDetails.numUnsavedApparentMisses=responseDetails.numUnsavedApparentMisses+1;
        end
        
    end
end

if ~strcmp(type,'') && debug
    printDroppedFrameReport(1,timestamps,frameNum,thisIFI,ifi,type); %fid=1 is stdout (screen)
end

timestamps.lastFrameTime=timestamps.vbl;
timestamps.prevPostFlipPulse=timestamps.postFlipPulse;

end % end function