function [xTextPos didManual] = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, stimID, protocolStr, ...
  textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion)

% This function draws display text for each stim frame.
% Part of stimOGL rewrite.
% INPUT: tm, window, labelFrames, subID, xOrigTextPos, yTextPos, yNewTextPos, stimID, protocolStr,
%   textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion
% OUTPUT: xTextPos didManual

if labelFrames
    %junkSize = Screen('TextSize',window,subjectFontSize);
    [xTextPos,yTextPosUnused] = Screen('DrawText',window,['ID:' subID ],xOrigTextPos,yTextPos,100*ones(1,3));
    xTextPos=xTextPos+50;
    %junkSize = Screen('TextSize',window,standardFontSize);
    [garbage,yNewTextPos] = Screen('DrawText',window,['trlMgr:' class(tm) ' stmMgr:' stimID  ' prtcl:' protocolStr ],xTextPos,yNewTextPos,100*ones(1,3));
end
[normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);

if labelFrames
    if iscell(textLabel)
        txtLabel=textLabel{i};
    else
        txtLabel=textLabel;
    end
    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('priority:%g %s stimInd:%d frame:%d stim:%s',Priority(),trialLabel,i,frameNum,txtLabel),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);

    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('ptb:%s',ptbVersion),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);

    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('ratrix:%s',ratrixVersion),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
end

if manual
    didManual=1;
    manTxt='on';
else
    manTxt='off';
end
if didManual
    [garbage,yNewTextPos] = Screen('DrawText',window,sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt),xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
end

if didAPause
    [garbage,yNewTextPos] = Screen('DrawText',window,'trial record will indicate a pause occurred on this trial',xTextPos,yNewTextPos,100*ones(1,3));
    yNewTextPos=yNewTextPos+1.5*normBoundsRect(4);
end


end % end function