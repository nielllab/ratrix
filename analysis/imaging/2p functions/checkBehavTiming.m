%%% diagnostic for timing alignment
[f p] = uigetfile('*.mat','behav session file');
load(fullfile(p,f),'phasetimes','starts');

dt = diff(phasetimes);
stopTTL = dt(1:3:end);
stopRatrix = abs(starts(:,1));

figure
plot(stopTTL); hold on; plot(stopRatrix,'.'); title('stopping time'); legend({'TTL','Ratrix'}); xlabel('trial #'); ylabel('secs');