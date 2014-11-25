batchLP_DMN;
close all

use = find(strcmp({files.monitor},'vert') & ~strcmp({files.site},'lgn') & ~strcmp({files.size},'8mm'));
%use = 1: length(files)
%%% calculate gradients and regions
use = use(1:5)
clear map merge
for i = 1:length(use)
    f=use(i)
     figure
    if ~isempty(files(f).topox)
        load([pathname files(f).topox],'map')
       
        subplot(2,3,1);
        imshow( polarMap(map{3},95));
        subplot(2,3,4);
        imagesc(abs(map{3}));
        axis equal; axis off;
        title([files(f).subj ' ' files(f).expt ' ' sprintf('%0.3f',max(abs(map{3}(:))))])
        drawnow
    else
        display('missing topox')
    end
    if ~isempty(files(f).topoXslow)
        load([pathname files(f).topoXslow],'map')
        
        subplot(2,3,2);
        imshow( polarMap(map{3},95));
        subplot(2,3,5);
        imagesc(abs(map{3}));
        axis equal; axis off
        title([files(f).subj ' ' files(f).expt ' ' sprintf('%0.3f',max(abs(map{3}(:))))])
        drawnow
    end
    
    
    if ~isempty(files(f).stepBinary)
        load([pathname files(f).stepBinary],'map')
        
        subplot(2,3,3);
        imshow( polarMap(map{3},95));
        subplot(2,3,6);
        imagesc(abs(map{3}));
        axis equal
        title([files(f).subj ' ' files(f).expt ' stepbinary'])
        drawnow
    end
    
%     if ~isempty(files(f).loom)
%         loom_resp{f}=fourPhaseOverlay(files(f),pathname,outpathname,'loom');
%     end
    
%     if ~isempty(files(f).topox)
%         clear dfof_bg sp
%         load([pathname files(f).topox],'dfof_bg','sp')
%         if exist('dfof_bg','var')& exist('sp','var')
%             getPCA(dfof_bg,sp,[files(f).subj ' ' files(f).expt])
%             title([files(f).subj ' ' files(f).expt ' topoX PCA'])
%         end
%          
%     end
%     
%     if ~isempty(files(f).stepBinary)
%         clear dfof_bg sp
%         load([pathname files(f).stepBinary],'dfof_bg','sp')
%         if exist('dfof_bg','var') & exist('sp','var')
%             getPCA(dfof_bg,sp,[files(f).subj ' ' files(f).expt])
%         end
%         title([files(f).subj ' ' files(f).expt ' stepbinary PCA'])
%     end
    
    
    if ~isempty(files(f).histonum)
        figure
        nf = str2num(files(f).histonum); nf = floor(min(nf,16)/2);
        fbase = [pathname files(f).histology];
        fbase = fbase(1:end-2);
        nx = ceil(sqrt(nf));
        for fr = 1:nf
            fname = sprintf('%s%02d.tif',fbase,fr*2-1);
            im = imrotate(imread(fname),0);
            subplot(nx,nx,fr);
            imshow(im);
        end
        title([files(f).subj ' ' files(f).expt])
    end
    
end


% %fourPhaseAvg(loom_resp,allxshift-25,allyshift-25,zoom, 80, avgmap);
%
% for f = 1:length(use)
%  f
%  grating_resp{f}=fourPhaseOverlay(files(use(f)),pathname,outpathname,'grating');
% end
