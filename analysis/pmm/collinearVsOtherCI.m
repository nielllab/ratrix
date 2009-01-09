function [delta CI]=collinearVsOtherCI(more,names)
%accepts the extra output from performancePerConditionPerDay and returns
%confidence intervals of the magnitude of the difference between the
%conditions

%CI
x1= more.numCorrect(find(strcmp(names,'---')),:); %collinear
n1= more.numAttempted(find(strcmp(names,'---')),:);
x2= sum(more.numCorrect(find(~strcmp(names,'---')),:)); %other types
n2= sum(more.numAttempted(find(~strcmp(names,'---')),:));
[delta CI]=diffOfBino(x2,x1,n2,n1,'wald');