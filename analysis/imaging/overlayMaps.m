% close all
% [f p ] =uigetfile('*.mat','map file')
% load(fullfile(p,f));
% [fb pb ] =uigetfile('*.mat','behav file')
% load(fullfile(pb,fb));
% [f p ] =uigetfile('*.tif','image file')
% imraw = imread(fullfile(p,f));


for f = 1:length(files)
    if length(files{f})>=4 && ~isempty(files{f}{4})
        load([pathname files{f}{4}]); %%% behavior
        load( [outpathname expname '_topography.mat']); %%% topography
        
        basemap =merge;
        titles = {'all trials','left trials','right trials','left-right','correct','incorrect','correct-incorrect'};
        
        resp_time = starts(3,trials)-starts(2,trials);
        figure
        hist(resp_time,0.3:0.02:0.6)
        oldbg = bg;
        minbg = min(bg,[],2);
        bg = bg-repmat(minbg,[1 size(bg,2) 1 1]);
        
        for i =1:1
            if i==1
                decon = deconvg6s(nanmedianMW(bg(targ(trials)<2&resp_time>0.4 & resp_time<0.5,:,:,:)),0.1);
                all_decon=squeeze(decon);
            elseif i==2
                decon = deconvg6s(nanmedianMW(bg(targ(trials)<0,:,:,:)),0.1);
            elseif i==3
                decon = deconvg6s(nanmedianMW(bg(targ(trials)>0,:,:,:)),0.1);
            elseif i ==4
                decon = deconvg6s(nanmedianMW(bg(targ(trials)>0,:,:,:)),0.1) - deconvg6s(nanmedianMW(bg(targ(trials)<0,:,:,:)),0.1);
            elseif i==5
                
                decon = deconvg6s(nanmedianMW(bg(correct(trials)==1,:,:,:)),0.1) ;
            elseif i==6
                decon = deconvg6s(nanmedianMW(bg(correct(trials)==0,:,:,:)),0.1)
            elseif i==7
                
                decon = deconvg6s(nanmedianMW(bg(correct(trials)==1,:,:,:)),0.1) - deconvg6s(nanmedianMW(bg(correct(trials)==0,:,:,:)),0.1);
            end
            use_pts=find(pts>=0);
            if i==0
                figure
                subplot(2,2,1)
                imshow(polarMapTest(basemap));
                subplot(2,2,2)
                himg= imshow(imresize(imraw,size(basemap)))
                colormap(gray); axis equal
                subplot(2,2,3);
                imshow(polarMapTest(basemap));
                hold on
                himg= imshow(imresize(imraw,size(basemap)))
                colormap(gray); axis equal
                hold on
                set(himg,'AlphaData',0.5)
                subplot(2,2,4)
                data = squeeze(decon(1,use_pts(4),:,:));
                imshow(mat2im(data,jet,[-0.15 0.15]));
            end
            
            figure
            use_pts=find(pts>=0);
            for t=1:6
                subplot(2,3,t);
                if i~=4 & i~=7
                    himg = imshow((basemap));
                end
                % set(himg,'alphadata',0.5)
                hold on
                data = imresize(squeeze(decon(1,use_pts(t),:,:)),size(squeeze(basemap(:,:,1))));
                if i==4 | i==7
                    hbehav = imshow(mat2im(data,jet,[-0.15 0.15]));
                else
                    hbehav = imshow(mat2im(data,hot,[0 0.2]));
                end
                transp = zeros(size(data));
                if i==4 | i  ==7
                    % transp(abs(data)>0.02)=0.75;
                    transp=1;
                else
                    transp(abs(data)>0.05)=1;
                    %transp=1;
                end
                set(hbehav,'AlphaData',transp);
                if t ==6
                    title(titles{i});
                else
                    % title(sprintf('t=%0.2f',pts(use_pts(t))));
                end
            end
            %    fname = [fb(1:end-14) '_' titles{i} '.fig']
            %     saveas(gcf,fullfile('c:\data\imaging\figs',fname),'fig')
            %saveas(gcf,fullfile(pb,fname),'jpg')
        end
    end
    
end
% deconInterp = interp1(1:size(all_decon,1),all_decon,1:0.25:size(all_decon,1));
% deconInterp = permute(squeeze(deconInterp),[2 3 1]);
% deconImg = mat2im(deconInterp,gray,[-0.015 0.2]);
% deconMov = immovie(permute(deconImg,[1 2 4 3]));
%
% f = sprintf('%sRealtime.avi',fb(1:end-4))
% vid = VideoWriter(fullfile(p,f));
% vid.FrameRate=40;
% open(vid);
% writeVideo(vid,deconMov);
% close(vid)
%
% f = sprintf('%s4x.avi',fb(1:end-4))
% vid = VideoWriter(fullfile(p,f));
% vid.FrameRate=10;
% open(vid);
% writeVideo(vid,deconMov);
% close(vid)