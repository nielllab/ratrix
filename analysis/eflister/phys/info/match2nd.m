function out=match2nd(first,rows)
out=zeros(size(rows));
for i=1:size(rows,1)
    second=rows(i,:);
    [xc lags]=xcorr(first,second);
    [garbage order]=sort(abs(xc));
    shift=lags(order(end));
    if xc(order(end))<0
        second=-1*second;
    end
    if shift>=0
        out(i,:)=[zeros(1,shift) second(1:end-shift)];
    else
        out(i,:)=[second(1-shift:end) zeros(1,-shift)];
    end
end