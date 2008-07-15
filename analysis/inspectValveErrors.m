function out=inspectValveErrors(largeData,workstation,verbose)
%v=inspectValveErrors(largeData,'this_station',1)

problemTrialNum=0;
problemTrialNums=[];

noErrorCount=0;
totalTrialsSoFar=0;

combinedValveErrors=[];

for j=1:size(largeData,1)
    if ~isempty(largeData{j}) %ignore empty data structure
        if size(largeData{j}.trialRecords,2)>0;   %ignore empty trialrecords
            %problemTrial=[]
            problemTrialNumThisSession=0;
            problemTrialNumsThisSession=[];
            errorsExistHere=any(strcmp(fields(largeData{j}.trialRecords(1).responseDetails),'valveErrorDetails'));
            penaltyErrorsExistHere=any(strcmp(fields(largeData{j}.trialRecords(1)),'errorRecords'));
            if ~errorsExistHere
                disp('no error valve data in early trial records')
            end
            if penaltyErrorsExistHere
                disp('also checked valve errors in the penalty phase of this session')
            end

            for i=1:size(largeData{j}.trialRecords,2)
                %trialRecords(i).responseDetails.valveErrorDetails
                errorFound=0;

                if errorsExistHere
                    if ~isempty(largeData{j}.trialRecords(i).responseDetails.valveErrorDetails)
                        phase='discriminandum';
                        [combinedValveErrors problemTrialNum problemTrialNums problemTrialNumThisSession problemTrialNumsThisSession] =addToCombinedValveError(combinedValveErrors,largeData,workstation,phase,problemTrialNum,problemTrialNums,problemTrialNumThisSession,problemTrialNumsThisSession,i,j,verbose);
                        errorFound=1;
                    end
                end

                if penaltyErrorsExistHere
                    if ~isempty(largeData{j}.trialRecords(i).errorRecords)
                        if ~isempty(largeData{j}.trialRecords(i).errorRecords.responseDetails.valveErrorDetails)
                            phase='penalty';
                            [combinedValveErrors problemTrialNum problemTrialNums problemTrialNumThisSession problemTrialNumsThisSession] =addToCombinedValveError(combinedValveErrors,largeData,workstation,phase,problemTrialNum,problemTrialNums,problemTrialNumThisSession,problemTrialNumsThisSession,i,j,verbose);
                            errorFound=1;
                        end
                    end
                end

                if errorFound==0
                    noErrorCount=noErrorCount+1;
                end
            end

            for i=problemTrialNumThisSession
                if i>0
                    largeData{j}.trialRecords(i).responseDetails.valveErrorDetails
                end
            end

            totalTrialsSoFar=totalTrialsSoFar+size(largeData{j}.trialRecords,2);
        end
    end
end


if noErrorCount==totalTrialsSoFar
    disp(sprintf('searched all %d trials', noErrorCount))
    disp(sprintf('there are no valves errors in this largeData file'))

    out=[];
else
    disp(sprintf('there are %d valve errors in this largeData file',size(combinedValveErrors,2)))
    problemTrialNums
    out=combinedValveErrors;
end

end


function [combinedValveErrors problemTrialNum problemTrialNums problemTrialNumThisSession problemTrialNumsThisSession] =addToCombinedValveError(combinedValveErrors,largeData,workstation,phase,problemTrialNum,problemTrialNums,problemTrialNumThisSession,problemTrialNumsThisSession,i,j,verbose)

%total count
problemTrialNum=problemTrialNum+1;
problemTrialNums(j,problemTrialNum)=i;

%session count
problemTrialNumThisSession=problemTrialNumThisSession+1;
problemTrialNumsThisSession(problemTrialNumThisSession)=i;

switch phase
    case 'discriminandum'
        combinedValveErrors{problemTrialNum}.details=largeData{j}.trialRecords(i).responseDetails.valveErrorDetails;
    case 'penalty'
        combinedValveErrors{problemTrialNum}.details=largeData{j}.trialRecords(i).errorRecords.responseDetails.valveErrorDetails;
    otherwise
        error('unknown phase')
end

combinedValveErrors{problemTrialNum}.subject=largeData{size(largeData,1)+j};
combinedValveErrors{problemTrialNum}.station=largeData{j}.trialRecords(i).station.id; %only if stations actually unique
combinedValveErrors{problemTrialNum}.station=workstation; %temp way for now, get from who calls function, pmm 070501
combinedValveErrors{problemTrialNum}.session=j;
combinedValveErrors{problemTrialNum}.trial=i;
combinedValveErrors{problemTrialNum}.phase=phase;
combinedValveErrors{problemTrialNum}.trialDate=largeData{j}.trialRecords(i).date;
combinedValveErrors{problemTrialNum}.sessionDate=largeData{j}.trialRecords(1).date;

if verbose
    sprintf('ERROR FOUND - number %d session %d trial %d',problemTrialNum,j,i)
    largeData{j}.trialRecords(i).responseDetails.valveErrorDetails
end

end

