function [dfof responseMap responseMapNorm] = readTifDiff(in);
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

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
    basename = in(1:end-5)
    clear in
    [data frameT idx pca_fig]=readSyncMultiTif(basename,maxGB);
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
    if LED==split
        dfof{LED} = 2*dfof{green}-dfof{blue};
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
   
    movPeriod =5;
    binning=0.125;
    framerate=10;
    img = out(:,:,1);
    
    [map cycMap fullMov] =phaseMap(dfof{LED},framerate,movPeriod,binning);
    map(isnan(map))=0;
    mapFig(map)
    
    
    responseMap{LED}=map;
    
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
    
    stepMap = zeros(size(cycMap,1),size(cycMap,2),3);
%     stepMap(:,:,1) = mean(cycMap(:,:,27:30),3)-mean(cycMap(:,:,1:25),3);
%     stepMap(:,:,2)= mean(cycMap(:,:,77:80),3)-mean(cycMap(:,:,61:75),3);
    
    figure
    set(gcf,'Name','baseline map');
    imshow(imresize(stepMap,4)./prctile(stepMap(:),99));
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    
    
    mapfig=figure
    imshow(polarMap(map),'InitialMagnification','fit');
    colormap(hsv);
    colorbar
    done=0;
    
    cycMapAll{LED} = cycMap;
    
    if LED==3
    keyboard
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
     
    end
    
    
    if LED==3;
        mapfig=figure
    
        imagesc(cycMapAll{3}(:,:,round((movPeriod/2 + 0.3)*framerate))-cycMapAll{3}(:,:,round((movPeriod/2+0.1)*framerate)))
    
        
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
            
            y = round(y); x= round(x);
            figure
            subplot(2,2,1)
            plot(squeeze(fullMov(x,y,:)));
            xlim([0 length(fullMov)]);
            subplot(2,2,2);
%             spect = abs(fft(squeeze(fullMov(x,y,:))));
%             fftPts = 2:length(spect)/2;
%             loglog((fftPts-1)/length(spect),spect(fftPts));
plot(squeeze(dfof{1}(x,y,:)),squeeze(dfof{2}(x,y,:)),'.');
axis equal
            subplot(2,2,3);
            timescale = (1:size(cycMapAll{1},3))/framerate;
            % plot(squeeze(cycMap(x,y,:))); ylim([-0.125 0.125]);
            plot(timescale,squeeze(cycMapAll{1}(x,y,:)),'g');hold on
            plot(timescale,squeeze(cycMapAll{2}(x,y,:)),'r'); plot(timescale,squeeze(cycMapAll{3}(x,y,:)),'k');
            ylim([-0.01 0.01]);
            subplot(2,2,4);
%             imshow(polarMap(map),'InitialMagnification','fit');
%             colormap(hsv);
%             colorbar
%             hold on
%             plot(y,x,'*');
            params.Fs = framerate;
            params.tapers = [3 5];
            params.fpass = [0 framerate/2-1];
            [S t f] = mtspecgramc(cycMapAll{3}(x,y,:),[1 0.1],params);
            imagesc(S');
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
        
    end
    
    
    
end  %%%LED
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


