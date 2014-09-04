function y = visualGain(p,x);
% size(x)
% size(p)
y = (1+p(end)*x(:,end)).*(x(:,1:end-1)*p(1:end-1));
%size(sum(x*p))

