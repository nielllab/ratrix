function show(p,s)

if ~exist('s','var') || isempty(s)
    s = 2;
end

head = 1.1;
h = [];

t = get(p); % [timeWanted busySpins timeTrig ackSpins timeAck]' x n

h(end+1) = subplot(s,1,1);
data = t([2 4],:)';
x = plot(data);

d=3;
arrayfun(@(x,y) set(x,'LineWidth',y),x,(d-1)+(d*(length(x)-1):-d:0)');

ylabel('spins')
legend({'busy' 'ack'})
if any(~isnan(data(:)))
    ylim([-1 head*max(data(:))+1]);
end

h(end+1) = subplot(s,1,2);
data = diff([t([1 3 5],1:end-1); t(1,2:end)])'*1000;
semilogy(data)
ylabel('ms')
legend({'busy' 'ack' 'next'});
%ylim([-10 head*max(data(:))])
linkaxes(h,'x');
xlim([1 struct(p).n]);
xlabel('exposure')

eff = find(isnan(t(1,:)),1);
if isempty(eff)
    eff = size(t,2);
else
    eff = eff-1;
end
title(sprintf('rate %g (effective) %g (nominal) hz', 1/median(diff(t(1,1:eff))), 1/struct(p).rate))
end