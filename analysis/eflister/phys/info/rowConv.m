function out=rowConv(dims,stim)
out=zeros(size(dims,1),length(stim));
for i=1:size(dims,1)
    %sig=conv(dims(i,:),stim);
    sig=filter(dims(i,:),1,stim);
    tails=floor((length(sig)-size(out,2))/2);
    sig=sig(tails:end);
    out(i,:)=sig(1:end-(length(sig)-size(out,2)));
end