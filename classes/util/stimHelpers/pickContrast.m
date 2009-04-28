%return a contrast factor to multiply standard normal values so that only
%ptile percent of the result will have absolute values larger than
%abs(doNotExceed)
function out=pickContrast(doNotExceed,ptile)
if ptile<=0 || ptile>=1
    error('0<ptile<1')
end

out=abs(doNotExceed/norminv(ptile/2));

% n=100;
% d=10000;
% for i=1:n
%     a(i)=sum(abs(out*randn(1,d))>doNotExceed)/d;
% end
% plot(a)