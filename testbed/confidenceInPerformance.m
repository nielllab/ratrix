
function [pass lower]=confidenceInPerformance();
%this is a function to convince oneself of a good setting for the
%confidence intervals when shaping

% numItter=20;
% numTrials=300;
% constantPerformance=0.7;
% correct=rand(numItter,numTrials)<constantPerformance;
% 
% alphas=[0.05 0.07 0.1 0.2];
% thresholds=[0.6:0.1:0.9 ];
% 
% 
% trialsAnalyzed=[10, 20, 30, 40, 50, 100,200,300];
% numTrialCategories=length(trialsAnalyzed);
% numThreshs=size(thresholds,2);
% numAlphas=size(alphas,2);
% pass=zeros(numThreshs,numAlphas,numItter,numTrialCategories);
% for i=1:numThreshs
%     for j=1:numAlphas
%         for k=1:numItter
%             for n=1:numTrialCategories
%                 [junk, pci] = binofit(sum(correct(k,1:trialsAnalyzed(n))),trialsAnalyzed(n),alphas(j));
%                 lower(i,j,k,n)=pci(1);
%                 pass(i,j,k,n)=pci(1)>thresholds(i);
%             end
%             disp(sprintf('thresh: %d, alpha: %d, itteration: %d',i,j,k))
%         end
%         fractionThatPass=reshape(mean(pass(i,j,:,:),3),1,numTrialCategories );
%         meanLower=reshape(mean(lower(i,j,:,:),3),1,numTrialCategories );
%         maxLower=reshape(max(lower(i,j,:,:),[],3),1,numTrialCategories );
%         
%         subplot(numThreshs,numAlphas,(i-1)*numAlphas+j)
%         plot(repmat(trialsAnalyzed,numItter,1),reshape(lower(i,j,:,:),numItter,numTrialCategories),'.'  )
%         hold on
%         plot(trialsAnalyzed,fractionThatPass)
%         plot(trialsAnalyzed,meanLower','k-')
%         text(200,0.2,sprintf('thr=%2.3g\na=%2.3g',thresholds(i),alphas(j)))
%     end
% end



numItter=20;
numTrials=300;
constantPerformance=[0.7:0.025:0.8];


alphas=[0.05 0.07 0.1 0.2 0.3];
%thresholds=[0.6:0.1:0.9 ];
threshold=.75;

trialsAnalyzed=[10, 20, 30, 40, 50, 100,200,300];
numTrialCategories=length(trialsAnalyzed);
%numThreshs=size(thresholds,2);
numAlphas=size(alphas,2);
numPerformanceLevels=size(constantPerformance,2);
pass=zeros(numPerformanceLevels,numAlphas,numItter,numTrialCategories);


for p=1:numPerformanceLevels
    correct=rand(numItter,numTrials)<constantPerformance(p);
    for j=1:numAlphas
        for k=1:numItter
            for n=1:numTrialCategories
                [junk, pci] = binofit(sum(correct(k,1:trialsAnalyzed(n))),trialsAnalyzed(n),alphas(j));
                lower(p,j,k,n)=pci(1);
                pass(p,j,k,n)=pci(1)>threshold;
            end
            disp(sprintf('perf#: %d, alpha: %d, itteration: %d',p,j,k))
        end
        fractionThatPass=reshape(mean(pass(p,j,:,:),3),1,numTrialCategories );
        meanLower=reshape(mean(lower(p,j,:,:),3),1,numTrialCategories );
        maxLower=reshape(max(lower(p,j,:,:),[],3),1,numTrialCategories );
        
        subplot(numPerformanceLevels,numAlphas,(p-1)*numAlphas+j)
        plot(repmat(trialsAnalyzed,numItter,1),reshape(lower(p,j,:,:),numItter,numTrialCategories),'.'  )
        hold on
        plot(trialsAnalyzed,fractionThatPass)
        plot(trialsAnalyzed,meanLower','k-')
        text(200,0.2,sprintf('trueP=%2.3g\na=%2.3g',constantPerformance(p),alphas(j)))
    end
end



