function good=goodPins(p)
good=1;
goods={};
if iscell(p)
    for i=1:length(p)
        x=p{i};
        if ischar(x{1}) && hex2dec(x{1})>0
            if isBitSpec(getBitSpecForPinNum(x{2}))
                if notMember(goods,x)
                    goods{end+1}=x;
                else
                    error('contains dupes')
                end
            else
                error('bad pin num (must be 1-17)')
            end
        else
            x{1}
            ischar(x{1})
            class(x{1})
            hex2dec(x{1})>0
            error('pport addrs must be positive hex strings')
        end
    end
else
    error('need cell input')
end