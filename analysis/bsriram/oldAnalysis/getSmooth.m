function o = getSmooth(d,w,flag)

o = zeros(1,length(d));

if(~rem(w,2))   
    w = w+1;    
end
range = (w-1)/2;
startInd = range+1;
stopInd = length(d)-range;

for i = startInd:stopInd
   o(i) = sum(d(i-range:i+range).*flag(i-range:i+range))/sum(flag(i-range:i+range));
end
    

end