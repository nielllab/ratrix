function plotPerformancePerValuePerCondition(numCorrect, numAttempted, numYes,performanceMeasure, valueName, method, params)
%this functions assumes input of the type (targetContrast, condition, deviation, flankerContrast)


someConditions=params.someConditions;
availableConditions=someConditions;
colors=params.colors;
smallDisplacement=params.smallDisplacement;
alpha=params.alpha;
vals.conditionNames=params.conditionNames;

vals.contrasts=params.featureVals.contrasts;
vals.devs=params.featureVals.devs;
vals.flankerContrasts=params.featureVals.flankerContrasts;

stats.numYes=numYes;
stats.numCorrect=numCorrect;
[stats numAttempted]=filterFlankerStatistics(valueName, method, numAttempted, stats,vals);
numYes=stats.numYes;
numCorrect=stats.numCorrect;

pctCor=numCorrect./numAttempted;
pctYes=numYes./numAttempted;


someConditions=intersect(someConditions,availableConditions);


command = sprintf('values = params.featureVals.%s', valueName);
try
    eval(command);
catch
    disp(command);
    error('bad command');
end


switch performanceMeasure
    case {'pctCor','hitRate','correctRejections'}

        try
            %okay
            perf=pctCor;

            title(sprintf('performance per condition per %s', valueName))
            ylabel(performanceMeasure);
            hold on;  xlabel(valueName)  %when Signal Present and Absent
            for condition=availableConditions; %someConditions
                [performance, pci] = binofit(numCorrect(:,condition),numAttempted(:,condition),alpha);
                %errorbar(values+smallDisplacement(condition),performance,performance-pci(:,1),pci(:,2)-performance,'color',colors(condition,:))
                for i=1:length(values)
                    plot([values(i)+smallDisplacement(condition)]*[1 1],[pci(i,1) pci(i,2)],'color',colors(condition,:))
                end
            end
            for condition=someConditions
                h(condition)=plot(values+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:));
            end
            %legend(h(fliplr(someConditions)),vals.conditionNames(fliplr(someConditions)),'Location','NorthEast')%NorthEastOutside
            hold off
        catch
            numCorrect
            numAttempted
            mfilename
            edit(mfilename)
            keyboard
        end

    case 'dpr'
        error('may contain assumptions about pooling across context -- line 19')
        
        %for error bars use Bayesian SDT
        
        % perf=dpr;
        %hold on; ylabel('Sensitivity (d-prime)')
        % for condition=someConditions
        %     h(condition)=plot(values+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:))
        % end
        % legend(h(fliplr(someConditions)),conditionNames(fliplr(someConditions)),'Location','NorthEastOutside')
        % hold off
    case 'pctYes'
        %okay
        perf=pctYes;

        title(sprintf('performance per condition per %s', valueName))

        hold on; ylabel(performanceMeasure); xlabel(valueName)  %when Signal Present and Absent
        
        for condition=availableConditions; %someConditions
            [performance, pci] = binofit(numYes(:,condition),numAttempted(:,condition),alpha);
            %errorbar(values+smallDisplacement(condition),performance,performance-pci(:,1),pci(:,2)-performance,'color',colors(condition,:))
            for i=1:length(values)
                plot([values(i)+smallDisplacement(condition)]*[1 1],[pci(i,1) pci(i,2)],'color',colors(condition,:))
            end

        end
        for condition=someConditions
            h(condition)=plot(values+smallDisplacement(condition),perf(:,condition),'.','MarkerSize',20,'color',colors(condition,:));
        end
        legend(h(fliplr(someConditions)),vals.conditionNames(fliplr(someConditions)),'Location','NorthEast')%NorthEastOutside
        hold off

    otherwise
        error('not an allowed performanceMeasure')
end



