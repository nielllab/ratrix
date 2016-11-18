%%% diagnostic for timing alignment
%%% compares stopping time as recorded by ratrix
%%% versus recorded by scanbox TTL

close all
batch2pBehaviorSBX;

for i = 1:length(files);
    i
    load([pathname files(i).dir '\' files(i).behavPts],'thisSession');
    
    thisSession
    
    if strcmp(thisSession(1),'D') | strcmp(thisSession(1),'F') ;
        thisSession = ['\\langevin\backup\twophoton\Newton\data\' thisSession(4:end)]
    end
    
    try
        load(thisSession,'phasetimes','starts');
        
        dt = diff(phasetimes);
        stopTTL = dt(1:3:end);
        stopRatrix = abs(starts(:,1));
        
        err(i) = mean(abs(stopTTL(1:length(stopRatrix))-stopRatrix));
        
        figure
        plot(stopTTL); hold on; plot(stopRatrix,'.'); title(sprintf('%s %s err = %0.3f',files(i).subj,files(i).expt,err(i))); legend({'TTL','Ratrix'}); xlabel('trial #'); ylabel('secs');
        
        drawnow
        
    catch
        sprintf('couldnt do %s',thisSession)
        err(i) = NaN;
    end
end

figure
plot(err); xlabel('session'); ylabel('error'); ylim([0 0.5])
bad = find(err>0.05);

for i = 1:length(bad)
    display(sprintf('bad!!! %s %s err = %0.3f',files(bad(i)).subj, files(bad(i)).expt,err(bad(i))))
end

if isempty(bad)
    display('all good!!!')
end
