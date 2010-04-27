function out=nanMeanDown(in)
for i=1:size(in,2)
    out(i)=mean(in(~isnan(in(:,i)),i));
end
end