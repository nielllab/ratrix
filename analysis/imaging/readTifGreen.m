function [dfof responseMap responseMapNorm cycMap] = readTifGreen(in);
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

choosePix =0; %%% option to manually select pixels for timecourse analysis
maxGB = 1.5; %%% size to reduce data down to

if ~exist('in','var') || isempty(in)
    [f,p] = uigetfile({'*.tif'; '*.tiff'; '*.mat'},'choose pco data');
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
        fl = 0;  %flip image? 1 = yes 0 = no

[out frameT idx pca_fig]=readSyncMultiTif(basename,maxGB,fl,namelength);


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
for LED=1:1
%     frms = 1:size(out,3);
%     if LED==blue
%         LEDfrms = find(idx==blue);
%         LEDout = interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap');
%         LEDout = shiftdim(LEDout,1);
%         m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
%         dfof{LED} = (double(LEDout)-m)./m;
%         clear m
%     elseif LED==green
%         LEDfrms = find(idx==green);
%         LEDout = interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap');
%         LEDout = shiftdim(LEDout,1);
%         m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
%         dfof{LED} = (double(LEDout)-m)./m;
%         clear m
%     elseif LED==split
%         dfof{LED} = dfof{blue}-dfof{green};
%     end
LEDout = out;


    m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
    dfof{LED} =(double(LEDout)-m)./m;
    clear m
    
    dx=25;
    if LED==blue | LED==green
        pix = LEDout(dx:dx:end,dx:dx:end,:);
        figure
        plot(reshape(pix,size(pix,1)*size(pix,2),size(pix,3))')
        set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
    end
    
    movPeriod =10;
    binning=0.5;
    framerate=10;
%     framerate=20;
    
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
    stepMap(:,:,1) = mean(cycMap(:,:,26:35),3)-mean(cycMap(:,:,10:25),3);
    stepMap(:,:,2)= mean(cycMap(:,:,76:85),3)-mean(cycMap(:,:,60:75),3);
    
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
        spect = abs(fft(squeeze(fullMov(x,y,:))));
        fftPts = 2:length(spect)/2;
        loglog((fftPts-1)/length(spect),spect(fftPts));
        subplot(2,2,3);
        plot(squeeze(cycMap(x,y,:))); ylim([-0.125 0.125]);
        subplot(2,2,4);
        imshow(polarMap(map),'InitialMagnification','fit');
        colormap(hsv);
        colorbar
        hold on
        plot(y,x,'*');
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
        
        
    end
    
    
    
end  %%%LED
try
    ps2pdf('psfile', psfilename, 'pdffile', [psfilename(1:(end-2)) 'pdf']);
delete(psfilename);
catch
    display('cant save pdf')
end

    function mapFig(mapIn)
        figure
        
        subplot(2,2,1)
        imagesc(squeeze(LEDout(:,:,1)),[prctile(img(:),5) prctile(img(:),95)])
        colormap(gray)
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


