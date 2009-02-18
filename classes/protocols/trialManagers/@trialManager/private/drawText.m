function xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, normBoundsRect, stimID, protocolStr, ...
    textLabel, trialLabel, i, frameNum, manual, didAPause, ptbVersion, ratrixVersion, numDrops, numApparentDrops, phaseInd, phaseType)

% This function draws display text for each stim frame.
% Part of stimOGL rewrite.
% INPUT: window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, normBoundsRect, stimID, protocolStr,
%   textLabel, trialLabel, i, frameNum, manual, didAPause, ptbVersion, ratrixVersion, numDrops, numApparentDrops, phaseInd, phaseType
% OUTPUT: xTextPos

xTextPos=xOrigTextPos;
if labelFrames
    %junkSize = Screen('TextSize',window,subjectFontSize);
    [xTextPos] = Screen('DrawText',window,['ID:' subID ],xOrigTextPos,yTextPos,100*ones(1,3));
    xTextPos=xTextPos+50;
    %junkSize = Screen('TextSize',window,standardFontSize);
    [garbage,yNewTextPos] = Screen('DrawText',window,['trlMgr:' class(tm) ' stmMgr:' stimID  ' prtcl:' protocolStr ],xTextPos,yNewTextPos,100*ones(1,3));
end
yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);

if labelFrames
    if iscell(textLabel)
        txtLabel=textLabel{i};
    else
        txtLabel=textLabel;
    end
    if iscell(phaseType)
        phaseTypeDisplay=phaseType{1};
    else
        phaseTypeDisplay=phaseType;
    end
    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('priority:%g %s stimInd:%d frame:%d drops:%d(%d) stim:%s, phaseInd:%d strategy:%s',Priority(),trialLabel,i,frameNum,numDrops,numApparentDrops,txtLabel,phaseInd,phaseTypeDisplay),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
    
    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('ptb:%s',ptbVersion),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
    
    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('ratrix:%s',ratrixVersion),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
end

if manual
    manTxt='on';
else
    manTxt='off';
end
if manual
    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
end

if didAPause
    [garbage,yNewTextPos] = Screen('DrawText',window,'trial record will indicate a pause occurred on this trial',xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
end


end % end function