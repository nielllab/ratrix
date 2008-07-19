function out=doSubjectFlankerAnalysis(subTrialParams);

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
    
    titles{1}='Red is target present';
    condition(1,:)=(targetContrast>0);  %when target present
    condition(2,:)=(targetContrast==0);  %when target absent
    
    titles{2}='Red is vertical target';
    condition(3,:)=(targetContrast>0) & (targetOrientation==vrt);   %when target present and vertical
    condition(4,:)=(targetContrast>0) & (abs(targetOrientation-hrz)<small);   %when target present and horizontal
    
    titles{3}='Red is vertical flanker';
    condition(5,:)=(flankerOrientation==vrt); %when flankers vertical
    condition(6,:)=(abs(flankerOrientation-hrz)<small); %when flankers horizontal
    condition=logical(condition);
    
    windowSizes = [10 50 100];
    for i=1:numConditions
      [performances{i} colorscale]=calculateSmoothedPerformances(correct(condition(i,:)),windowSizes,'boxcar','powerlawBW');
    end
    %colorscale=colorscale(:,1)
    
    figure 
    performancesAll =calculateSmoothedPerformances(correct,windowSizes,'boxcar','powerlawBW');
    subplot(2,2,1); plot(([1:size(performancesAll,1)]'),performancesAll(:,3),'k')
    title('Percent correct on all trial types')
    axis([1,size(performancesAll,1),0.4,1])
    
    a=0;
    for i=1:numConditions/2
        subplot(2,2,i+1);
        a=a+1;  plot(([1:size(performances{a},1)]'),performances{a}(:,3),'r')
        hold on
        a=a+1; plot(([1:size(performances{a},1)]'),performances{a}(:,3),'b')
        title(titles{i})
        axis([1,size(performances{a},1),0.4,1])
    end

    out=performances;
    
function plotPerformance(performances1,performances2,color1,color2,colorscale)   
H2=plot(([1:size(performances1,1)]'), performances1*100);
%H3=plot(([1:size(performances2,1)]'), performances2*100);

for i=1:length(H2)
   set(H2(i),'Color',color1*colorscale(i));
   %set(H3(i),'Color',color2*colorscale(i));
end
