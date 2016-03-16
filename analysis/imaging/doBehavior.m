%doBehavior


clear behav
for f = 1:length(use); behav{f}=[]; numTrialsPercond{f} = {}; end;


tic
clear correct ntrials

display('info about parallel pool')
%gcp('nocreate')

% if isempty(gcp('nocreate'))   %parallel pool not working 9/30/15 jw
%     pool = parpool;
% end
toc
tic
for f = 1:length(use)
sprintf('%d %s %s',f,files(use(f)).subj,files(use(f)).expt)
    [behav{f} correct(f) ntrials(f) nmf_spatial{f} nmf_temporal{f} numTrialsPercond{f}] = overlayMaps(files(use(f)),pathname,outpathname,1);
end
toc
%delete(gcp)

%keyboard
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
for cond = 1:4
nb=0; avgbehav=0;
for f= 1:length(use)
b=[];
    %for f= 1:1
    if ~isempty(behav{f}{cond})% & strcmp(files(use(f)).subj,allsubj{s}) ;
      f
      b = shiftdim(behav{f}{cond},1);
        zoom = 260/size(b,1);
        b = shiftImageRotate(b,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
        % for decon
        %avgbehav = avgbehav+b(:,:,1:14); %eventually should all be same length (21?)
       %%% for non-decon
        avgbehav = avgbehav+b(:,:,1:20); %eventually should all be same length (21?)
        nb= nb+1;
        shiftBehav{f}{cond} = b;
    end 
end
avgbehav = avgbehav/nb;

avgbehavCond{cond} = avgbehav;
%load('/backup/compiled behavior/mapOverlay.mat')
load('C:/mapOverlay.mat')

labels = {'correct','incorrect','left','right'};
figure
for t= 1:6  %10:18
    subplot(2,3,t);
    %imshow(avgmap);
    hold on
    data = squeeze(avgbehav(:,:,t+7));
    
    h = imshow(mat2im(data,jet,[0 0.15]));
    plot(ypts,xpts,'w.','Markersize',1);
  %  imwrite(mat2im(data,jet,[0 0.15]),sprintf('behav_left3-4%d%s',t,'.tif'),'tif')
%     transp = zeros(size(squeeze(avgmap(:,:,1))));
%     transp(abs(data)>=0.00)=1;
%     set(h,'AlphaData',transp);
    
end
title([allsubj{s} ' ' labels{cond}])
end


figure
for t = 1:6
    subplot(2,3,t);
    data = squeeze(avgbehavCond{4}(:,:,t+7) - avgbehavCond{3}(:,:,t+7));
    h= imshow(mat2im(data,jet,[-0.05 0.05]))
    
    hold on
     plot(ypts,xpts,'w.','Markersize',1);
end
title('left vs right')

figure
for t = 1:6
    subplot(2,3,t);
    data = squeeze(avgbehavCond{2}(:,:,t+7) - avgbehavCond{1}(:,:,t+7));
    h= imshow(mat2im(data,jet,[-0.1 0.1]))
  
    hold on
     plot(ypts,xpts,'w.','Markersize',2);
end
  title('incorrect - correct')

  
  for f= 1:length(behav);
      figure
  if ~isempty (behav{f}{1})  
      for t= 1:6
  subplot(2,3,t)
  imagesc(shiftBehav{f}{1}(:,:,t+7),[0 0.15]);
  hold on
  plot(ypts,xpts,'w.','Markersize',1);
  axis off
      end
      title(sprintf('%d %s %s',f,files(use(f)).subj,files(use(f)).expt))
  
  elseif isempty (behav{f}{1})
      sprintf('no correct trials')
      sprintf('%d %s %s',f,files(use(f)).subj,files(use(f)).expt)
  end
  end        
  
  figure
 imagesc(squeeze(avgbehavCond{1}(:,:,10)),[0 0.15])
  hold on
   plot(ypts,xpts,'w.','Markersize',1);
%    
%  clear data mnresp stdresp
%  range = -2:2;
%  for i = 1:4
%      [y x] = ginput(1);
%      y= round(y); x= round(x);
%      text(y,x,sprintf('%d',i))
%      for f = 1:length(behav);
%         if ~isempty (behav{f}{1})
%              data(:,:,:,f) = shiftBehav{f}{1}(x+range,y+range,:); %shiftBehave{f=18}{1}has only 260x260x19 (others 260x260x21)
%         elseif isempty (behav{f}{1})  
%              shiftBehav{f}{1} = NaN(260,260,21);
%             data(:,:,:,f) = shiftBehav{f}{1}(x+range,y+range,:);
%       sprintf('no correct answers fit criteria')
%       sprintf('%d %s %s',f,files(use(f)).subj,files(use(f)).expt)
%     %  keyboard
%         end
%      end
%      meanpix = squeeze(mean(mean(data,2),1));
%      
%    try  %put try catch because nanmean gave error 'too many arguements for a5 behavior jw 10/3/15
%      mnresp(i,:) = nanmean(meanpix,2);
%    catch
%      mnresp(i,:) = mean(meanpix,2);
%    end
%    
%    try
%      stdresp(i,:) = nanstd(meanpix,[],2)/sqrt(size(meanpix,2));
%    catch  
%      stdresp(i,:) = std(meanpix,[],2)/sqrt(size(meanpix,2));
%    end 
%    
%    
%  end
%  figure
%  plot(mnresp(:,6:12)')
%  
%   figure
%  plot(mnresp(:,:)')
%  
%  figure
%  errorbar(mnresp(:,1:16)',stdresp(:,1:16)')
%  
%  clear compBehav
%  for f=1:length(use);
%      if ~isempty (behav{f}{1})
%      compBehav(:,:,:,f) = shiftBehav{f}{1};
%      elseif isempty (behav{f}{1})
%          compBehav(:,:,:,f) = NaN(260,260,21);
%      end
%      
%  end
%  correction=mnresp(end,:);
%  correction=correction-min(correction(1:5));
%  clear baseline
%  baseline(1,:,:,1)=mnresp(end,:);
%  baseline = repmat(baseline,size(compBehav,1),size(compBehav,2),1);
%  meanImg = nanmean(compBehav,4) - baseline;
%  stdImg = nanstd(compBehav,[],4)/sqrt(size(compBehav,4));
% % figure
%  for t= 1:6
%      %subplot(2,3,t);
%      figure
%      imagesc(meanImg(:,:,t+7),[0 0.05])
%      hold on
%       plot(ypts,xpts,'w.','Markersize',1);
%       axis square
%       axis equal
%       axis off
%       title (['average activation T = ' num2str(t*100) 'ms'])
%  end
%  pointData = mnresp - repmat(correction,size(mnresp,1),1);
%  for i = 1:size(pointData,1)
%      pointData(i,:) = pointData(i,:)-min(pointData(i,1:6));
%      pointDataNorm(i,:) = pointData(i,:)/max(pointData(i,:));
%      stdData(i,:) = stdresp(i,:)/max(pointData(i,:));
%  end
%  
%  figure
%  errorbar(pointData(:,5:14)',stdresp(:,5:14)');
%  
%  figure
%  errorbar(pointDataNorm(1:end-1,5:14)',stdData(1:end-1,5:14)')
%  
%  
%  
%  
%  
%      
%  
% % clear mov
% % 
% % for t = 1:12
% %     data = squeeze(avgbehav(:,:,t+3));
% %     
% %    
% %   mov(:,:,:,t) = mat2im(data,jet,[0 0.15]);
% % end
% % mov = immovie(mov);
% % vid = VideoWriter('g62b7lt correct behave.avi');
% % vid.FrameRate=10;
% % open(vid);
% % writeVideo(vid,mov);
% % close(vid)
% % 
% % 
% % data = avgbehav(:,:,3:16);
% % data = shiftdim(data,2);
% % t = 1:14;
% % t_interp = 1:0.25:14;
% % data_interp = interp1(t,data,t_interp);
% % clear mov
% % data_interp(data_interp<0.05)=0;
% % for t = 1:length(t_interp);
% %     mov(:,:,:,t) = mat2im(squeeze(data_interp(t,:,:)),gray,[0 0.15]);
% % end
% % mov = immovie(mov);
% % vid = VideoWriter('g62b7lt correct behave interp gray.avi');
% % vid.FrameRate=40;
% % open(vid);
% % writeVideo(vid,mov);
% % close(vid)
% % 
% 




