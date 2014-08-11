clear all

FFF_filelist
length(imfiles)
% %%% run analysis on all
% for i = 1:length(imfiles)
%     readTifDiff(imfiles{i},framerate,movPeriod);
% end

for i = 1:length(imfiles)
   try
       load([imfiles{i}{2}(1:end-11) 'datafile.mat'])
   catch
     readTifDiff(imfiles{i},framerate,movPeriod); 
     load([imfiles{i}{2}(1:end-11) 'datafile.mat'])
   end    
       map = cycMapAll{3};
    onset = movPeriod*framerate/2+3;
    
    SNR{i} = (map(:,:,onset) - mean(map(:,:,onset-5:onset-1),3))./std(map(:,:,onset-25:onset-1),[],3);
%     figure
%     imagesc(SNR{i}); axis equal; colorbar
%     title(titles{i});
    
end

figure
for i = 1:length(imfiles);
    subplot(2,4,i)
    imagesc(SNR{i},[-5 10]); axis equal; colorbar
   set(gca,'XtickLabel',[]);set(gca,'YtickLabel',[]);
   title(titles{i});
end
     