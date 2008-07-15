function    [t]  = setCurrentShapedValue(t, value)

if isempty(t.shapingValues)
    error('no shaping value defined');
else

    if isnumeric( value )
        t.shapingValues.currentValue = value;
        pass=checkShapingValues(t, t.shapingMethod, t.shapingValues);
        if ~pass
            t.shapingValues = t.shapingValues
            t.shapingMethod = t.shapingMethod
            error('bad shaping values')
        end
        switch t.shapedParameter
            case 'targetContrast'
                %we don't know which field to change because we do not know
                %which protocol it is, so we call a function
                t=setTargetContrast(t, value);

            case 'stdGaussMask'
                t.stdGaussMask=value;
                decache(t);
                cache(t);            
            otherwise %use a general method to set the value

                command = sprintf('t.%s = value;', t.shapedParameter);
                try
                    eval(command)
                catch
                    fields(t)
                    disp(command);
                    error('bad command');
                end
        end
    else
        error('currentShapedValue must be a number')
    end
end

