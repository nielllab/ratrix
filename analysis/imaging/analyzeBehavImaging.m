clear all
close all
colordef white
afiles = {'data0408singlebaseline.mat','data0812singlebaseline.mat','data1220single baseline.mat','data23singlebaseline.mat'}
path = 'c:\data\behavior figs\gc625 goto black';

timefig = figure;
hold on
c='bgrk'
for i= 1:length(afiles);
     load(fullfile(path,afiles{i}));
    request = starts(2,:)-starts(1,:);
    response = starts(3,:)-starts(2,:);
   aftererror = zeros(size(correct));
   aftererror(2:end) = 1-correct(1:end-1);
   
   
    targ= targ(trials);
    correct=correct(trials);
    correct_rate(i) = sum(correct)/length(trials);
    leftright(i) = sum(targ<0)/length(trials);
    resp(i,1) = sum(correct==1 & targ<0)/sum(targ<0); resp(i,2)=sum(correct==1 & targ>0)/sum(targ>0);
   
   N(i)=length(trials);

    if i==1
        figure
    imagesc(squeeze(nanmedianMW(bg(:,length(pts),:,:))))
    [x y] =ginput(1);
    end
    figure(timefig);
%     plot(pts,nanmedianMW(bg(correct==0,:,round(y),round(x))),'r');
%      plot(pts,nanmedianMW(bg(correct==1,:,round(y),round(x))),'g');
   plot(pts,nanmedianMW(bg(:,:,round(y),round(x)))-squeeze(nanmedianMW(bg(:,11,round(y),round(x)))),c(i));
   %    plot(pts,nanmedianMW(bg(:,:,round(y),round(x))),c(i));
 xlabel('secs'); ylabel('df/f');
    
    stoptime(i) = median(request(trials));
    resptime(i) = median(response(trials));
    bins = 0:0.25:3;
    figure
    h1=hist(request(trials),bins);
    h2=hist(response(trials),0:0.25:3);
    bar(bins,[h1; h2]')
    title(sprintf('%d',i))
    
    err(i) = median(aftererror(trials));
    
end
 load(fullfile(path,afiles{1}));
stoptime
resptime
err

figure
plot(resptime,stoptime); hold on
plot(resptime,stoptime,'o');
xlabel('response time (secs)')
ylabel('stopping time (secs)')
    