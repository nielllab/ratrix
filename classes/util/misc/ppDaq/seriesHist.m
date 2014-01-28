function out = seriesHist(x,y,f,r,t,lab,ylab,xlab)
if ~isvector(x) || ~(size(y,1)==length(x) || (isvector(y) && length(y)==length(x))) || isempty(x)
    error('x must be nonempty vector, length equal to number of rows in y')
end

lims = cellfun(@(f) f(y(:)),{@min @max});
lims = lims + [-1 1] * .1 * diff(lims);
b = linspace(lims(1),lims(2),1000);
h = hist(y,b);

a = [];
figure(f)

a(end+1) = subplot(t,2,1+(r-1)*2);
out = a;
plot(x,y)
title(lab)
ylabel(ylab)
xlabel(xlab)
ylim(lims)
xlim(x([1 end]))

a(end+1) = subplot(t,2,2+(r-1)*2);
semilogx(h/length(x),b)
ylim(lims)

linkaxes(a,'y')
end