%%% compiles data from sinusoidal gratings
%%% based on full-image weighted dF/F
%%% cmn 2019

close all

files = dir('*.mat');

for f = 1:length(files)
    load(files(f).name,'stimOrder','weightTcourse')
    for c = 1:17;
        resp(c,:) = nanmedian(weightTcourse(:,stimOrder==c),2);
        amp(c,f) = nanmean(resp(c,9:15),2);
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
errorbar(mean(tuning,2), std(tuning,[],2)/sqrt(length(files)));
ylabel('mean dF/F');xlabel('cyc / deg'); title('SF tuning')
set(gca,'Xtick',1:5);
set(gca,'XtickLabel',{'0','0.01','0.04','0.16','0.64'});
xlim([0.5 5.5])