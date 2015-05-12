[f p] = uigetfile('*.mat','topox pts')
load(fullfile(p,f));
xPhase = phaseVal;
xdF = dF;

[f p] = uigetfile('*.mat','topoy pts')
load(fullfile(p,f));
yPhase = phaseVal;
ydF = dF;

[f p] = uigetfile('*.mat','grating pts')
load(fullfile(p,f));

figure
plot(abs(xPhase)./std(xdF,[],2),abs(yPhase)./std(ydF,[],2),'o')

figure
plot(abs(xPhase),abs(yPhase),'o')

absthresh=0.01;
use = find(abs(xPhase)>absthresh & abs(yPhase)>absthresh);
length(use)/length(xPhase)
figure
plot(mod(angle(xPhase(use)),2*pi),mod(angle(yPhase(use)),2*pi),'o');
axis([0 2*pi 0 2*pi])

figure
hold on
for i = 1:length(use)
   if ~isnan(osi(use(i)))
       plot(mod(angle(xPhase(use(i))),2*pi),mod(angle(yPhase(use(i))),2*pi),'o','Color',cmapVar(osi(use(i)),0,1));
   end
end

figure
hold on
for i = 1:length(use)
   if ~isnan(R(use(i)))
       plot(mod(angle(xPhase(use(i))),2*pi),mod(angle(yPhase(use(i))),2*pi),'o','Color',cmapVar(R(use(i)),0,2));
   end
end



figure
hold on
for i = 1:length(use)
   if ~isnan(abs(xPhase((use(i)))))
       plot(mod(angle(xPhase(use(i))),2*pi),mod(angle(yPhase(use(i))),2*pi),'o','Color',cmapVar(abs(xPhase(use(i))),0,0.15));
   end
end

figure
hold on
for i = 1:length(use)
   if ~isnan(abs(xPhase((use(i)))))
       plot(mod(angle(xPhase(use(i))),2*pi),mod(angle(yPhase(use(i))),2*pi),'o','Color',cmapVar(abs(yPhase(use(i))),0,0.15));
   end
end
