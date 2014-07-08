function [data percentCorrect numtrials] = overlayMaps(expfile,pathname,outpathname,showImg)

dbstop if error
if ~exist('showImg','var')
    showImg=0;
end
opengl software
if isfield(expfile,'behav') && ~isempty(getfield(expfile,'behav'))
    load([pathname expfile.behav]); %%% behavior
    load( [outpathname expfile.subj expfile.expt '_topography.mat']); %%% topography
    
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
    
        for d = 1:20;
        histcorrect(d) = mean(correct(stop_time>(d-1)/2 & stop_time<d/2));
    end
        figure
        histcorrect(isnan(histcorrect))=0;
    plot(0.5:0.5:10,histcorrect);
    xlabel('stopping time')
    hold on
       h = hist(stop_time,0.5:0.5:10);
    plot(0.5:0.5:10,h/sum(h),'k');%  
    
    keyboard
    
    basemap =merge;
    titles = {'all trials','left trials','right trials','left-right','correct','incorrect','correct-incorrect'};
    

    
    resp_time = starts(3,trials)-starts(2,trials);
    stop_time = stop_time(trials);
    correct=correct(trials);
    targ=targ(trials);

    
    %     figure
    %     hist(resp_time,0.3:0.02:0.6)
    oldbg = bg;
       % minbg = min(bg,[],2);
        % minbg = nanmedianMW(bg(:,pts>=-0.5 & pts<0,:,:),2);
        minbg = min(bg(:,pts>=-0.5 & pts<=0,:,:),[],2);
        bg = bg-repmat(minbg,[1 size(bg,2) 1 1]);
    
    for i =1:1
        if i==1
            useTrials = find(correct==1&resp_time>0.3 & resp_time<0.6 & stop_time<1.1);
            for j =1:5
                tr = ceil(rand*length(useTrials));
                figure
                for fr = 1:24
                    subplot(4,6,fr);
                    imagesc(squeeze(bg(useTrials(tr),fr,:,:)),[0 0.15]);
                    axis off
                end
            end
          %  keyboard
            numtrials = length(useTrials)
            %keyboard
           if numtrials==0
               data=[];
               return
           end
           
               decon = deconvg6sParallel(nanmedianMW(bg(useTrials,4:end,:,:)),0.1);
            all_decon=squeeze(decon);
        elseif i==2
            decon = deconvg6s(nanmedianMW(bg(targ<0,:,:,:)),0.1);
        elseif i==3
            decon = deconvg6s(nanmedianMW(bg(targ>0,:,:,:)),0.1);
        elseif i ==4
            numtrials = 1;
            decon = deconvg6sParallel(nanmedianMW(bg(targ>0,:,:,:)),0.1) - deconvg6sParallel(nanmedianMW(bg(targ<0,:,:,:)),0.1);
        elseif i==5
            
            decon = deconvg6s(nanmedianMW(bg(correct==1,:,:,:)),0.1) ;
        elseif i==6
            decon = deconvg6s(nanmedianMW(bg(correct==0,:,:,:)),0.1)
        elseif i==7
             if ~isempty(bg(correct==0&targ<2&resp_time>0.3 & resp_time<0.6,:,:,:))
                 decon = deconvg6s(nanmedianMW(bg(correct==1&targ<2&resp_time>0.3 & resp_time<0.6,:,:,:)),0.1)-deconvg6s(nanmedianMW(bg(correct==0&targ<2&resp_time>0.3 & resp_time<0.6,:,:,:)),0.1);
             else
                 display('no wrong trials')
                  error;
                  decon = deconvg6s(nanmedianMW(bg(correct(trials)==1&targ(trials)<2&resp_time>0.3 & resp_time<0.6,:,:,:)),0.1);
             end
           % decon = deconvg6s(nanmedianMW(bg(correct(trials)==1,:,:,:)),0.1) - deconvg6s(nanmedianMW(bg(correct(trials)==0,:,:,:)),0.1);
        end
        use_pts=find(pts>=0)-3;
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
                if i~=4 & i~=7
                    himg = imshow((basemap));
                end
                % set(himg,'alphadata',0.5)
                hold on
                
                if i==4 | i==7
                    hbehav = imshow(mat2im(data,jet,[-0.15 0.15]));
                else
                    hbehav = imshow(mat2im(data,jet,[0 0.2]));
                end
                transp = zeros(size(data));
                if i==4 | i  ==7
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
    end
    
end
data = squeeze(decon);
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