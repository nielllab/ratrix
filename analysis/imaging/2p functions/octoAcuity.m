%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all

files = dir('*.mat');

for f = 1:length(files)
    load(files(f).name,'stimOrder','weightTcourse')
    for c = 1:17;
        resp(c,:) = nanmedian(weightTcourse(:,stimOrder==c),2);
        amp(c,f) = nanmean(resp(c,9:20),2);
    end
    
    figure
    plot(resp')
    
    figure
    plot(amp)
    for sf = 1:4;
        tuning(sf+1,f) = nanmean(amp(sf:4:end,f));
        sfResp(sf+1,:,f) = nanmean(resp(sf:4:end,:),1);
    end
    tuning(1,f) = amp(end);
    sfResp(1,:,f) = resp(end,:);
   
    figure
    plot(sfResp(:,:,f)')
    figure
    plot(tuning(:,f))
    
end


figure
plot(mean(resp,3)')
figure
plot(1:5,tuning);

figure
plot(mean(sfResp,3)'); title('resp vs SF')

figure
hold on
plot(2:5,mean(tuning(2:end,:),2),'bo')
errorbar(2:5,mean(tuning(2:end,:),2), std(tuning(2:end,:),[],2)/sqrt(length(files)),'k');
plot(1.5,mean(tuning(1,:),2),'bo')
errorbar(1.5,mean(tuning(1,:),2), std(tuning(1,:),[],2)/sqrt(length(files)),'k');

ylabel('mean dF/F');xlabel('cyc / deg'); title('SF tuning')
set(gca,'Xtick',[ 1.5 2:5]);
set(gca,'XtickLabel',{'0','0.05','0.02','0.08','0.32'});
xlim([1 5.5])