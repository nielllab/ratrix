%%% doTopography


for f = 1:length(use)
    f
    [grad{f} amp{f} map_all{f} map{f} merge{f}]= getRegions(files(use(f)),pathname,outpathname);
    
end

clear allamp
for f = 1:length(use)
    f
    load(fullfile(pathname,files(use(f)).topox),'cycMap');
    df = max(cycMap,[],3) - min(cycMap,[],3);
    allamp(f) = max(df(:));
    
end

%%% need to max shiftImage return full array (260 across after zoom?), then fit it into a space of
%%% appropriate size
useReference=1;
if useReference
    load('C:/referenceMap.mat','avgmap4d','avgmap');
end
display('aligning')



%%% align gradient maps to first file
for f = 1:length(use); %changed from 1:length(map)
    f
    if useReference
        comparemaps{1}=avgmap4d;  comparemaps{2}=map{f}; comparemerge{1}=avgmap; comparemerge{2}=merge{f};
        [imfit{f} allxshift(f) allyshift(f) allthetashift(f) allzoom(f)] = alignMapsRotate(comparemaps, comparemerge, [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor] );
    else
        [imfit{f} allxshift(f) allyshift(f) allthetashift(f) allzoom(f)] = alignMapsRotate(map([length(use) f]), merge([length(use) f]), [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor] );
    end
    xshift = allxshift(f); yshift = allyshift(f); thetashift = allthetashift(f); zoom = allzoom(f);
    
    save( [outpathname files(use(f)).subj files(use(f)).expt '_topography.mat'],'xshift','yshift','zoom','-append');
end
%

%close all


display('computing averages')

x0 =0; y0=0; sz = 130;
%x0 =0; y0=0; sz = 128;

nx = 2; ny=3;
avgmap=0; meangrad{1}=0; meangrad{2}=0; meanpolar{1} = 0; meanpolar{2}=0;meanamp=0;avgmap4d=0;
for f= 1:length(use) ;
    %for f= [5 8];
    f
    
    if allxshift(f)>-100
        m = shiftImageRotate(merge{f},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
        
        
        sum(isnan(m(:)))
        
        sum(isnan(merge{f}(:)))
        avgmap = avgmap+m;
        
        figure
        subplot(nx,ny,2)
        imshow(m);
        title( [files(use(f)).subj ' ' files(use(f)).expt ' ' files(use(f)).monitor f] );
        
        imblue=zeros(100,100); imgreen=zeros(100,100);
        
        %%% comment out if can't find images
        try
            imblue = imread([datapathname files(use(f)).topoxdata '_0001.tif']);
            imgreen = imread([datapathname files(use(f)).topoxdata '_0004.tif']);
        catch
            try
            imblue = imread([datapathname files(use(f)).topoxdata '_000001.tif']);
            imgreen = imread([datapathname files(use(f)).topoxdata '_000004.tif']);
            catch
                display('cant find images')
            end
        end
        if sum(imblue(:)>0)
            subplot(nx,ny,3)
            
            imagesc( shiftImageRotate(imblue,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),0.5,sz));
            colormap(gray)
            axis off; axis equal
            
            subplot(nx,ny,6)
            imagesc( shiftImageRotate(imgreen,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),0.5,sz));
            axis off; axis equal
            colormap(gray)
        end
        %%% up to here
        
        for ind=1:4
            map4d(:,:,ind)=shiftImageRotate(squeeze(map{f}(:,:,ind)),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
        end
        avgmap4d=avgmap4d+map4d;
        
        for ind = 1:2
            gradshift{ind} = shiftImageRotate(real(grad{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            gradshift{ind} = gradshift{ind} + sqrt(-1)* shiftImageRotate(imag(grad{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            
            meangrad{ind} = meangrad{ind} + gradshift{ind};
            ampshift = shiftImageRotate(amp{f}{2},allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            subplot(nx,ny,5)
            
            imagesc(ampshift,[0 0.05]); axis off; axis equal; colormap gray
            
            meanamp = meanamp+ ampshift;
            allGrad(:,:,ind,f) = gradshift{ind}.* ampshift;
            
            polarshift{ind} = shiftImageRotate(real(map_all{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            polarshift{ind} = polarshift{ind} + sqrt(-1)* shiftImageRotate(imag(map_all{f}{ind}),allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),allzoom(f),sz);
            subplot(nx,ny,1+(ind-1)*ny);
            
            imshow(polarMap(polarshift{ind},94));
            allPolar(:,:,ind,f) = polarshift{ind};
            meanpolar{ind} = meanpolar{ind} + polarshift{ind};
            %            subplot(nx,ny,4+(ind-1)*ny);
            %             dx=4;
            %          rangex = dx:dx:size(gradshift{1},1); rangey = dx:dx:size(gradshift{1},2);
            %
            %          imshow(ones(size(gradshift{ind}))); hold on
            %          quiver( rangex,rangey,10*real(gradshift{ind}(rangex,rangey)),10*imag(gradshift{ind}(rangex,rangey)))
            
        end
            if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end
    
end
avgmap4d=avgmap4d/length(use);
avgmap = avgmap/length(use);
avgmapfig = figure

imshow(avgmap);
title('average topo  map');
meangrad{1} = meangrad{1}/length(use); meangrad{2} = meangrad{2}/length(use);
meanpolar{1} = meanpolar{1}/length(use); meanpolar{2} = meanpolar{2}/length(use);
meanPolarAll(:,:,s,1)= meanpolar{1}; meanPolarAll(:,:,s,2)= meanpolar{2};

allPhase(:,:,1) = mod(angle(meanpolar{1}),2*pi);
allPhase(:,:,2) = mod(angle(meanpolar{2}),2*pi);

if length(use)>1
    for ind = 1:2
        data = squeeze(allPolar(:,:,ind,:));
        data = reshape (data,size(data,1)*size(data,2),size(data,3));
        xc = corrcoef(data);
        figure
        imagesc(imresize(abs(xc),10,'nearest'),[0.5 1]);
        xc(xc==1)=NaN;
        d = abs(xc(:));
        d= d(~isnan(d));
        xcAll(s,ind) = mean(d);
        xcStd(s,ind) = std(d);
        title([allsubj{s} ' ' num2str(ind)])
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
        
    end
end

% frame = zeros(260,320,4);
% frame(:,31:290,:)=avgmap4d;
% avgmap4d=frame;
%
% frame=zeros(260,320,3);
% frame(:,31:290,:)=avgmap;
% avgmap=frame;

load('C:/mapoverlay.mat')


for m=1:2
    figure
    imshow(polarMap(meanpolar{m},92));
end

figure
for m=1:2
    subplot(2,2,m);
    
    imshow(polarMap(meanpolar{m},95));
    title(allsubj{s})
    hold on
    plot(ypts,xpts,'w.','Markersize',2)
    %     im = polarMap(meanpolar{m},80);
    %     imwrite(im,sprintf('polarmap%d%s', m,'.tif'), 'tif')
end
subplot(2,2,3)
imshow(avgmap);
title('average topo  map');
hold on
plot(ypts,xpts,'w.','Markersize',2)

subplot(2,2,4);

imAmp = max(abs(meanpolar{1}),abs(meanpolar{2}));
imAmp=imAmp/(prctile(imAmp(:),90));
imAmp(imAmp>1)=1;imAmp = imAmp.^1.5;
showGradient(allPhase,imAmp,xpts,ypts);
figure
showGradient(allPhase,imAmp,0,0);

%
% divmap = getDivergenceMap(meanpolar);
% figure
% imagesc(divmap); axis equal

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

