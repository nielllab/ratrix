function xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, normBoundsRect, stimID, protocolStr, ...
    textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion, numDrops, numApparentDrops, phaseInd, phaseType,textType)

%DrawFormattedText() won't be any faster cuz it loops over calls to Screen('DrawText'), tho it would clean this code up a bit.

xTextPos=xOrigTextPos;
brightness=100;
switch textType
    case 'full'
        if labelFrames
            [xTextPos] = Screen('DrawText',window,['ID:' subID ],xOrigTextPos,yTextPos,brightness*ones(1,3));
            xTextPos=xTextPos+50;
            [garbage,yTextPos] = Screen('DrawText',window,['trlMgr:' class(tm) ' stmMgr:' stimID  ' prtcl:' protocolStr ],xTextPos,yTextPos,brightness*ones(1,3));
        end
        yTextPos=yTextPos+1.5*normBoundsRect(4);
        
        if labelFrames
            if iscell(textLabel)  % this is a reoccuring cost per frame... could be before the loop... pmm
                txtLabel=textLabel{i};
            else
                txtLabel=textLabel;
            end
            if iscell(phaseType)
                phaseTypeDisplay=phaseType{1};
            else
                phaseTypeDisplay=phaseType;
            end
            [garbage,yTextPos] = Screen('DrawText',window,sprintf('prty:%g %s stmInd:%d frm:%d drps:%d(%d), phsInd:%d strtgy:%s',Priority(),trialLabel,i,frameNum,numDrops,numApparentDrops,phaseInd,phaseTypeDisplay),xTextPos,yTextPos,brightness*ones(1,3));
            yTextPos=yTextPos+1.5*normBoundsRect(4);
            
            [garbage,yTextPos] = Screen('DrawText',window,sprintf('stim:%s',txtLabel),xTextPos,yTextPos,brightness*ones(1,3));
            yTextPos=yTextPos+1.5*normBoundsRect(4);            
            
            [garbage,yTextPos] = Screen('DrawText',window,sprintf('ptb:%s',ptbVersion),xTextPos,yTextPos,brightness*ones(1,3));
            yTextPos=yTextPos+1.5*normBoundsRect(4);
            
            [garbage,yTextPos] = Screen('DrawText',window,sprintf('ratrix:%s',ratrixVersion),xTextPos,yTextPos,brightness*ones(1,3));
            yTextPos=yTextPos+1.5*normBoundsRect(4);
        end
    case 'light'
        [garbage,yTextPos] = Screen('DrawText',window,sprintf('%s stimInd:%d frame:%d drops:%d(%d)',trialLabel,i,frameNum,numDrops,numApparentDrops),xTextPos,yTextPos,brightness*ones(1,3));
        yTextPos=yTextPos+1.5*normBoundsRect(4);
    otherwise
        error('unsupported')
end

if manual
    manTxt='on';
else
    manTxt='off';
end
if didManual
    [garbage,yTextPos] = Screen('DrawText',window,sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt),xTextPos,yTextPos,brightness*ones(1,3));
    yTextPos=yTextPos+1.5*normBoundsRect(4);
end

if didAPause
    %[garbage,yTextPos] = ...
    Screen('DrawText',window,'trial record will indicate a pause occurred on this trial',xTextPos,yTextPos,brightness*ones(1,3));
    %yTextPos=yTextPos+1.5*normBoundsRect(4);
end


end % end function