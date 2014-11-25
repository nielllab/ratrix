afiles = {'C:\data\imaging\twophoton\102114 G62L1-LT passive viewing - prelearn\V1_1st\run4sessiondata.mat', ...
    'C:\data\imaging\twophoton\102114 G62J8-LT passive viewing - prelearn\V1\run3sessiondata.mat', ...
    'C:\data\imaging\twophoton\101414 GCaMP6 2p passive\G62H1TT\V1_spot2\run2sessiondata.mat' };

pminAll = []; osifitAll = []; osiAll = [];RAll=[];ampAll=[];
for i = 1:length(afiles);
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

figure
hist(osifitAll(use),0.05:0.1:0.95);

sprintf('%d out of %d OSI>0.33 = %f',sum(osifitAll(use)>0.33),length(use),sum(osifitAll(use)>0.33)/length(use))



afiles = {'C:\data\imaging\twophoton\052214 Gcamp6 running area\G62h1-TT\run1004sessiondata.mat' ...
    'C:\data\imaging\twophoton\52514 Gcamp6 running area\G62B1-LT\run6sessiondata.mat' ...
    'C:\data\imaging\twophoton\101514 GCaMP6 2p passive\G62J5rt\LOLA\run2sessiondata.mat' ...
    'C:\data\imaging\twophoton\101514 GCaMP6 2p passive\G62J5rt\LOLA\run5sessiondata.mat' ...
    }
cAll = []; zAll = [];
for i = 1:length(afiles)
    load(afiles{i},'runC','runZ')
    cAll = [cAll runC];
    zAll = [zAll runZ];
end

zthresh = 2.5;
bins = -0.95:0.1:0.95
h = hist(cAll,bins);
figure
bar(bins,h/length(cAll));
hold on
h = hist(cAll((zAll)>zthresh),bins);
bar(bins,h/length(cAll),'g')
h = hist(cAll((zAll)<-zthresh),bins);
bar(bins,h/length(cAll),'r')
xlim([-0.75 0.75])

sprintf('%d cells %0.2f correlated  %0.2f anti-correlated',length(zAll),sum(zAll>zthresh)/length(zAll),sum(zAll<-zthresh)/length(zAll))


    