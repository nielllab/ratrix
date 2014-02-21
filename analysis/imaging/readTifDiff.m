function [dfof responseMap responseMapNorm] = readTifDiff(in);
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

framerate = input('acquistion framerate : ');
movPeriod = input('stimulus period (usually 5 or 10 secs): ');


choosePix =1; %%% option to manually select pixels for timecourse analysis
maxGB = 0.5; %%% size to reduce data down to
imcolor= {'green','red'};

for chan=1:2
    if ~exist('in','var') || isempty(in)
        
        [f,p] = uigetfile({'*.tif'; '*.tiff'; '*.mat'},sprintf('choose %s pco data',imcolor{chan}));
        %'C:\Users\nlab\Desktop\macro\real\'
        %[f,p] = uigetfile('C:\Users\nlab\Desktop\data\','choose pco data');
        if f==0
            out = [];
            return
        end
        
        [a b] = fileparts(fullfile(p,f));
        in = fullfile(a,b);
        
    end
    try
       basename = in(1:end-7);
       sz = size(imread([basename '_000001.tif']));
    namelength=6;
    catch
               basename = in(1:end-5);
       sz = size(imread([basename '_0001.tif']));
    namelength=4;
    end
    clear in
    if chan==1
        fl = 1;
    else
        fl=0;
    end;
    [data frameT idx pca_fig]=readSyncMultiTif(basename,maxGB,fl,namelength);
    data = double(data);
    mn = mean(data,3);
    figure
    imagesc(mn); colormap(gray);
    figure
    plot(diff(frameT)*1000);
    title(sprintf('channel %d',chan))
    display('normalizing to mean');
    LEDout{chan}=data;
    if chan==1;
        LEDout{3}=data;
    end
    for f=1:size(data,3);
        data(:,:,f)=(data(:,:,f)-mn)./mn;
    end
    dfof{chan}=data; clear data;
end

%%% perform spatial realignment???


psfilename = [basename '.ps']
if exist(psfilename,'file')==2;delete(psfilename);end

figure
plot(diff(frameT));
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

figure(pca_fig)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');



blue=1; green=2; split=3;
for LED=1:3
    if LED==split   %%% any combination of chan 1 & 2 that you want!
        %dfof{LED} = (1/0.36)*dfof{green}-dfof{blue}; %%%
        % dfof{LED} = dfof{green}-dfof{blue};  %%% ratio
        dfof{3} = zeros(size(dfof{1}));
        for i = 1:size(dfof{green},1);
            i
            for j=1:size(dfof{green},2);
                [c s] = princomp([squeeze(dfof{1}(i,j,:)) squeeze(dfof{2}(i,j,:))]);
                dfof{3}(i,j,:) =s(:,2);
            end
        end
    end
    
    
    
    dx=25;
    if LED==blue | LED==green
        pix = LEDout{LED}(dx:dx:end,dx:dx:end,:);
        figure
        plot(reshape(pix,size(pix,1)*size(pix,2),size(pix,3))')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    
    out =dfof{LED};
    
    binning = 1/16;
    img = out(:,:,1);
    
    [map cycMap fullMov] =phaseMap(dfof{LED},framerate,movPeriod,binning);
    map(isnan(map))=0;
    mapFig(map)
    
    binMov{LED}=fullMov;  %%% binned version of dfof for each channel
    
    responseMap{LED}=map;  %%% polar map for each channel
    
    %%% dfof timecourse
    t0 = linspace(1,size(cycMap,3),10);
    figure
    for t = 1:9;
        subplot(3,3,t);
        imagesc(squeeze(mean(cycMap(:,:,t0(t):t0(t+1)-1),3)),[-0.02 0.02]);
        colormap(gray);
    end
    
    map = map-mean(map(:));
    mapFig(map)
    
    responseMapNorm{LED}=map;
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% option to normalize to a defined region
    %%% we don't use this
    normalize=0;
    if normalize
        mapfig=figure
        imshow(polarMap(map),'InitialMagnification','fit');
        colormap(hsv);
        colorbar
        axis on
        [x y] = ginput(2)
        %keyboard
        submap = map(y(1):y(2),x(1):x(2));
        figure
        imshow(polarMap(submap))
        map=map-mean(submap(:));
        mapFig(map);
    end
    
    
    done=0;
    
    cycMapAll{LED} = cycMap;  %%% cycle averaged binned movie for 3 channels
    
    %%% compute movie around stim onset
    if LED==3
        
        timescale = (1:size(cycMapAll{1},3))/framerate;
        baseline = mean(cycMapAll{3}(:,:,round((movPeriod/2 + (-0.2:0.02:0.1))*framerate)),3);
        moviepoints = -0.5:(1/framerate):1;
        
        figure
        for i = 1:length(moviepoints);
            if framerate<=10
                subplot(4,4,i)
            elseif framerate<=30
                subplot(6,8,i)
            elseif framerate<=60
                subplot(8,12,i)
            end
            imagesc(cycMapAll{3}(:,:,round((movPeriod/2 + moviepoints(i))*framerate))-baseline,[-1 5]*10^-3);
            if i==1; title(sprintf('framerate %dmsec',round(1000/framerate))); end
            axis off
            
        end
        
        %%%display blood vessel map and evoked activity map
        figure
        subplot(1,2,1)
        imagesc(squeeze(LEDout{1}(:,:,1)))
        colormap(gray); axis equal; axis off
        freezeColors
        subplot(1,2,2)
        imagesc(cycMapAll{3}(:,:,round((movPeriod/2 + 0.3)*framerate))-cycMapAll{3}(:,:,round((movPeriod/2+0.1)*framerate)))
        colormap(jet); axis equal; axis off
    end
    
    
    if LED==3; %%% select pixels and plot timecourse
        
        %%% map of response right after stimulus in 3 channels
        figure
        for i=1:3
            respmap(:,:,i) = cycMapAll{i}(:,:,round((movPeriod/2 + 0.3)*framerate))-cycMapAll{i}(:,:,round((movPeriod/2+0.1)*framerate))
            subplot(2,2,i);
            imagesc(respmap(:,:,i),[-5 5]*10^-3);
        end
        
        %%% difference map, used for selecting points
        mapfig=figure;
        imagesc(respmap(:,:,3))
        
        %%% select map points for pixel analysis
        npts=0
        while ~done
            figure(mapfig)
            if choosePix
                [y x b] = ginput(1);
                if b==3 %%%% right click
                    done=1;
                    break;
                end
            elseif ~choosePix
                done=1;
                
                [m max_ind]= max(abs(map(:)))
                [x y] = ind2sub(size(map),max_ind);
            end
            npts=npts+1;
            y = round(y); x= round(x);
            figure
            
            %%% timecourse for this pixel
            subplot(2,2,1)
            plot(squeeze(fullMov(x,y,:)));
            xlim([0 length(fullMov)]);
            
            %%% red vs green for this pixel, plus regression
            subplot(2,2,2);
            plot(squeeze(binMov{1}(x,y,:)),squeeze(binMov{2}(x,y,:)),'.');
            [r m b] = regression(squeeze(binMov{1}(x,y,:))',squeeze(binMov{2}(x,y,:))')
            title(sprintf('r=%0.2f m=%0.2f b=%0.2f',r,m,b));
            
            %%% cycle avg timecourse for 3 channels
            axis equal
            subplot(2,2,3);
            timescale = (1:size(cycMapAll{1},3))/framerate;
            % plot(squeeze(cycMap(x,y,:))); ylim([-0.125 0.125]);
            plot(timescale,squeeze(cycMapAll{1}(x,y,:)),'g');hold on
            plot(timescale,squeeze(cycMapAll{2}(x,y,:)),'r'); plot(timescale,squeeze(cycMapAll{3}(x,y,:)),'k');
             plot(timescale,squeeze(cycMapAll{2}(x,y,:))- squeeze(cycMapAll{1}(x,y,:)),'y');  %%%diff
            ylim([-0.01 0.01]);
            
            %%% time frequency analysis
            subplot(2,2,4);
            params.Fs = framerate;
            params.tapers = [2 3];
            params.fpass = [0 framerate/2-1];
            [S t f] = mtspecgramc(squeeze(cycMapAll{3}(x,y,:)),[0.5 0.1],params);
            imagesc(S',[0 prctile(S(:),85)]);
            axis xy
            xlabel('frames');
            ylabel('hz')
            
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
            resp(npts,:) = squeeze(mean(mean(respmap(x-1:x+1,y-1:y+1,:),2),1));
            for i = 1:3;
                d= respmap(x-1:x+1,y-1:y+1,i);
                resp_std(npts,i)=std(d(:))/length(d(:));
            end
            resp
            resp_std
            
            %%% time frequency for entire recording duration at this pixel
            figure
            subplot(1,2,1)
            params.Fs = framerate;
            params.tapers = [2 3];
            params.fpass = [0 framerate/2-1];
            [S t f] = mtspecgramc(squeeze(binMov{3}(x,y,:)),[3 1],params);
            imagesc(S',[0 prctile(S(:),90)]);
            axis xy
            subplot(1,2,2);
            plot(f,mean(S,1));
            
            
            gr= squeeze(binMov{1}(x,y,:)); red = squeeze(binMov{2}(x,y,:)); rgdiff= squeeze(binMov{3}(x,y,:));
            frqs = (1:length(gr))/(length(gr)/framerate);
            
            %%% FFT of raw red/green
            figure
            [c s] = princomp([gr  red]);
            subplot(2,2,1)
            plot(frqs,abs(fft(gr))'.*(1:length(gr)),'g'); hold on; plot(frqs,abs(fft(red))'.*(1:length(gr)),'r');
            
            xlim([0 frqs(end)/2])
            
            %%% FFT of PCA components
            subplot(2,2,2); hold on
            plot(frqs,abs(fft(s(:,1))'.*(1:length(gr))),'b');
            plot(frqs,abs(fft(s(:,2))'.*(1:length(gr))),'g');
            xlim([0 frqs(end)/2])
            
            
            %%%% timecourse of 3 components
            subplot(2,2,3);
            plot(cycAvgSig(gr,framerate*movPeriod),'g');
            hold on
            plot(cycAvgSig(red,framerate*movPeriod),'r');
            plot(squeeze(cycMapAll{3}(x,y,:)),'k');
            
            %%% timecourse of 2 PCA components
            c = 'bg';
            subplot(2,2,4);
            for i = 1:2
                sig = cycAvgSig(s(:,i),framerate*movPeriod);
                plot(timescale,sig/max(abs(sig)),c(i));
                hold on
            end
            
        end
    end
    
end  %%%LED

meanresp=mean(resp,1)
resp_err=mean(resp_std,1)

datafilename=[psfilename(1:end-3) 'resp2.mat'];
save(datafilename,'meanresp','resp_err', 'cycMapAll');



ps2pdf('psfile', psfilename, 'pdffile', [psfilename(1:(end-2)) 'pdf']);
delete(psfilename);  

    function mapFig(mapIn)
        figure
        
        subplot(2,2,1)
        imagesc(squeeze(LEDout{LED}(:,:,1)))
        colormap(gray); axis equal
        freezeColors
        
        subplot(2,2,2);
        ampMax = prctile(abs(mapIn(:)),90);
        imagesc(abs(mapIn),[0 ampMax])
        colormap(gray)
        colorbar
        
        subplot(2,2,3)
        imshow(polarMap(mapIn));
        %     imagesc(angle(mapIn))
        %     colormap(hsv)
        
        subplot(2,2,4)
        plot(mapIn(:),'.','MarkerSize',2)
        axis(1.5*[-ampMax ampMax -ampMax ampMax])
        axis square
    end
end


