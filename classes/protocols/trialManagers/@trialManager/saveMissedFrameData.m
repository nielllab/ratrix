function [responseDetails lastFrameTime] = saveMissedFrameData(tm, responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi)

% This function saves data about missed frames into responseDetails.
% Part of stimOGL rewrite.
% INPUT: responseDetails, missed, frameNum, ft, timingCheckPct, lastFrameTime, ifi
% OUTPUT: responseDetails, lastFrameTime


%save facts about missed frames
if missed>0 && frameNum<responseDetails.numFramesUntilStopSavingMisses
    disp(sprintf('warning: missed frame num %d',frameNum));
    responseDetails.numMisses=responseDetails.numMisses+1;
    responseDetails.misses(responseDetails.numMisses)=frameNum;
    responseDetails.afterMissTimes(responseDetails.numMisses)=GetSecs();
else
    thisIFI=ft-lastFrameTime;
    thisIFIErrorPct = abs(1-thisIFI/ifi);
    if  thisIFIErrorPct > timingCheckPct
        disp(sprintf('warning: flip missed a timing and appeared not to notice: frame num %d, ifi error: %g',frameNum,thisIFIErrorPct));
        responseDetails.numApparentMisses=responseDetails.numApparentMisses+1;
        responseDetails.apparentMisses(responseDetails.numApparentMisses)=frameNum;
        responseDetails.afterApparentMissTimes(responseDetails.numApparentMisses)=GetSecs();
        responseDetails.apparentMissIFIs(responseDetails.numApparentMisses)=thisIFI;
    end
end
lastFrameTime=ft;

%stop saving miss frame statistics after the relevant period -
%prevent trial history from getting too big
%1 day is about 1-2 million misses is about 25 MB
%consider integers if you want to save more
%reasonableMaxSize=ones(1,intmax('uint16'),'uint16');%

if missed>0 && frameNum>=responseDetails.numFramesUntilStopSavingMisses
    responseDetails.numMisses=responseDetails.numMisses+1;
    responseDetails.numUnsavedMisses=responseDetails.numUnsavedMisses+1;
end

end % end function