function dur=ensureRezFilled(z)
start=GetSecs();
full=0;
beeped=0;
while ~full
    if sensorBlocked(z)
        if ~beeped
            beep
            beeped=1;
            fprintf('refilling\n')
        end
        setValve(z,z.fillRezValveBit,z.const.valveOn);
    else
        setValve(z,z.fillRezValveBit,z.const.valveOff);
        full=1;
        if beeped
            beep
        end
    end
end
dur=GetSecs()-start;