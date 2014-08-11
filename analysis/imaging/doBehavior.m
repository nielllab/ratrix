%doBehavior
close all

clear behav
for f = 1:length(use); behav{f}=[]; end;

matlabpool open
tic
clear correct ntrials
for f = 1:length(use)
    [behav{f} correct(f) ntrials(f)] = overlayMaps(files(use(f)),pathname,outpathname,1);
end
toc
matlabpool close
sprintf('subj %s correct %f trials %f',allsubj{s},mean(correct),mean(ntrials))

%%% try to subtract running from behavior
for f = 1:0
    %  %for f =1:1
    %      f
    %    % try
    %          try
    %         clear movemap
    %     [pathname files(use(f)).topoy]
    %     load([pathname files(use(f)).topoy],'movemap');
    %     figure
    %     imagesc(movemap,[-0.1 0.1])
    %     movemap = movemap-mean(movemap(:));
    %
    %        norunbehav = behav{f};
    %        zm = size(norunbehav,3)/size(movemap,2);
    %        movemap = imresize(movemap,zm);
    %        movemap = movemap/sqrt(sum(movemap(:).*movemap(:)));
    %        for t = 1:size(norunbehav,1)
    %            data = squeeze(norunbehav(t,:,:));
    %            data = data-mean(data(:));
    %            runcomponent = sum(sum(data.*movemap));
    %            norunbehav(t,:,:) = squeeze(norunbehav(t,:,:)) - runcomponent * movemap;
    %        end
    %        behavNoRun{f} = norunbehav;
    %     catch
    %         display('no movemap')
    %         close(gcf)
    %     end
    %
end
%behav=behavNoRun;
allsubj{s}
nb=0; avgbehav=0;
for f= 1:length(use)
    %for f= 1:1
    if ~isempty(behav{f})% & strcmp(files(use(f)).subj,allsubj{s}) ;
      f
      b = shiftdim(behav{f},1);
        zoom = 260/size(b,1);
        b = shiftImageRotate(b,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
        avgbehav = avgbehav+b;
        nb= nb+1;
    end
end
avgbehav = avgbehav/nb;

figure
for t= 1:6  %10:18
    subplot(2,3,t);
    %imshow(avgmap);
    hold on
    data = squeeze(avgbehav(:,:,t+7));
    
    h = imshow(mat2im(data,jet,[0 0.15]));
    
    imwrite(mat2im(data,jet,[0 0.15]),sprintf('behav_left3-4%d%s',t,'.tif'),'tif')
%     transp = zeros(size(squeeze(avgmap(:,:,1))));
%     transp(abs(data)>=0.00)=1;
%     set(h,'AlphaData',transp);
    
end
title(allsubj{s})

clear mov

for t = 1:12
    data = squeeze(avgbehav(:,:,t+3));
    
   
  mov(:,:,:,t) = mat2im(data,jet,[0 0.15]);
end
mov = immovie(mov);
vid = VideoWriter('g62b7lt correct behave.avi');
vid.FrameRate=10;
open(vid);
writeVideo(vid,mov);
close(vid)


data = avgbehav(:,:,3:16);
data = shiftdim(data,2);
t = 1:14;
t_interp = 1:0.25:14;
data_interp = interp1(t,data,t_interp);
clear mov
data_interp(data_interp<0.05)=0;
for t = 1:length(t_interp);
    mov(:,:,:,t) = mat2im(squeeze(data_interp(t,:,:)),gray,[0 0.15]);
end
mov = immovie(mov);
vid = VideoWriter('g62b7lt correct behave interp gray.avi');
vid.FrameRate=40;
open(vid);
writeVideo(vid,mov);
close(vid)






