clear all
close all
colordef white
afiles = {'data0408.mat','data0812.mat','data1220.mat','data23.mat'}
path = 'c:\data\behavior figs\gc625 goto black';

timefig = figure;
hold on
c='bgrk'
for i= 1:length(afiles);
    load(fullfile(path,afiles{i}));
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
    plot(pts,nanmedianMW(bg(:,:,round(y),round(x))),c(i));
    xlabel('secs'); ylabel('df/f')
end
    