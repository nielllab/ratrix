%load('allbehav HvV spatial freq 200.mat');
load('C:/mapOverlay.mat')
labels = {'correct','incorrect','left','right'};


for cond= 1:1
    allavg = 0; allavg2=0;
    for s = 1:length(alldata)
        
        
        avgbehav = alldata{s}{cond};
        allavg = allavg+avgbehav;
        allavg2 = allavg2 + avgbehav.^2;
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
    
    allavg = allavg/s; allstd = sqrt(allavg2/s - allavg.^2);
    
    
    meanfig = figure; %zscorefig = figure;
    for t= 1:6  %10:18
       figure(meanfig)
       subplot(2,3,t);
        hold on
        data = squeeze(allavg(:,:,t+7));       
        h = imshow(mat2im(data,jet,[0 0.15]));
        plot(ypts,xpts,'w.','Markersize',1);
        
%         figure(zscorefig)
%                subplot(2,3,t);
%         hold on
%         data = squeeze(allavg(:,:,t+7)./allstd(:,:,t+7));       
%         h = imagesc(data,[1  5]);
%         plot(ypts,xpts,'w.','Markersize',1);
        
        %  imwrite(mat2im(data,jet,[0 0.15]),sprintf('behav_left3-4%d%s',t,'.tif'),'tif')
        %     transp = zeros(size(squeeze(avgmap(:,:,1))));
        %     transp(abs(data)>=0.00)=1;
        %     set(h,'AlphaData',transp);
        
    end
    title(['average ' labels{cond}])
end



