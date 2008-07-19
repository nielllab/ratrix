function smallData=setSmallDataFromListOfVariableNames(smallData,trialRecords,savedVariableNames)
%SAVE LIST OF VARIABLES
%cells must be filled per trial AND 2 deep structures must be filled per trial

numFields=size(savedVariableNames,1);
numTrials=size(trialRecords,2);
for f=1:numFields
    for i=1:numTrials
        trial=i; %this used to be different when collecting many sessions at once, see getRatrixDataFromStation

        %Check to See the Field Exists
        command=sprintf('tempVariable=trialRecords(i)%s;',char(savedVariableNames(f,2)));
        try
            eval(command)
            makeNans=0;
        catch
            %if the field doesn't exist we will store a nan
            makeNans=1;
            if trial==1
                warning (sprintf('trialManager does not contain %s', char(savedVariableNames(f,2))));
            end
        end

        if makeNans
            command=sprintf('smallData.%s(%d)=nan;',char(savedVariableNames(f,1)),trial);
        else
            if iscell(tempVariable)
                command=sprintf('smallData.%s{%d}=trialRecords(%d)%s;',char(savedVariableNames(f,1)),trial,i,char(savedVariableNames(f,2)));
            else
                command=sprintf('smallData.%s(%d)=trialRecords(%d)%s;',char(savedVariableNames(f,1)),trial,i,char(savedVariableNames(f,2)));
            end
        end

        try
            eval(command)
        catch
            disp(command);
            rethrow(lasterror);
            %             psychrethrow(psychlasterror);


            disp(sprintf('size of trial records is: %d trials',size(trialRecords,2)))
            disp(sprintf('size of small data field for this variable is: %d trials',size(eval(sprintf('smallData.%s',char(savedVariableNames(f,1)))),2)))
            disp(sprintf('smallData.%s(%d)',char(savedVariableNames(f,1)),trial))
            eval(sprintf('smallData.%s(%d)',char(savedVariableNames(f,1)),trial))
            disp(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))))
            eval(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))))

            %             eval(sprintf('trialRecords(%d)%s',i-1,char(savedVariableNames(f,2))))
            %             eval(sprintf('trialRecords(%d)%s',i-0,char(savedVariableNames(f,2))))
            %             eval(sprintf('trialRecords(%d)%s',i+1,char(savedVariableNames(f,2))))
            %             eval(sprintf('trialRecords(%d)%s',i+2,char(savedVariableNames(f,2))))


            disp(sprintf('%s had value of: %d',sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))),eval(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))))))
            eval(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2))))
            if isempty(eval(sprintf('trialRecords(%d)%s',i,char(savedVariableNames(f,2)))))
                warning('can''t use the general converter if has empty values...move it to the specific converter and add a check.')
                %the reason is empty set is the wrong size!  (zero) rather than (one)
            end

            error ('bad command')
        end
    end
end