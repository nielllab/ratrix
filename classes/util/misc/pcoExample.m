function pcoExample
setRatrixPath;
dbstop if error

refresh = 1000;
numSecs = 10;

n = refresh*numSecs;

rec = nan(1,n);

p.rate = 1000; %1/struct(pco).rate
p.n = round(.75*numSecs*p.rate);
p.addr = getPPaddr;
p = init(pco(p));

disp('starting')

pri = Priority(MaxPriority('GetSecs','KbCheck'));
t = GetSecs;
for i=1:n
    [p,rec(i)] = exec(p,true);
    
    while GetSecs < t + 1/refresh
        %spin
    end
    t = GetSecs;
end
Priority(pri);

show(p,3); % [timeWanted busySpins timeTrig ackSpins timeAck]' x n

subplot(3,1,3);
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