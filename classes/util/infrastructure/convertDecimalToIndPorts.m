function vec=convertDecimalToIndPorts(dec,numPorts)
% converts the representation in 'dec' (such as 4) to the old vector format (such as [1])
% vectorized (dec and numPorts can be vectors N long)
% only works if each element of dec converts to a single port (not multiple ports)
str=dec2bin(dec);
% pad str with leading zeros as necessary
toPad=numPorts-size(str,2);
for i=1:toPad
    tocat=num2str(zeros(size(str,1),1));
    str=[tocat str];
end
for i=1:size(str,1)
    try
    vec(i)=find(str(i,:)=='1');
    catch
        error('only works for single ports');
    end
end
end