function s=doOpportunisticRefillPumps(s,vol,keys)

if isscalar(vol) && isreal(vol) && vol>0
else
    error('vol must be a strictly positive real number')
end

try
    lastZone=0;
    closeAllValves(s);
    [s.pump durs]=openPump(s.pump);

    [durs t s.pump]=resetPumpPosition(s.zones{1},s.pump);
    %[s lastZone] = doPrime(s);
    
    pause
    
    ListenChar(2)
    FlushEvents('keyDown')
    done=0;
    needsAntiRock=1;
    fprintf('hit the key for a zone (%s) to deliver a %g ml reward, ''q'' to quit\n',num2str([1:length(s.zones)]),vol)
    while ~done
        for i=1:length(s.zones)
            setOnlineRefill(s.zones{i});
        end
        % Check for commands from the command queue here
        % FILL IN
        if ~isempty(keys) || CharAvail()
            if ~isempty(keys)
                k=keys(1);
                keys=keys(2:end);
            else
                k=GetChar(0);
            end
            
            switch k
                case 'q'
                    done=1;
                case 'p'
                    [s lastZone] = doPrime(s);
                    needsAntiRock = 1;
                otherwise
                    k=str2num(k);
                    if ~isempty(k) && k>0 && k<=length(s.zones)
                        fprintf('doing zone %d\n',k)
                        if needsAntiRock
                            s.pump=doAntiRock(s.zones{k},s.pump);
                            lastZone=k;
                            needsAntiRock=0;
                        end
                        [durs s.pump] =doInfuse(s.zones{k},s.pump,vol,lastZone~=k);
                        lastZone=k;
                    end
            end
        else
            if lastZone==0
                lastZone=ceil(rand*length(s.zones));
                [s.pump durs]=equalizePressure(s.zones{lastZone},s.pump);
            elseif ismember(lastZone,1:length(s.zones))
                %OK
            else
                error('lastZone is bad val: %g',lastZone)
            end
            [s.pump didOpportunisiticRefill]=considerOpportunisticRefill(s.zones{lastZone},s.pump);
            if didOpportunisiticRefill
                needsAntiRock=1;
            elseif needsAntiRock
                s.pump=doAntiRock(s.zones{lastZone},s.pump);
                needsAntiRock = 0;
            end
        end
    end
    ListenChar(1)

    [durs t s.pump]=resetPumpPosition(s.zones{1},s.pump);
    s.pump=closePump(s.pump);
    durs=ensureAllRezFilled(s);
    closeAllValves(s);
catch
    %ListenChar(1) %this is needed to undo the ListenChar(2) above, but seems to replace useful errors with 'Undefined function or variable 'GetCharJava_1_4_2_09'.'
    closeAllValves(s);
    fprintf('closing pump due to error\n');
    s.pump=closePump(s.pump);
    rethrow(lasterror)
end