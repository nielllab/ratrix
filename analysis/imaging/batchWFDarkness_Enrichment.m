% Batch Functional Connectivity Wide Field Analysis
%close all;clear all
% % Pathname2 since data and save-out location is different. Proccessed data
% % location is pathname2
pathname2 = '\\langevin\backup\widefield\Denise\Enrichment\DarknessConnectivity';
psfilename = 'c:\tempDeniseWF.ps';

redoani = input('reanalyze individual animal data? 0=no, 1=yes: ');
if redoani
    realign = input('rerun entire analysis with stim align? 0=no, 1=yes: ');
    deconvplz = input('Deconvolve Image Again? 0=no, 1=yes: ');
end

for f =1:length(use);
    % Create temporary file for PDF
    filename = sprintf('%s_%s_%s_darkness.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).cond);
    if (exist(fullfile(outpathname,filename),'file')==0 | redoani==1)
        psfilename = 'c:\tempDeniseWF.ps';
        if exist(psfilename,'file')==2;delete(psfilename);end
        load([pathname '\' files(use(f)).darkness],'dfof_bg','sp');
        % Downsize factor of aligned images.
        dsfactor = 1/8;
        %     dfof_bgAlign = imrotate(dfof_bg,alignTheta,'crop');
        %     dfof_bgAlignDS = imresize(dfof_bgAlign,dsfactor);
        
        zoom = 260/size(dfof_bg,1);
        dfof_bgAlign = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
        dfof_bgAlignDS = imresize(dfof_bgAlign,dsfactor);%,downsample,'method','box');
        % subtracting the meand dfof from each image.
        avgim = mean(mean(dfof_bgAlignDS,1),2);
        dfof_bgAlignDS2 = dfof_bgAlignDS - repmat(avgim,size(dfof_bgAlignDS,1),size(dfof_bgAlignDS,2),1);
        % Creating Standard Deviation images for visualizing areas
        dfof_bgAlignSTD = std(dfof_bgAlignDS,[],3);
        dfof_bgAlignSTD2 = std(dfof_bgAlign,[],3);
        %%
        % Deconvolution of downsampled data
        if (exist(filename,'file')==0 || deconvplz == 1)
            sprintf('doing deconvolution')
            %do deconvolution on the raw data
            img = shiftdim(dfof_bgAlignDS2+0.2,2); %shift dimesions for decon lucy and add 0.2 to get away from 0
            tic
            pp = gcp; %start parallel pool
            deconvimg = deconvg6sParallel(img,0.1); %deconvolve
            toc
            deconvimg = shiftdim(deconvimg,1); %shift back
            deconvimg = deconvimg - mean(mean(mean(deconvimg))); %subtract min value
            img = shiftdim(img,1); %shift img back
            img = img - 0.2; %subtract 0.2 back off
            %check deconvolution success on one pixel
            f3 = figure;
            hold on
            plot(squeeze(img(20,20,:)))
            plot(squeeze(deconvimg(20,20,:)),'g')
            hold off
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
            ncut = 20; %# of trials to cut due to deconvolution cutting off end
            trials=size(img,3)-ncut; %deconv cuts off last trial
            deconvimg = deconvimg(:,:,1:trials);
        else
            load([pathname2 '\WFD_' filename ]);%'.mat'
        end
        alldeconvimg(f,:,:,:)= deconvimg; 
    %% Create Cicle ROI Around Window
        
        dfof_bgAlignSTDdcv = std(deconvimg,[],3);
        f4 = figure; set(f4, 'Position', get(0, 'Screensize'));
        imagesc(dfof_bgAlignSTDdcv); axis equal; hold on;
        % Check if previous files exists, use Pre points if on a post file
        if mod(f,2)==1
           if ~exist(fullfile(pathname,files(use(f)).darknessdata)) || realign
                display('click on diameter of ring (4 points)');
              %  'Pick 4 points around the head plate.'
                clear dx dy
                for i = 1:4
                    [dy(i) dx(i)] = ginput(1);
                    plot(dy(i),dx(i),'g*');
                end
               save((fullfile(pathname,files(use(f)).darknessdata)),'dx','dy');
            else
                load(fullfile(pathname,files(use(f)).darknessdata))
            end
        else
            load(fullfile(pathname,files(use(f-1)).darknessdata))
        end
        % Creates region of intrest around brain
        [xc, yc, R,a] = circfit(round(dy'),round(dx'));
        % Draws Circle on plot
        Createcircle(xc,yc,R);
        % Creates a Meshgrid and finds points inside circle, sets equal to 1
        % and points outside equal to 0.
        ExtractPart = zeros(size(deconvimg(:,:,1)));
        [x1, y1] = meshgrid(1:size(ExtractPart,2),1:size(ExtractPart,1));
        xgrid=(x1-xc); ygrid=(y1-yc);
        x1 = xgrid; y1=ygrid;
        ExtractPart(((x1).^2 +(y1).^2) < R.^2) = 1;
        % Uncomment to view area extracted
        % imagesc(dfof_bgAlignSTDdcv.*(ExtractPart));
        UnfoldExtract = reshape(ExtractPart,size(ExtractPart,1)*size(ExtractPart,2),1); %1d Unfolded Extract Matrix
        UnfoldExtract2 = repmat(UnfoldExtract,1,size(deconvimg,3)); % 2d Unfoled Extract matrix for movies
        UnfoldIm = reshape(deconvimg,size(deconvimg,1)*size(deconvimg,2),size(deconvimg,3)); % Unfolded movie
        %% Frequency Processing
        Fs = 10;    % Sampling Frequency
        FreqRange = [0 1;1 5]; % nx2 matrix, where column 1 is min freq. column2 is max. n is the number of frequency bins
        % Running frequency filtering and Power spectrum
        [PSD1, Freq1, FiltData1] = Calc_PSD(UnfoldIm,UnfoldExtract,Fs,FreqRange(1,:),1,1);
        [PSD2, Freq2, FiltData2] = Calc_PSD(UnfoldIm,UnfoldExtract,Fs,FreqRange(2,:),3,1);
        %% Optimal Frequency Plot
        f5 =figure; set(f5, 'Position', get(0, 'Screensize')); subplot(1,2,1);
        imagesc(dfof_bgAlignSTD2); axis equal; axis off; title('Standard Deviation Map');
        freq1ba = find(Freq1 >= .2 ); % find optimal frequencies above .2 Hz
        PSD1temp = PSD1./(max(max(PSD1(:,freq1ba)))); %max(max(PSD1));%
        [~,maxInt1] = max((PSD1temp(:,freq1ba)),[],2);
        ReIm1 = reshape(Freq1(maxInt1+freq1ba(1)),size(deconvimg,1),size(deconvimg,2)); %put image back together
        subplot(1,2,2);
        h = imagesc(ReIm1.*ExtractPart); c1= colorbar; caxis([.2 5]); c1.Label.String = 'Frequency (Hz)'; axis equal; axis off;
        title('Optimal Frequency');
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %% Fourier Amplitude
        % Finding frequency bins in data
        freq1b = find(Freq1 >= FreqRange(1,1) & Freq1 < FreqRange(1,2));
        freq2b = find(Freq2 >= FreqRange(2,1) & Freq2 < FreqRange(2,2));
        imrange1 = [0 1];
        f6 =figure; set(f6, 'Position', get(0, 'Screensize')); colormap jet; subplot(1,3,1); imagesc(dfof_bgAlignSTD2); axis equal; axis off;
        title('Standard Deviation Map');
        PSD1temp = PSD1./(max(max(PSD1(:,freq1b)))); %max(max(PSD1));%
        ReIm1 = reshape(max(PSD1temp,[],2),size(deconvimg,1),size(deconvimg,2));
        subplot(1,3,2);
        imagesc(ReIm1.*ExtractPart,imrange1);c1= colorbar; axis equal; axis off; caxis([0 1]); c1.Label.String = 'Amplitude ';
        title('0-1 Hz Frequency Bin')
        PSD2temp = PSD2./(max(max(PSD2(:,freq2b)))); %max(max(PSD1));%
        ReIm2 = reshape(max(PSD2temp,[],2),size(deconvimg,1),size(deconvimg,2));
        imrange2 = [0 1]; subplot(1,3,3); %colormap jet;
        imagesc(ReIm2.*ExtractPart,imrange2);c2= colorbar; axis equal; axis off; caxis([0 1]); c1.Label.String = 'Amplitude';
        title('1-5 Hz Frequency Bin'); hold off;
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %%  Correlation Analysis
        Corrval1 = pixelCC(FiltData1.*UnfoldExtract2,1);
        Corrval2 = pixelCC(FiltData2.*UnfoldExtract2,1);
        
        
        %% K Means Clustering
        
        [idx1, C1] = kmeans(Corrval1,5);
        [idx2, C2] = kmeans(Corrval2,5);
        f6 =figure; set(f6, 'Position', get(0, 'Screensize')); subplot(2,3,2);
        imagesc(dfof_bgAlignSTD); axis equal; axis off;
        subplot(2,3,4);
        imagesc(reshape(idx1,size(deconvimg,1),size(deconvimg,2))); axis equal; axis off;
        
        title('0-1 Hz Frequency Clusters');
        subplot(2,3,5);
        imagesc(reshape(idx2,size(deconvimg,1),size(deconvimg,2))); axis equal; axis off;
        title('1-5 Hz Frequency Clusters');
        
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %%
        disp('Temporal Cross Correlation')
        [lagVals0,Coeff0,Alag,ACoeff]= TemporalXC(UnfoldIm.*UnfoldExtract2,1);
        %%
        stdImg = dfof_bgAlignSTD;
        %%% grid points for analysis ...
        if ~exist('npts','var'); npts=0; end
        %%% if points weren't loaded in, then select
        if npts ==0;
            npts = input('number of points to select (0=auto grid) : ')
            if npts>0 %%% manually select points
                figure
                imagesc(stdImg,[0 0.1]); colormap jet
                hold on
                for i = 1:npts
                    [y(i) x(i)] = ginput(1);
                    plot(y,x,'g*')
                end
                x=round(x); y= round(y);
            else %%% auto select points on grid
                gridspace = input('grid spacing : ');
                clear x y ptstd
                for xi = gridspace:gridspace:size(img,1);
                    for yi = gridspace:gridspace:size(img,2);
                        npts = npts+1;
                        x(npts)=xi; y(npts)=yi;
                        ptstd(npts) = stdImg(xi,yi);
                    end
                end
                npts = sum(ptstd>0.015); x = x(ptstd>0.015); y= y(ptstd>0.015);
                
                %%% remove points you don't want ...
                figure
                imagesc(stdImg,[0 0.1]); colormap gray; hold on
                plot(y,x,'g*')
                done = 0;
                while ~done
                    [yi xi b] = ginput(1);
                    if b==3
                        done=1;
                    else
                        ind = find(x==round(xi)&y==round(yi));
                        if ~isempty(ind)
                            x=x(setdiff(1:length(x),ind)); y = y(setdiff(1:length(y),ind));
                        else
                            x = [x round(xi)]
                            y= [y round(yi)]
                        end
                        hold off
                        imagesc(stdImg,[0 0.1]); colormap gray; hold on
                        plot(y,x,'g*')
                    end
                end
                npts = length(y);
            end
        end
        allStdImgDS(f,:,:) = stdImg; %std map all animals, downsampled
        allStdImg(f,:,:) = dfof_bgAlignSTD2; %not downsampled
        allImgDS(f,:,:,:) = dfof_bgAlignDS; %downsampled, no mean subracted
        allImgAmpDS(f,:,:,:)= dfof_bgAlignDS2;%downsampled, mean subtracted 

        figure
        imagesc(stdImg,[0 0.1]); colormap gray; hold on
        plot(y,x,'g*')
        title([files(use(f)).expt ' ' files(use(f)).cond]);
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%
        clear useTime obs_im obs_im_all allObs_im
        obsr = reshape(img,size(img,1)*size(img,2),size(img,3));
        sigcol = reshape(dfof_bgAlignSTD,size(img,1)*size(img,2),1);
        % useTime = sp>10;
        %%% only use stationary times .... sp<10, for running sp>10
        useTime(:,1) = sp<10; %0 = stationary, 1 = mv
        useTime(:,2) = sp>10;
        obsr(sigcol<0.01,:)=0;  %%% remove pts with low variance to select brain from bkground
        
        for mv = 1:2
            obs = obsr(:,useTime(:,mv));
            obsAllT = obsr;
          %%% PCA
          
            if ~isempty(obs(useTime(:,mv)))
            [coeff score latent] = pca(obs');
            
            %%% show loading of PCA components
            figure
            plot(1:10,latent(1:10)/sum(latent))
            xlabel('component'); ylabel('latent')
            
            %%% plot 24 spatial components ... these make pretty pictures, not sure
            %%% what to do with them!
            figure
            for i = 1:18
                subplot(3,6,i);
                range = max(abs(coeff(:,i)));
                imagesc(reshape(coeff(:,i),size(img,1),size(img,2)),[-range range])
                % hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
            end
            if mv == 1
                title(sprintf('%s_%s_%s_stat',files(use(f)).expt,files(use(f)).cond));
            else
                title(sprintf('%s_%s_%s_mv',files(use(f)).expt,files(use(f)).cond));
            end
            if exist('psfilename','var')
                set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                print('-dpsc',psfilename,'-append');
            end
            
            %%% timecourse of first 5 temporal components
            figure
            for i = 1:5
                subplot(5,1,i);
                plot(score(:,i)); axis off
            end
            
            %%% plot speed versus temporal compoenents ..
            if exist('sp','var') && sum(sp~=0)
                figure
                subplot(3,1,1)
                plot(sp(useTime(:,mv))); ylabel('speed')
                subplot(3,1,2);
                plot(score(:,1)); ylabel('component1')
                subplot(3,1,3)
                plot(sp(useTime(:,mv))/max(sp(useTime(:,mv))),'g'); hold on; plot(score(:,1)/max(score(:,1)));
                
                if mv == 1
                    title(sprintf('%s_%s_%s_stationary',files(use(f)).expt,files(use(f)).cond));
                else
                    title(sprintf('%s_%s_%s_mv',files(use(f)).expt,files(use(f)).cond));
                end
                if exist('psfilename','var')
                    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
                    print('-dpsc',psfilename,'-append');
                end
                
                for i = 1:3
                    figure
                    plot(-120:0.1:120,xcorr(sp(useTime(:,mv)),score(:,i),1200,'coeff'));
                    %   title('sp comp1 xcorr'); xlabel('secs'); ylim([-0.5 0.5])
                    %   set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
                end
            end
         %else
              %  coeff = NaN; score = NaN; latent = NaN; %does this skip over for ALL sessions if one is empty??
        %end
        %%% subtract off first pca component (global signal)
        tcourse = coeff(:,1)*score(:,1)' ; %+ coeff(:,2)*score(:,2)' + coeff(:,4)*score(:,4)';
        obs = obs-tcourse;
        obs_im = reshape(obs,size(img(:,:,useTime(:,mv))));  %%% in x, y, t
        obs_im_all = reshape(obsAllT,size(img(:,:,1:length(obsr))));
        %%% calculate correlation coeff matrix for whole frame
        cc = corrcoef(obs');
        %%% plot timecourse for selected points after decorrelation (aka removal of first pca component)
        figure; hold on
        clear decorrTrace traceCorr
        for i = 1:npts
            decorrTrace(:,i) = squeeze(obs_im(x(i),y(i),:));
            % plot(decorrTrace(:,i)+0.1*i)%,col(i));
        end
        
        %%% correlation coefficient of selected points
        traceCorr = corrcoef(decorrTrace);
        % traceCorr(traceCorr<=0)=0.01;
        
        %%% convert correlation coeffs back into matrix
        cc_im = reshape(cc,size(img,1),size(img,2),size(img,1),size(img,2));
        decorrSig = std(obs_im,[],3);
        
        maxim = prctile(img,95,3); %%% 95th percentile makes a good background image
        
        %%% plot clustered points with connectivity, only contralateral (across midline) connections
        % clustcol = 'wgrcmyk'; %%% color scheme for clusters
        
        %%
        figure
        imagesc(maxim) ; colormap gray; axis equal
        hold on
        clear dist contra
        for i = 1:npts
            for j= 1:npts
                dist(i,j) = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
                contra(i,j) = (x(i)-size(img,2)/2) * (x(j)-size(img,2)/2) <0 & ~(x(i)==33) & ~(x(j)==33) ; %%% does it cross the midline
                if traceCorr(i,j)>0.75 && contra(i,j)
                    plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.6),'Color','b');
                    plot(y,x,'.y');
                end
            end
        end
        axis ij
        axis equal
        if mv == 1
            title(sprintf('%s_%s_%s_stationary',files(use(f)).expt,files(use(f)).cond));
        else
            title(sprintf('%s_%s_%s_mv',files(use(f)).expt,files(use(f)).cond));
        end
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        %%%
        figure
        imagesc(maxim) ; colormap gray; axis equal
        hold on
        for i = 1:npts
            for j= 1:npts
                if traceCorr(i,j)>0.75 && dist(i,j) > gridspace*2 &&~contra(i,j)
                    plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.5),'Color','b')
                    plot(y,x,'.y');
                end
            end
        end
        axis ij
        axis equal
        if mv == 1
            title(sprintf('%s_%s_%s_stationary',files(use(f)).expt,files(use(f)).cond));
        else
            title(sprintf('%s_%s_%s_mv',files(use(f)).expt,files(use(f)).cond));
        end
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %%
        decorrTraceAll{use(f)} =  decorrTrace;
     %  alldecorrTrace(f,:,:)= decorrTrace;
        corrAll(f,:,:,mv) = traceCorr;
        dist = dist(:); distAll(:,f) = dist;
        traceCorr = traceCorr(:);
        contra = contra(:); contraAll(:,f) = contra;
        allObs_im(f,:,:,:) = obs_im_all;
        
        %%% plot mean correlation as a function of distance
        distbins = gridspace/2:gridspace:60;
        for i = 1:length(distbins)-1;
            meanC(i) = nanmean(traceCorr(dist>distbins(i) & dist<=distbins(i+1) & ~contra));
        end
        meanC(i+1) = nanmean(traceCorr(contra & dist>2*gridspace));
        figure
        bar(meanC)
        xlabel('distance'); ylabel('correlation')
        if mv == 1
            title(sprintf('%s_%s_%s_stationary',files(use(f)).expt,files(use(f)).cond));
        else
            title(sprintf('%s_%s_%s_mv',files(use(f)).expt,files(use(f)).cond));
        end
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
        
        %%% scatter plot of correlation vs distance for all points
        figure
        hold on
        plot(dist(contra),traceCorr(contra),'r*')
        plot(dist(~contra),traceCorr(~contra),'o');
        xlabel('distance'); ylabel('correlation')
        legend('contra','ipsi');
        if mv == 1
            title(sprintf('%s_%s_%s_stationary',files(use(f)).expt,files(use(f)).cond));
        else
            title(sprintf('%s_%s_%s_mv',files(use(f)).expt,files(use(f)).cond));
        end
        if exist('psfilename','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfilename,'-append');
        end
            else
            end
    end
        end
   
    %%
    
    try
        dos(['ps2pdf ' psfilename ' "' [fullfile(outpathname,filename) '.pdf'] '"'])
    catch
        display('couldnt generate pdf');
    end
    delete(psfilename);
    
    %%
    save([pathname2 '\WFD_' filename '.mat'],'corrAll','npts','x','y','allObs_im','decorrTraceAll','allImgDS','allStdImgDS','ACoeff','dfof_bgAlignDS','deconvimg','lagVals0','Coeff0','ExtractPart','sp','Alag','PSD1','PSD2','FiltData1','FiltData2','Corrval1','Corrval2','Freq1','allxshift','allyshift','-v7.3')
     %else
   % num2str(use(f))
    %end
end