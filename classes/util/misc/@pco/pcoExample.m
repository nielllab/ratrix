function pcoExample
setRatrixPath;
dbstop if error

refresh = 60;
n = 100;

p.n = n;
p.addr = getPPaddr;
p = init(pco(p));

disp('starting')
t = GetSecs;
for i=1:n
    p = exec(p);
    
    while GetSecs < t + 1/refresh
        %spin
    end
end

t = get(p); % [timeWanted busySpins timeTrig ackSpins timeAck]' x n

head = 1.1;
h = [];

h(end+1) = subplot(2,1,1);
data = t(:,[2 4]);
plot(data)
ylabel('spins')
legend({'busy' 'ack'})
ylim([-1 head*max(data(:))]);

h(end+1) = subplot(2,1,2);
data = diff([t([1 3 5],1:end-1) t(1,2:end)])'*1000;
plot(data)
ylabel('ms')
xlabel('frame')
legend({'busy' 'ack' 'next'});
ylim([-10 head*max(data(:))])

linkaxes(h,'x');
xlim([1 n]);

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