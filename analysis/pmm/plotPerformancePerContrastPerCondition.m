function plotPerformaePerContrastPerCondition(numCorrect, numAttempted, dpr, method, params)
%this functions assumes input of the type (targetContrast, condition, deviation, flankerContrast) 

someConditions=params.someConditions;
colors=params.colors;
smallDisplacement=params.smallDisplacement;
alpha=params.alpha;
conditionNames=params.conditionNames;

contrasts=params.featureVals.contrasts;
devs=params.featureVals.devs;
flankerContrasts=params.featureVals.flankerContrasts;

switch method
    case 'allDevsAndFlankerContrasts'
        numCorrect=sum(sum(numCorrect,3),4); %sum over all but what you use
        numAttempted=sum(sum(numAttempted,3),4);
        %size(numAttempted)
        pctCor=numCorrect./numAttempted;
    case 'mostFrequentDevAndFlankerContrast'
        %  find the most frequent flanker contrast
        flankerContrastCount=sum(sum(sum(numAttempted,3),2),1);
        flankerContrastInd=find(flankerContrastCount==max(flankerContrastCount));
        flankerContrast=flankerContrasts(flankerContrastInd);
        
        % for the selected flankerContrast,  find the most frequent deviation
        devCount=sum(sum(numAttempted(:,:,:,flankerContrastInd),2),1);
        devInd=find(devCount==max(devCount));
        dev=devs(devInd)
        
        % set the number correct and attempted
        numCorrect=numCorrect(:,:,devInd,flankerContrastInd);
        numAttempted=numAttempted(:,:,devInd,flankerContrastInd);
           
        %  further prune unavailable contrasts and conditions
        availableContrasts=find(sum(numAttempted,2)~=0);  %might only be some do to filtering      
        availableConditions=find(sum(numAttempted,1)~=0);  %expect all
        contrasts=contrasts(availableContrasts);
        conditionNames
        availableConditions
        conditionNames=conditionNames(availableConditions);
        
        % set the number correct and attempted  
        numCorrect=numCorrect(availableContrasts,availableConditions);
        numAttempted=numAttempted(availableContrasts,availableConditions);      
        
        %contrastCount=sum(sum(sum(numAttempted,4),3),2); %sum across what you check
        %find(contrastCount==max(contrastCount))
        
        % reduce d-prime as well
        dpr=dpr(availableContrasts,availableConditions,devInd,flankerContrastInd);
        
        pctCor=numCorrect./numAttempted;
    case 'user select devs and contrasts'
        
end


perf=pctCor;
title('performance per condition per contrast')
%subplot(211); 
hold on; ylabel('Percent Correct')  %when Signal Present and Absent
for condition=someConditions
    [performance, pci] = binofit(numCorrect(:,condition),numAttempted(:,condition),alpha);
    errorbar(contrasts+smallDisplacement(condition),performance,performance-pci(:,1),pci(:,2)-performance,'color',colors(condition,:))
end
for condition=someConditions
    h(condition)=plot(contrasts+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:));
end
legend(h(fliplr(someConditions)),conditionNames(fliplr(someConditions)),'Location','NorthEastOutside')
hold off

%%

% perf=dpr;
% subplot(212); hold on; ylabel('Sensitivity (d-prime)')
% for condition=someConditions
%     h(condition)=plot(contrasts+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:))
% end
% legend(h(fliplr(someConditions)),conditionNames(fliplr(someConditions)),'Location','NorthEastOutside')
% hold off