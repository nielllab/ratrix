function fitPriors

close all

xs=[.05      .7  .75   .95];
pts=[.0001   9     1   .01];

% pts=pts/sum(pts);

qty=2000;
% 
% data=nan*zeros(1,qty);
% rands=repmat(rand(1,qty),length(pts),1);
% 
% test=rands<repmat([cumsum(pts)]',1,qty);
% 
% imagesc(test)

pts=round(qty*pts);

data=[];
for i=1:length(pts)
    data(end+1:end+1+pts(i))=xs(i);
end

subplot(3,1,1)
hist(data,100)
xlim([min(xs) max(xs)])

subplot(3,1,2)
p=lognfit(data)
sup=linspace(0,max(xs),100);
plot(sup,lognpdf(sup,p(1),p(2)))
title(sprintf('logn:\t\t%g\t\t%g',p(1),p(2)))
xlim([min(xs) max(xs)])

subplot(3,1,3)
p=gamfit(data)
plot(sup,gampdf(sup,p(1),p(2)))
title(sprintf('gamma:\t\t%g\t\t%g',p(1),p(2)))
xlim([min(xs) max(xs)])