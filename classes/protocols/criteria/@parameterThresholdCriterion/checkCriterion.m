function [graduate, details] = checkCriterion(c,subject,trainingStep,trialRecords)

%determine what type trialRecord are
recordType='largeData'; %circularBuffer

graduate=0;
if ~isempty(trialRecords)
    %get the correct vector
    switch recordType
        case 'largeData'
            command=sprintf('parameterValue=trialRecords(end)%s',c.parameterLocation);
        case 'circularBuffer'
            error('not written yet');
        otherwise
            error('unknown trialRecords type')
    end

    %eval the comand that gets the parameter value
    try
        eval(command);
    catch ex
        disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
        disp(command);
        error('bad command in check criterion')
    end

    %check the parameter based on thresh and operator
    switch c.operator
        case '>'
            if parameterValue > c.threshold
                graduate=1;
            end
        case '>='
            if parameterValue >= c.threshold
                graduate=1;
            end
        case '<'
            if parameterValue < c.threshold
                graduate=1;
            end
        case '<='
            if parameterValue <= c.threshold
                graduate=1;
            end
        case '=='
            error('pmm doesn''t trust the equality, as one seems to find what you think is equal is not, don''t know why, not debugged')%080207
            if parameterValue == c.threshold
                graduate=1;
            end
        otherwise
            error('what the?')
    end
end


%play graduation tone

if graduate
    beep;
    waitsecs(.2);
    beep;
    waitsecs(.2);
    beep;
    waitsecs(1);
    [junk stepNum]=getProtocolAndStep(subject);
    for i=1:stepNum+1
        beep;
        waitsecs(.4);
    end
    if (nargout > 1)
        details.date = now;
        details.criteria = c;
        details.graduatedFrom = stepNum;
        details.allowedGraduationTo = stepNum + 1;
        details.parameterValue = parameterValue;
    end
end