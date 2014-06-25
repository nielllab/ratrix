%%% doTopography


for f = 1:length(use)
    f
    [grad{f} amp{f} map_all{f} map{f} merge{f}]= getRegions(files(use(f)),pathname,outpathname);
end

%%% align gradient maps to first file
for f = 1:length(use); %changed from 1:length(map)
%    for f = 1:1
    [imfit{f} allxshift(f) allyshift(f) allthetashift(f) allzoom(f)] = alignMapsRotate(map([1 f]), merge([1 f]), [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor] );
    xshift = allxshift(f); yshift = allyshift(f); thetashift = allthetashift(f); zoom = allzoom(f);
    save( [outpathname files(use(f)).subj files(use(f)).expt '_topography.mat'],'xshift','yshift','zoom','-append');
end
%

%x0 =0; y0=0; sz = 80;
avgmap=0; meangrad{1}=0; meangrad{2}=0; meanpolar{1} = 0; meanpolar{2}=0;meanamp=0;
for f= 1:length(use) ;
    f
    
    if allxshift(f)>-50
        m = shiftImageRotate(merge{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
        sum(isnan(m(:)))
        
        sum(isnan(merge{f}(:)))
        avgmap = avgmap+m;
        
%         figure
%         imshow(m);        
%         title( [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor] );
        
        for ind = 1:2
            gradshift{ind} = shiftImageRotate(real(grad{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            gradshift{ind} = gradshift{ind} + sqrt(-1)* shiftImageRotate(imag(grad{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            meangrad{ind} = meangrad{ind} + gradshift{ind};
            ampshift = shiftImageRotate(amp{f}{2},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            meanamp = meanamp+ ampshift;
            
            polarshift{ind} = shiftImageRotate(real(map_all{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            polarshift{ind} = polarshift{ind} + sqrt(-1)* shiftImageRotate(imag(map_all{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            meanpolar{ind} = meanpolar{ind} + polarshift{ind};
   end
    end
    
end
avgmap = avgmap/length(use);
figure
imshow(avgmap);
title('average topo  map');
meangrad{1} = meangrad{1}/length(use); meangrad{2} = meangrad{2}/length(use);
meanpolar{1} = meanpolar{1}/length(use); meanpolar{2} = meanpolar{2}/length(use);

figure
for m=1:2
    subplot(1,2,m);
    imshow(polarMap(meanpolar{m},80));
    title(allsubj{s})
end


% divmap = getDivergenceMap(meanpolar);
% figure
% imagesc(divmap); axis equal
% 
% figure
% imagesc(divmap.*abs(meanpolar{1})); axis equal

% dx=4;
% rangex = dx:dx:size(meangrad{1},1); rangey = dx:dx:size(meangrad{1},2);
% figure
% for m = 1:2
%     subplot(1,2,m)
%     imshow(imresize(avgmap,1));
%     hold on
%     quiver(rangex,rangey,  10*real(meangrad{m}(rangex,rangey)),10*imag(meangrad{m}(rangex,rangey)),'w')
% 
% end

% figure
% meanmov{1}=zeros(size(avgmap,1),size(avgmap,2),100); meanmov{2}=meanmov{1};
% for f = 1:length(use)
%    f
%    if allxshift(f)>-20
%         for ind = 1:2
%         if ind==1
%             load([pathname files(use(f)).topox],'cycMap');
%         elseif ind==2
%             load([pathname files(use(f)).topoy],'cycMap');
%         end
%         %cycMap = cycle_mov;
%         for frm = 1:size(cycMap,3)
%             imshow(avgmap);
%             im = imresize(squeeze(cycMap(:,:,frm)),1);
%             imshift = shiftImage(im,allxshift(f)+x0,allyshift(f)+y0,allzoom(f),sz);
%             meanmov{ind}(:,:,frm) = meanmov{ind}(:,:,frm) +imshift;
%         end
%         end
%     end
% end
% 
% meanmov{1} = meanmov{1}/length(use);meanmov{2} = meanmov{2}/length(use);
% 
% 
% figure
% 
% for m = 1:2
%     clear mov
%     for frm = 1:size(cycMap,3)
%         imshow(avgmap);
%         imshift = meanmov{m}(:,:,frm);
%         hold on
%         h=imshow(mat2im(imshift,jet,[0 0.1]));
%         transp = zeros(size(imshift));
%         transp(imshift>0.02)=1;
%         set(h,'Alphadata',transp);
%         mov(frm) = getframe(gcf);
%         hold off
%         mov(f)=getframe(gcf);
%     end
%     if m==1
%         vid = VideoWriter('topoxavg.avi');
%     else
%         vid =VideoWriter('topoyavg.avi');
%     end
%     vid.FrameRate=25;
%     open(vid);
%     writeVideo(vid,mov);
%     close(vid)
% end
% 
% keyboard

