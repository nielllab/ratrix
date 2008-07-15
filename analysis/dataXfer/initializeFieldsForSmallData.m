function smallData=initializeFieldsForSmallData(smallData,varNames,structNames,trialRecords,preAllocationLength,varClass)
numFields=size(varNames,1);

for i=1:numFields
    %Check to See the Field Exists
    command=sprintf('tempVariable=trialRecords(1)%s;',char(structNames(i)));
    try
        eval(command)
        makeNans=0;
    catch
        %if the field doesn't exist we will store a nan
        makeNans=1;
        warning (sprintf('trialManager does not contain %s', char(structNames(i))));
    end

    if makeNans
        command=sprintf('smallData.%s=nan(1,preAllocationLength);',char(varNames(i)));
    else
        if iscell(tempVariable)
            command=sprintf('smallData.%s={};',char(varNames(i)));
        else
            command=sprintf('smallData.%s=[];',char(varNames(i)));
            if exist('preAllocationLength','var')
                if exist('varClass','var')
                    command=sprintf('smallData.%s=zeros(1,preAllocationLength,''%s'');',char(varNames(i)),char(varClass(i)));
                else
                    command=sprintf('smallData.%s=zeros(1,preAllocationLength);',char(varNames(i)));
                end
            end
        end
    end



    try
        eval(command);
    catch
        disp(command)
        error ('bad command');
    end
end