function [responseDetails lastFrameTime numDrops numApparentDrops] = ...
    saveMissedFrameData(tm, responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi, numDrops,numApparentDrops,...
    when,whenTime,lastLoopEnd,time1,time2,time3,time4,time5,time6,time7,barebones,vbl)

% This function saves data about missed frames into responseDetails.
% Part of stimOGL rewrite.
% INPUT: responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi
% OUTPUT: responseDetails, lastFrameTime

%save facts about missed frames
if missed>0 && frameNum<responseDetails.numFramesUntilStopSavingMisses
    disp(sprintf('warning: missed frame num %d (when=%.15g at %.15g, lastLoopEnd=%.15g, when-last=%.15g [%.15g %.15g %.15g %.15g %.15g %.15g %.15g])',frameNum,when,whenTime,lastLoopEnd,when-lastFrameTime,time1-lastLoopEnd,time2-time1,time3-time2,time4-time3,time5-time4,time6-time5,time7-time6));
    numDrops=numDrops+1;
    if ~barebones
        responseDetails.numMisses=responseDetails.numMisses+1;
        responseDetails.misses(responseDetails.numMisses)=frameNum;
        responseDetails.afterMissTimes(responseDetails.numMisses)=GetSecs();
    end
    if frameNum>2
        %error('it')
    end
else
    thisIFI=vbl-lastFrameTime;
    thisIFIErrorPct = abs(1-thisIFI/ifi);
    if  thisIFIErrorPct > timingCheckPct
        %seems to happen when thisIFI/ifi is near a whole number
        disp(sprintf('warning: flip missed a timing and appeared not to notice: frame num %d, ifi error: %g, pct: %g%% (when=%.15g at %.15g, lastLoopEnd=%.15g)',frameNum,thisIFIErrorPct,100*thisIFI/ifi,when,whenTime,lastLoopEnd));
        numApparentDrops=numApparentDrops+1;
        if ~barebones
            responseDetails.numApparentMisses=responseDetails.numApparentMisses+1;
            responseDetails.apparentMisses(responseDetails.numApparentMisses)=frameNum;
            responseDetails.afterApparentMissTimes(responseDetails.numApparentMisses)=GetSecs();
            responseDetails.apparentMissIFIs(responseDetails.numApparentMisses)=thisIFI;
        end
        %error('it2')
    end
end
lastFrameTime=vbl;

if ~barebones
    %stop saving miss frame statistics after the relevant period -
    %prevent trial history from getting too big
    %1 day is about 1-2 million misses is about 25 MB
    %consider integers if you want to save more
    %reasonableMaxSize=ones(1,intmax('uint16'),'uint16');%

    if missed>0 && frameNum>=responseDetails.numFramesUntilStopSavingMisses
        responseDetails.numMisses=responseDetails.numMisses+1;
        responseDetails.numUnsavedMisses=responseDetails.numUnsavedMisses+1;
    end
end

end % end function