function xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, normBoundsRect, stimID, protocolStr, ...
    textLabel, trialLabel, i, frameNum, manual, didAPause, ptbVersion, ratrixVersion, numDrops, numApparentDrops, phaseInd, phaseType)

%DrawFormattedText() won't be any faster cuz it loops over calls to Screen('DrawText'), tho it would clean this code up a bit.

xTextPos=xOrigTextPos;
if labelFrames
    [xTextPos] = Screen('DrawText',window,['ID:' subID ],xOrigTextPos,yTextPos,100*ones(1,3));
    xTextPos=xTextPos+50;
    [garbage,yTextPos] = Screen('DrawText',window,['trlMgr:' class(tm) ' stmMgr:' stimID  ' prtcl:' protocolStr ],xTextPos,yTextPos,100*ones(1,3));
end
yTextPos=yTextPos+1.5*normBoundsRect(4);

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
    [garbage,yTextPos] = Screen('DrawText',window,sprintf('priority:%g %s stimInd:%d frame:%d drops:%d(%d) stim:%s, phaseInd:%d strategy:%s',Priority(),trialLabel,i,frameNum,numDrops,numApparentDrops,txtLabel,phaseInd,phaseTypeDisplay),xTextPos,yTextPos,100*ones(1,3));
    yTextPos=yTextPos+1.5*normBoundsRect(4);
    
    [garbage,yTextPos] = Screen('DrawText',window,sprintf('ptb:%s',ptbVersion),xTextPos,yTextPos,100*ones(1,3));
    yTextPos=yTextPos+1.5*normBoundsRect(4);
    
    [garbage,yTextPos] = Screen('DrawText',window,sprintf('ratrix:%s',ratrixVersion),xTextPos,yTextPos,100*ones(1,3));
    yTextPos=yTextPos+1.5*normBoundsRect(4);
end

if manual
    manTxt='on';
else
    manTxt='off';
end
if manual
    [garbage,yTextPos] = Screen('DrawText',window,sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt),xTextPos,yTextPos,100*ones(1,3));
    yTextPos=yTextPos+1.5*normBoundsRect(4);
end

if didAPause
    %[garbage,yTextPos] = ...
    Screen('DrawText',window,'trial record will indicate a pause occurred on this trial',xTextPos,yTextPos,100*ones(1,3));
    %yTextPos=yTextPos+1.5*normBoundsRect(4);
end


end % end function