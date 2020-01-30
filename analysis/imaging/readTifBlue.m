function [dfof responseMap responseMapNorm cycMap frameT] = readTifBlue(in, rigzoom,fl);
% [pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
% addpath(fullfile(fileparts(pathstr),'bootstrap'))
% setupEnvironment;
in
dbstop if error
colordef white
close all
movPeriod =10;
binning=0.5;
framerate=10;

choosePix =0; %%% option to manually select pixels for timecourse analysis
maxGB = 16*binning.^2; %%% size to reduce data down to
binning=1;

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


if in(end-6)=='_' & in(end-5)=='0'
    basename=in(1:end-7);
elseif in(end-4)=='_' & in(end-3)=='0'
    basename=in(1:end-5);
else
    basename=in;
end
try
    sz = size(imread([basename '_000001.tif']));
    namelength=6;
catch
    sz = size(imread([basename '_0001.tif']));
    namelength=4;
end
basename
clear in
if ~exist('fl','var')
    fl=0;
end
%flip image? 1 = yes 0 = no


[out frameT idx pca_fig]=readSyncMultiTif_BlueEA(basename,maxGB,fl,namelength, rigzoom);


psfilenameFinal = [basename '.ps'];
psfilename = 'F:\temp2.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

figure
plot(diff(frameT));
ylabel('frame dt')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

figure(pca_fig)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');



blue=1; green=2; split=3;
figure
plot(idx);
for LED=1:1
    frms = 1:size(out,3);
    if LED==blue
        LEDfrms = find(idx==blue);
        tic
        LEDout = double(interp1(LEDfrms,shiftdim(single(out(:,:,LEDfrms)),2),frms,'linear','extrap'));
        toc
        LEDout = shiftdim(LEDout,1);
        m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
        dfof{LED} = (double(LEDout)-m)./m;
        clear m
    elseif LED==green
        LEDfrms = find(idx==green);
        tic
        LEDout = double(interp1(LEDfrms,shiftdim(single(out(:,:,LEDfrms)),2),frms,'linear','extrap'));
        toc
        LEDout = shiftdim(LEDout,1);
        m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
        dfof{LED} = (double(LEDout)-m)./m;
        clear m
    elseif LED==split
        dfof{LED} = dfof{blue}-dfof{green};
        
        
    end
    
    img = out(:,:,1);
    dx=25;
    if LED==blue | LED==green
        pix = LEDout(dx:dx:end,dx:dx:end,:);
        figure
        plot(reshape(pix,size(pix,1)*size(pix,2),size(pix,3))')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    clear pix
    
    
    [rawmap rawcycMap fullMov] =phaseMap(dfof{LED},framerate,movPeriod,binning);
    rawmap(isnan(rawmap))=0;
    mapFig(rawmap)
    
    if LED==split
        tic
        
        %% decon before averaging
%                 [map preCycMap fullMov] =deconPhaseMapPre(dfof{LED},framerate,movPeriod,binning);
%                    map(isnan(map))=0;
%                    mapFig(map)
        
        [map cycMap fullMov] =deconPhaseMap(dfof{LED},framerate,movPeriod,binning);
        preCycMap = cycMap;
        toc
        map(isnan(map))=0;
        mapFig(map)
    else
        map = rawmap;
        cycMap = rawcycMap;
    end
    
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
    imshow(imresize(stepMap,1/binning)./prctile(stepMap(:),99));
    %     set(gcf, 'PaperPositionMode', 'auto');
    %     print('-dpsc',psfilename,'-append');
    
    
    
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
        
        if LED==split
            plot(squeeze(preCycMap(x,y,:))-min(squeeze(preCycMap(x,y,:))),'k');
            hold on
            plot(squeeze(cycMap(x,y,:))--min(squeeze(cycMap(x,y,:))));
            plot(squeeze(rawcycMap(x,y,:))-min(squeeze(rawcycMap(x,y,:))),'g'); ylim([0 0.25]);
        else
            plot(squeeze(cycMap(x,y,:))); ylim([-0.125 0.125]);
        end
        
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

dos(['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-2)) 'pdf"'])
if exist([psfilenameFinal(1:(end-2)) 'pdf'],'file')
    ['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-2)) 'pdf"']
    display('generated pdf using dos ps2pdf')
else
    try
        ps2pdf('psfile', psfilename, 'pdffile', [psfilenameFinal(1:(end-2)) 'pdf'])
        [psfilenameFinal(1:(end-2)) 'pdf']
        display('generated pdf using builtin matlab ps2pdf')
    catch
        display('couldnt generate pdf');
        keyboard
    end
end

delete(psfilename);

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
        imshow(polarMap(mapIn,94));
        %     imagesc(angle(mapIn))
        %     colormap(hsv)
        
        subplot(2,2,4)
        plot(mapIn(:),'.','MarkerSize',2)
        axis(1.5*[-ampMax ampMax -ampMax ampMax])
        axis square
    end
end


