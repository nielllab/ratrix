function    [value]  = getCurrentShapedValue(t)

if ~isempty(t.shapingValues)
    if ~isempty(t.shapingValues.currentValue)
        value = t.shapingValues.currentValue ;
    else
        value = 'empty'; % this enforces some value to get returned, resulting in overwriting the empty value during initialization by something in the miniDatabase
    end

else
    value = [];
end

