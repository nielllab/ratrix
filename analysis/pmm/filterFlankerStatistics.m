function [stats numAttempted]=filterFlankerStatistics(valueName,method,numAttempted,stats,vals)
%valueName='constrasts' | 'devs'
%method='allDevsAndFlankerContrasts' | 'mostFrequentDevAndFlankerContrast'| 'allTargetAndFlankerContrasts'
%numAttempted must be the same size as the fields in stats
%this function expects output from flankerAnalysis of the type
%(targetContrast, condition, deviation, flankerContrast)
%
%example:
%[numAttempted stats]=filterFlankerStatistics(valueName, method, numAttempted, stats,vals);


resetNumAttempted=numAttempted;

numTContrast=size(numAttempted,1);
numConditions=size(numAttempted,2);
numDevs=size(numAttempted,3);
numFContrast=size(numAttempted,4);

f=fieldnames(stats);
numStats=length(f);
for i=1:numStats


    numAttempted=resetNumAttempted;

    if ~all(size(numAttempted)==size(stats.(f{i})))
        error('stats must be the same size as numAttempted');
    end

    switch valueName
        case 'contrasts'
            switch method

                case 'allDevsAndFlankerContrasts'
                    numAttempted=sum(sum(numAttempted,3),4);
                    stats.(f{i})=sum(sum(stats.(f{i}),3),4);

                    %size(numAttempted)

                    % reduce d-prime as well
                    % dpr=dpr(availableContrasts,availableConditions,devInd,flankerContrastInd)


                case 'mostFrequentDevAndFlankerContrast'
                    %  find the most frequent flanker contrast
                    flankerContrastCount=sum(sum(sum(numAttempted,3),2),1);
                    flankerContrastInd=find(flankerContrastCount==max(flankerContrastCount));
                    vals.flankerContrast=vals.flankerContrasts(flankerContrastInd);
                    %keyboard
                    % for the selected flankerContrast,  find the most frequent deviation
                    devCount=sum(sum(numAttempted(:,:,:,flankerContrastInd),2),1);
                    devInd=find(devCount==max(devCount));
                    vals.devs=vals.devs(devInd);

                    % set the number correct and attempted
                    numAttempted=numAttempted(:,:,devInd,flankerContrastInd);
                    stats.(f{i})=stats.(f{i})(:,:,devInd,flankerContrastInd);

                    %  further prune unavailable contrasts and conditions
                    availableContrasts=find(sum(numAttempted,2)~=0);  %might only be some do to filtering
                    availableConditions=find(sum(numAttempted,1)~=0);  %expect all
                    vals.contrasts=vals.contrasts(availableContrasts);
                    vals.conditionNames
                    availableConditions
                    vals.conditionNames=vals.conditionNames(availableConditions)


                    % set the number correct and attempted
                    numAttempted=numAttempted(availableContrasts,availableConditions);
                    stats.(f{i})=stats.(f{i})(availableContrasts,availableConditions);

                    %contrastCount=sum(sum(sum(numAttempted,4),3),2); %sum across what you check
                    %find(contrastCount==max(contrastCount))

                case 'allTargetAndFlankerContrasts'

                    numAttempted=sum(sum(numAttempted,1),4);

                    stats.(f{i})=sum(sum(stats.(f{i}),1),4);  %sum over all but what you use
                    %         size(numAttempted)



                    % You have to reshape in order to reduce the dimensions because sum over
                    % the first dimension does not reduce the dimension size.
                    % Also, transpose is needed because "value" (= devs) has to be in the first
                    % dimension of the matrix.


                    numAttempted = reshape(numAttempted, numConditions,numDevs)';
                    stats.(f{i}) = reshape(stats.(f{i}), numConditions, numDevs)';

                otherwise
                    method
                    valueName
                    error('bad method for that value')

            end
        case 'devs'
            switch method

                case 'allTargetAndFlankerContrasts'

                    numAttempted=sum(sum(numAttempted,1),4);

                    stats.(f{i})=sum(sum(stats.(f{i}),1),4);  %sum over all but what you use
                    %         size(numAttempted)



                    % You have to reshape in order to reduce the dimensions because sum over
                    % the first dimension does not reduce the dimension size.
                    % Also, transpose is needed because "value" (= devs) has to be in the first
                    % dimension of the matrix.


                    numAttempted = reshape(numAttempted, numConditions,numDevs)';
                    stats.(f{i}) = reshape(stats.(f{i}), numConditions, numDevs)';
                    %         size(numAttempted)
                otherwise
                    method
                    valueName
                    error('bad method for that value')

            end

        otherwise
            valueName
            error('bad valueName')

    end

end