function [performances whenThisCondition titles]=doSubjectFlankerAnalysis(subTrialParams,smoothingWidth, plotOn);

            %get variables
            correct=subTrialParams(:,1);
            trialDates=subTrialParams(:,2);
            responses=subTrialParams(:,3);
            targetContrast=subTrialParams(:,4);
            targetOrientation=subTrialParams(:,5);
            flankerOrientation=subTrialParams(:,6);

            numTrials=size(subTrialParams,1);
            
            %define
            vrt=0;
            hrz=1.5707963267949;
            small=10^-6;
          
    %determine conditions
    numConditions=6;
    condition=logical(zeros(numConditions,numTrials));
    
    titles{1}='Solid is target present';
    condition(1,:)=(targetContrast>0);  %when target present
    condition(2,:)=(targetContrast==0);  %when target absent
    
    titles{2}='Solid is vertical target';
    condition(3,:)=(targetContrast>0) & (targetOrientation==vrt);   %when target present and vertical
    condition(4,:)=(targetContrast>0) & (abs(targetOrientation-hrz)<small);   %when target present and horizontal
    
    titles{3}='Solid is vertical flanker'; %flanker specific, but restricted to vertical targets as well
    condition(5,:)=(targetContrast>0) & (flankerOrientation==vrt) & (targetOrientation==vrt); %when flankers vertical
    condition(6,:)=(targetContrast>0) & (abs(flankerOrientation-hrz)<small) & (targetOrientation==vrt); %when flankers horizontal
    condition=logical(condition);
    
    
    %windowSizes = [10 50 100];
    windowSizes=smoothingWidth;
    
    for i=1:numConditions
      [performances{i} colorscale]=calculateSmoothedPerformances(correct(condition(i,:)),windowSizes,'boxcar','powerlawBW');
      whenThisCondition{i}=find(condition(i,:));
    end
    %colorscale=colorscale(:,1)
    

    if plotOn
        figure
        performancesAll =calculateSmoothedPerformances(correct,windowSizes,'boxcar','powerlawBW');
        subplot(2,2,1); plot(([1:size(performancesAll,1)]'),performancesAll(:,1),'k')
        title('Performance on all trial types'); ylabel('% correct')
        axis([1,numTrials,0.4,1])

        for i=1:numConditions/2
            subplot(2,2,i+1); title(titles{i}); hold on
            %note: ploting out of order of performance vector, so that solid red is ontop
            a=(i-1)*2+2; plot(whenThisCondition{a}',performances{a}(:,1),':c')
            a=(i-1)*2+1;  plot(whenThisCondition{a}',performances{a}(:,1),'r')
            axis([1,numTrials,0.4,1])
        end
    end
