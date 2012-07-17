function pcoExample
setRatrixPath;
dbstop if error

refresh = 1000;
numSecs = 5;

n = refresh*numSecs;

rec = nan(1,n);

p.n = round(.75*n/refresh/struct(pco).rate);
p.addr = getPPaddr;
p = init(pco(p));

disp('starting')

pri = Priority(MaxPriority('GetSecs','KbCheck'));
t = GetSecs;
for i=1:n
    [p,rec(i)] = exec(p);
    
    while GetSecs < t + 1/refresh
        %spin
    end
    t = GetSecs;
end
Priority(pri);

t = get(p); % [timeWanted busySpins timeTrig ackSpins timeAck]' x n

head = 1.1;
h = [];
s = 3;

h(end+1) = subplot(s,1,1);
data = t([2 4],:)';
x = plot(data);

d=3;
arrayfun(@(x,y) set(x,'LineWidth',y),x,(d-1)+(d*(length(x)-1):-d:0)');

ylabel('spins')
legend({'busy' 'ack'})
ylim([-1 head*max(data(:))+1]);

h(end+1) = subplot(s,1,2);
data = diff([t([1 3 5],1:end-1); t(1,2:end)])'*1000;
semilogy(data)
ylabel('ms')
legend({'busy' 'ack' 'next'});
%ylim([-10 head*max(data(:))])
linkaxes(h,'x');
xlim([1 struct(p).n]);
xlabel('exposure')
title(sprintf('rate %g (effective) %g (nominal) hz', 1/median(diff(t(1,:))), 1/struct(p).rate))

h(end+1) = subplot(s,1,3);
plot(1000*rec','x-')
hold on
plot([1 n],zeros(1,2),'w-')
xlabel('frame')
xlim([1 n])
ylabel('ms')

set(gcf,'PaperPositionMode','auto'); %causes print/saveas to respect figure size
set(gcf,'InvertHardCopy','off'); %preserves black background when colordef black
saveas(gcf,['C:\Users\nlab\Desktop\' datestr(now,30) '-0.5-ms.png'])
end

function out = getPPaddr
[~, b] = getMACaddress;
switch b
    case 'BCAEC555FC4B' %2p machine
        pportaddr = 'C800'; %pci add on (not C480)
    otherwise
        pportaddr = '0348';
end

out = pportaddr;
end

function setRatrixPath
r = 'ratrix';
[pathstr, name] = fileparts(mfilename('fullpath'));
while ~ismember(name,{r ''})
    [pathstr, name] = fileparts(pathstr);
end
if isempty(name)
    error('couldn''t find base dir')
end
addpath(fullfile(pathstr,r,'bootstrap'));
setupEnvironment
end