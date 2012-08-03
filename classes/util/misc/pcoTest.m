function pcoTest
setRatrixPath;
dbstop if error

trig = uint8(7); %uint8(1); %control port has incompatible electrical spec?
busy = uint8(15);

n = 100;
t = nan(n,4);

decAddr = getPPaddr;
slowChecks = true;

pp(trig,false,slowChecks,[],decAddr)
disp('starting')
for i=1:n
    t(i,[1 3]) = 0;
    while pp(busy,[],slowChecks,[],decAddr)
        t(i,1) = t(i,1)+1; %ticks til not busy
    end
    disp(i)
    t(i,2) = GetSecs; %time done previous; trig sent
    pp(trig,true,slowChecks,[],decAddr);
    while ~pp(busy,[],slowChecks,[],decAddr)
        t(i,3) = t(i,3)+1; %ticks til got trig
    end
    t(i,4) = GetSecs; %time trig ack
    pp(trig,false,slowChecks,[],decAddr);
end

head = 1.1;
h = [];

h(end+1) = subplot(2,1,1);
data = t(:,[3 1]);
plot(data)
ylabel('spins')
legend({'ack' 'busy'})
ylim([-1 head*max(data(:))]);

h(end+1) = subplot(2,1,2);
data = diff([t(1:end-1,[2 4]) t(2:end,2)],[],2)*1000;
plot(data)
ylabel('ms')
xlabel('frame')
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
        error('unrecognized MAC')
end

out = hex2dec(pportaddr);
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