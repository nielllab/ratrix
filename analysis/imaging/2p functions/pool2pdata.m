afiles = {'C:\data\imaging\twophoton\102114 G62L1-LT passive viewing - prelearn\V1_1st\run4sessiondata.mat', ...
    'C:\data\imaging\twophoton\102114 G62J8-LT passive viewing - prelearn\V1\run3sessiondata.mat', ...
    'C:\data\imaging\twophoton\101414 GCaMP6 2p passive\G62H1TT\V1_spot2\run2sessiondata.mat' };



pminAll = []; osifitAll = []; osiAll = [];RAll=[];ampAll=[];
for i = 1:3
   i
   load(afiles{i},'pmin','osi','osifit','R','amp');
    pminAll = [pminAll pmin];
    osiAll = [osiAll osi];
    osifitAll = [osifitAll osifit];
    RAll = [RAll R];
    ampAll = [ampAll R];
end

use = find(pminAll<0.05 & ampAll>0.1);
resp = length(use)/length(pminAll);
sprintf('%d out of %d responsive = %f',length(use),length(pminAll),resp)

osifitScatter = osifitAll - rand(size(osifitAll))*0.05;
figure
[f x] = ecdf(osifitScatter(use));
plot(x,f); xlabel('OSI'); ylabel('cumulative fraction');

figure
[f x] = ecdf(RAll);
plot(x,f); xlabel('dF/F'); ylabel('cumulative fraction');

median(RAll)


figure
[f x] = ecdf(ampAll);
plot(x,f); xlabel('dF/F'); ylabel('cumulative fraction');

figure
hist(osifitAll(use),0.05:0.1:0.95);

figure
hist(ampAll,-1:0.1:3);
hold on
h=hist(ampAll(use),-1:0.1:3);
bar(-1:0.1:3,h,'r')

amps = ampAll;
amps(amp<0)=0;
figure
hist(amps,0:0.2:3 )

bins = 0.125:0.25:3;
[val cl cu] = bootstrap_ci_hist(amps,bins,68);
n=sum(val); val = val/n; cl= cl/n; cu=cu/n;
figure
bar(bins,val); hold on
errorbar(bins,val,val-cl,cu-val,'k.','Linewidth',2);
xlabel('dF/F'); ylabel('fraction');

bins = 0.05:0.1:1
[val cl cu] = bootstrap_ci_hist(osifitAll(use),bins,68);
n=sum(val); val = val/n; cl= cl/n; cu=cu/n;
figure
bar(bins,val); hold on
errorbar(bins,val,val-cl,cu-val,'k.','Linewidth',2);
xlabel('osi'); ylabel('fraction')


sprintf('%d out of %d OSI>0.33 = %f',sum(osifitAll(use)>0.33),length(use),sum(osifitAll(use)>0.33)/length(use))
% 
% 
% 
% afiles = {'C:\data\imaging\twophoton\052214 Gcamp6 running area\G62h1-TT\run1004sessiondata.mat' ...
%     'C:\data\imaging\twophoton\52514 Gcamp6 running area\G62B1-LT\run6sessiondata.mat' ...
%     'C:\data\imaging\twophoton\101514 GCaMP6 2p passive\G62J5rt\LOLA\run2sessiondata.mat' ...
%     'C:\data\imaging\twophoton\101514 GCaMP6 2p passive\G62J5rt\LOLA\run5sessiondata.mat' ...
%     }
% 
% afiles = {'C:\data\imaging\twophoton\102114 G62L1-LT passive viewing - prelearn\V1_1st\run4sessiondata.mat', ...
%     'C:\data\imaging\twophoton\102114 G62J8-LT passive viewing - prelearn\V1\run3sessiondata.mat', ...
%     'C:\data\imaging\twophoton\101414 GCaMP6 2p passive\G62H1TT\V1_spot2\run2sessiondata.mat' };
% 
% 
% cAll = []; zAll = [];
% for i = 1:length(afiles)
%     load(afiles{i},'runC','runZ')
%     length(runC)
%     cAll = [cAll runC-mean(runC)];
%     zAll = [zAll runZ-mean(runZ)];
% end
% 
% zthresh = 3;
% bins = -0.95:0.1:0.95
% h = hist(cAll,bins);
% figure
% bar(bins,h/length(cAll));
% hold on
% h = hist(cAll((zAll)>zthresh),bins);
% bar(bins,h/length(cAll),'g')
% h = hist(cAll((zAll)<-zthresh),bins);
% bar(bins,h/length(cAll),'r')
% xlim([-0.75 0.75])
% 
% figure
% plot(zAll)
% 
% sprintf('%d cells %0.2f correlated  %0.2f anti-correlated',length(zAll),sum(zAll>zthresh & abs(cAll)>0.05)/length(zAll),sum(zAll<-zthresh& abs(cAll)>0.05)/length(zAll))
% 
% 
%     