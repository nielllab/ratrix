function xTextPos = drawText(tm, window, labelFrames, subID, xOrigTextPos, yTextPos, normBoundsRect, stimID, protocolStr, ...
    textLabel, trialLabel, i, frameNum, manual, didManual, didAPause, ptbVersion, ratrixVersion, numDrops, numApparentDrops, phaseInd, phaseType,textType,ports)

%DrawFormattedText() won't be any faster cuz it loops over calls to Screen('DrawText'), tho it would clean this code up a bit.

xTextPos=xOrigTextPos;
brightness=100;
switch textType
    case 'full'
        if labelFrames
            [xTextPos] = Screen('DrawText',window,['ID:' subID ],xOrigTextPos,yTextPos,brightness*ones(1,3));
            xTextPos=xTextPos+50;
            doStr(['trlMgr:' class(tm) ' stmMgr:' stimID  ' prtcl:' protocolStr ]);
        end
        
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
            doStr(sprintf('prty:%g %s stmInd:%d frm:%d drps:%d(%d), phsInd:%d strtgy:%s',Priority(),trialLabel,i,frameNum,numDrops,numApparentDrops,phaseInd,phaseTypeDisplay));
            
            doStr(sprintf('stim:%s',txtLabel));
            
            doStr(sprintf('ptb:%s',ptbVersion));
            
            doStr(sprintf('ratrix:%s',ratrixVersion));
            
            doStr(sprintf('ports:%s',int2str(ports))); %slow?
        end
    case 'light'
        doStr(sprintf('%s stimInd:%d frame:%d drops:%d(%d)',trialLabel,i,frameNum,numDrops,numApparentDrops));
    otherwise
        error('unsupported')
end

    function doStr(str)
        [~,yTextPos] = Screen('DrawText',window,str,xTextPos,yTextPos,brightness*ones(1,3));
        yTextPos = yTextPos+1.5*normBoundsRect(4);
    end

if manual
    manTxt='on';
else
    manTxt='off';
end

if didManual
    doStr(sprintf('trial record will indicate manual poking on this trial (k+m to toggle for next trial: %s)',manTxt));
end

if didAPause
    doStr('trial record will indicate a pause occurred on this trial');
end

end