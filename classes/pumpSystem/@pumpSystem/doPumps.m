function s=doPumps(s,zones,vol)

if nargin==2
    if ~size(zones,1)==2
        error('2 arg call requires zones to have 2 rows.  row 1 holds the target zones, row 2 holds the target volumes')
    end
elseif nargin==3
    if isscalar(vol) && isreal(vol) && vol>0 && (size(zones,1)==1 || isempty(zones))
        zones=[zones;vol*ones(1,length(zones))];
    else
        error('vol must be a strictly positive real number, and zones must be a 1-dim vector or empty')
    end
else
    error('2 or 3 args required')
end

try
    lastZone=0;
    closeAllValves(s);
    [s.pump durs]=openPump(s.pump);

    if isempty(zones)
        ListenChar(2)
        FlushEvents('keyDown')
        done=0;
        while ~done
            fprintf('hit the key for a zone (%s) to deliver a %g ml reward, ''q'' to quit\n',num2str([1:length(s.zones)]),vol)
            k=GetChar(0);
            switch k
                case 'q'
                    done=1;
                otherwise
                    k=str2num(k);
                    if ~isempty(k) && k>0 && k<=length(s.zones)
                        fprintf('doing zone %d\n',k)
                        [durs s.pump] =doInfuse(s.zones{k},s.pump,vol,lastZone~=k);
                        lastZone=k;
                    end
            end
        end
        ListenChar(1)
    else
        for i=1:size(zones,2)
            fprintf('doing zone %d, pump %d\n',zones(1,i),i);
            [durs s.pump]=doInfuse(s.zones{zones(1,i)},s.pump,zones(2,i),lastZone~=zones(1,i));
            lastZone=zones(1,i);
        end
    end

    [durs t s.pump]=resetPumpPosition(s.zones{1},s.pump);
    s.pump=closePump(s.pump);
    durs=ensureAllRezFilled(s);
    closeAllValves(s);
catch ex
    %ListenChar(1) %this is needed to undo the ListenChar(2) above, but seems to replace useful errors with 'Undefined function or variable 'GetCharJava_1_4_2_09'.'
    closeAllValves(s);
    fprintf('closing pump due to error\n');
    s.pump=closePump(s.pump);
    rethrow(ex)
end