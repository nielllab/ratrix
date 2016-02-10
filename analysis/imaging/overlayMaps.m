function [alldata percentCorrect numtrials nmf_spatial nmf_temporal numTrialsPercond] = overlayMaps(expfile,pathname,outpathname,showImg)
nmf_spatial=[];
nmf_temporal=[];
alldata = [];

dbstop if error
if ~exist('showImg','var')
    showImg=0;
end
opengl software
  showImg=1;
  
if isfield(expfile,'behav') && ~isempty(getfield(expfile,'behav'))
    display('loading ...')
    
    behav_name = [pathname expfile.behav];
     behav_name(behav_name=='\')='/';
     
    load(behav_name,'trials','targ','correct','starts','onsets','pts','bg'); %%% behavior
    
    topo_name = [outpathname expfile.subj expfile.expt '_topography.mat'];
     topo_name(topo_name=='\')='/';
    
    load(topo_name); %%% topography
    
    resp_time = starts(3,:)-starts(2,:);
    stop_time = starts(2,:)-starts(1,:);
    tr = find(resp_time>0.5 & resp_time>0.6);
    percentCorrect = sum(correct(tr))/length(tr);
    
    
    percentIncorrect = sum(~correct(tr))/length(tr);
    sprintf('correct = %f',percentCorrect)
    
    clear histcorrect
    for d = 1:10;
        histcorrect(d) = mean(correct(resp_time>(d-1)/10 & resp_time<d/10));
    end
    histcorrect(15) = mean(correct(resp_time>1.5));
    histcorrect(isnan(histcorrect))=0;
    figure
    plot(0.05:0.1:1.5,histcorrect);
    xlabel('response time')
    ylim([ 0 1])
    
    hold on
    h = hist(resp_time,0.05:0.1:1.5);
    plot(0.05:0.1:1.5,h/sum(h),'k');
    title([expfile.subj ' ' expfile.expt])
    drawnow
    
    for d = 1:20;
        
        histcorrect(d) = mean(correct(stop_time>(d-1)/2 & stop_time<d/2));
    end
    
    %         histcorrect(isnan(histcorrect))=0;
    %     plot(0.5:0.5:10,histcorrect);
    %     xlabel('stopping time')
    %     hold on
    %        h = hist(stop_time,0.5:0.5:10);
    %     plot(0.5:0.5:10,h/sum(h),'k');%
    
    
    basemap =merge;
    titles = {'correct','incorrect','left','right','correct+incorrect'};
    
    
    
    resp_time = starts(3,trials)-starts(2,trials);
    stop_time = stop_time(trials);
    correct=correct(trials);
    targ=targ(trials);
    
%    save(['D:\behav files\' expfile.subj expfile.expt '_behavdata.mat'],'bg','resp_time','stop_time','correct','targ','pts')
    
    %     figure
    %     hist(resp_time,0.3:0.02:0.6)
    oldbg = bg;
    minbg = min(bg,[],2);
    % minbg = nanmedianMW(bg(:,pts>=-0.5 & pts<0,:,:),2);
     %minbg = min(bg(:,pts>=-0.5 & pts<=0,:,:),[],2);
    bg = bg-repmat(minbg,[1 size(bg,2) 1 1]);
    
    
    
    
    bg_all= bg;
    
%     %     im=bg_im(5:5:end,2:2:end,:,:);
%     %     thresh=prctile(im(:),40);
%     %     bg(bg_im<thresh)=0;
%     %
%     bg(bg>0.5)=0.5;
%     size(bg)
%     bg = bg(:,7:end,10:end,10:end-10);
%     useTrials = find(correct==1  & resp_time>0.4 & resp_time<0.7)  ;
%     length(useTrials)
%     bg = bg(useTrials,:,:,:);
%     
%     for tr = 1:size(bg,1);
%         for fr = 1:size(bg,2);
%             bg_sm(tr,fr,:,:) = imresize(squeeze(bg(tr,fr,:,:)),0.5, 'box');
%         end
%     end
%     bg = bg_sm;
    %bg =deconvg6s(bg,0.1);
    
    for dopca = 1:0
        nt = size(bg,1); nf = size(bg,2); nx=size(bg,3); ny=size(bg,4);
        obs = reshape(bg,nt*nf,nx,ny);
        obs = shiftdim(obs,1);
        obs = reshape(obs,nx*ny,nt*nf);
        obs(obs<0)=0;
        
        ncomp=12;
        tic
        % [u s v] = svd(obs);
        [u v] = nnmf(obs,ncomp,'replicates',1);
        toc
        nmf_spatial = u;
        
        nmf_temporal=v;
        
        spatial=figure
        temporal=figure
        deconv = figure
        for i = 1:ncomp
            figure(spatial)
            subplot(4,4,i);
            range = prctile(abs(u(:,i)),99.5);
            comp = u(:,i);
            if mean(comp)<0
                comp=-comp;
                invert=1;
            else invert=0;
            end
            imagesc(reshape(comp,nx,ny),[0 range]);
            axis square; axis off
            %colormap(gray);
            figure(temporal);
            subplot(4,4,i);
            tcourse = reshape(v(i,:),nt,nf)*range;
            
            if invert
                tcourse=-tcourse;
            end
            meantc = median(tcourse,1);
            plot(meantc,'b');
            hold on
            left = tcourse(targ(useTrials)<0,:);
            plot(median(left,1),'g');
            right = tcourse(targ(useTrials)>0,:);
            plot(median(right,1),'r');
            plot(5,0,'*')
            xlim([0 length(meantc)]); ylim([0 0.05])
            
            figure(deconv);
            subplot(4,4,i)
            
            tc = reshape(meantc,1,length(meantc),1,1);
            tcdeconv = deconvg6s(tc-min(meantc),0.1);
            hold on
            plot(tcdeconv,'b');
            allT(i,:) = tcdeconv;
            
            tc = reshape(median(left),1,length(meantc),1,1);
            tcdeconv = deconvg6s(tc-min(median(left)),0.1);
            hold on
            plot(tcdeconv,'g');
            
            tc = reshape(median(right),1,length(meantc),1,1);
            tcdeconv = deconvg6s(tc-min(median(right)),0.1);
            hold on
            plot(tcdeconv,'r');
            
            plot(5,0,'*')
            xlim([0 length(meantc)]); ylim([0 0.05])
            
        end
        
        
        
        use = 1:ncomp;
        
        
        figure
        plot(allT(use,:)');
        
        f=1;
        clear comps
        
        %  cmap = [0 1 1; 0 1 0; 1 0 0 ; 1 1 0; 1 0 1; 0 0 1; 0 0 0]
        
        cmap=hsv;
        for i = 1:length(use);
            im = reshape(nmf_spatial(:,use(i)),nx,ny);

            %  subplot(3,4,i); imagesc(im); axis off; axis equal
            comps(:,:,i) = im; %/max(im(:));
        end
        [amp ind] = max(comps,[],3);
        amp = 1.5*(amp-0.3); amp(amp<0)=0;
        overlay = mat2im(ind,cmap,[1 max(ind(:))+1]);
        for c = 1:3
            overlay(:,:,c) = overlay(:,:,c).*amp;
        end
        
        figure
        imshow(permute(overlay,[1 2 3]))
        
        
        % keyboard
        %
        %         s_clean = s;
        %         rmv = input('terms to remove: ');
        %         for i = 1:length(rmv)
        %             s_clean(rmv(i),rmv(i))=0;
        %         end
        %
        %         obs_clean = u*s_clean*v';
        %
        %         undoObs = reshape(obs_clean,nx,ny,nt*nf);
        %         undoObs = shiftdim(undoObs,2);
        %         undoObs = reshape(undoObs, nt,nf,nx,ny);
        %
        %         bg = undoObs;
        %         clear undoObs u s s_clean v
        
    end
    
    bg=bg_all(:,4:end,:,:);
    
    
    %%% set up selection criteria here!
    for i =1:5
        if i==1
            useTrials = find(correct==1&resp_time>0.4 & resp_time<0.6 );
                        for j =1:0
                            tr = ceil(rand*length(useTrials));
                            figure
                            for fr = 1:24
                                subplot(4,6,fr);
                                imagesc(squeeze(bg(useTrials(tr),fr,:,:)),[0 0.15]);
                                axis off
                            end
                        end
                 
        elseif i==2
            useTrials = find(correct==0&resp_time>0.4 & resp_time<0.6 );
            showImg=0;
        elseif i==3
            useTrials = find(correct==1&targ<0&resp_time>0.4 & resp_time<0.6 );
        elseif i ==4
            useTrials = find(correct==1&targ>0&resp_time>0.4 & resp_time<0.6 );
         elseif i ==5
            useTrials = find(resp_time>0);           
        elseif i==6
            decon = deconvg6s(nanmedianMW(bg(correct==1,:,:,:)),0.1) ;
        elseif i==7
            decon = deconvg6s(nanmedianMW(bg(correct==0,:,:,:)),0.1)
        elseif i==8
            if ~isempty(bg(correct==0&targ<2&resp_time>0.3 & resp_time<0.6,:,:,:))
                decon = deconvg6s(nanmedianMW(bg(correct==1&targ<2&resp_time>0.3 & resp_time<0.6,:,:,:)),0.1)-deconvg6s(nanmedianMW(bg(correct==0&targ<2&resp_time>0.3 & resp_time<0.6,:,:,:)),0.1);
            else
                display('no wrong trials')
                error;
                decon = deconvg6s(nanmedianMW(bg(correct(trials)==1&targ(trials)<2&resp_time>0.3 & resp_time<0.6,:,:,:)),0.1);
            end
            % decon = deconvg6s(nanmedianMW(bg(correct(trials)==1,:,:,:)),0.1) - deconvg6s(nanmedianMW(bg(correct(trials)==0,:,:,:)),0.1);
        end
 
        numtrials = length(useTrials);
        sprintf('cond %d; %d trials',i,numtrials)
        
        numTrialsPercond{i}= length(useTrials);
        
        if numtrials==0
            alldata{i} = [];

        else
           %%% deconv post averaging
           decon = deconvg6sParallel(nanmedianMW(bg(useTrials,:,:,:)),0.1);
            %use_pts=find(pts>=0)-3;
            
            %%% no deconv
           % decon = nanmedianMW(bg(useTrials,:,:,:));
          
            %%% deconv pre-averaging
%             for i = 1:length(useTrials);
%             i    
%                 deconAll(i,:,:,:) = deconvg6sParallel(bg(useTrials(i),:,:,:),0.1);
%             end
%             decon = nanmedianMW(deconAll);
            
            use_pts=find(pts>=0);
            if i==0 & showImg
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
            
          
            if showImg
                figure
                
                use_pts=find(pts>=0)-3;
                for t=1:6
                    data = imresize(squeeze(decon(1,use_pts(t),:,:)),size(squeeze(basemap(:,:,1))));
                    subplot(2,3,t);
                    if  i~=7
                        himg = imshow((basemap));
                    end
                    % set(himg,'alphadata',0.5)
                    hold on
                    
                    if i==7
                        hbehav = imshow(mat2im(data,jet,[-0.15 0.15]));
                    else
                        hbehav = imshow(mat2im(data,jet,[0 0.2]));
                    end
                    transp = zeros(size(data));
                    if  i  ==7
                        % transp(abs(data)>0.02)=0.75;
                        transp=1;
                    else
                        transp(abs(data)>0.0)=1; %% was 0.05
                        %transp=1;
                    end
                    set(hbehav,'AlphaData',transp);
                    if t ==6
                        title(titles{i});
                    elseif t ==1
                        title([expfile.subj ' ' expfile.expt ' ' expfile.task]);
                    end
                end
                %    fname = [fb(1:end-14) '_' titles{i} '.fig']
                %     saveas(gcf,fullfile('c:\data\imaging\figs',fname),'fig')
                %saveas(gcf,fullfile(pb,fname),'jpg')
            end
            
            alldata{i} = squeeze(decon);
        end
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