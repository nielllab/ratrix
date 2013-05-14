function [dfof responseMap responseMapNorm] = readTifBaseline(in);
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

choosePix =0; %%% option to manually select pixels for timecourse analysis
maxGB = 0.5; %%% size to reduce data down to

%%%for xy=1:2 option to combine x and y maps
for xy=1

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
basename = in(1:end-5)

[out frameT idx pca_fig]=readSyncMultiTif(basename,maxGB);


psfilename = [basename '.ps']
if exist(psfilename,'file')==2;delete(psfilename);end

figure(pca_fig)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
    

blue=1; green=2; split=3;
for LED=1:3
    frms = 1:size(out,3);
    if LED==blue
        LEDfrms = find(idx==blue);
        LEDout = interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap');
        LEDout = shiftdim(LEDout,1);
        m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
        dfof{LED} = (double(LEDout)-m)./m;
        clear m
    elseif LED==green
        LEDfrms = find(idx==green);
        LEDout = interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap');
        LEDout = shiftdim(LEDout,1);
        m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
        dfof{LED} = (double(LEDout)-m)./m;
        clear m
    elseif LED==split
        dfof{LED} = dfof{blue}-dfof{green};
    end
    
    movPeriod =10;
    binning=0.25;
    framerate=10;
    img = out(:,:,1);
    
    [map cycMap fullMov] =phaseMap(dfof{LED},framerate,movPeriod,binning);
    map(isnan(map))=0;
    mapFig(map)
    
    stepMap = zeros(size(cycMap,1),size(cycMap,2),3);
    stepMap(:,:,1) = mean(cycMap(:,:,26:50),3)-mean(cycMap(:,:,10:25),3);
    stepMap(:,:,2)= mean(cycMap(:,:,76:100),3)-mean(cycMap(:,:,60:75),3);
    
    figure
    imshow(imresize(stepMap,4)./prctile(stepMap(:),99));
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');
    
    
    if xy==1
        xyMap = zeros(size(cycMap,1),size(cycMap,2),4);
        xyMap(:,:,1) = mean(cycMap(:,:,26:50),3)-mean(cycMap(:,:,1:25),3);
        xyMap(:,:,2)= mean(cycMap(:,:,76:100),3)-mean(cycMap(:,:,51:75),3);
    else
            xyMap(:,:,3) = mean(cycMap(:,:,26:50),3)-mean(cycMap(:,:,1:25),3);
        xyMap(:,:,4)= mean(cycMap(:,:,76:100),3)-mean(cycMap(:,:,51:75),3);
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
            plot(squeeze(cycMap(x,y,:))); ylim([-0.03 0.03]);
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

clear in
end %%% xy

%%% option to combine x and y maps
% shapeMap = reshape(xyMap,size(xyMap,1)*size(xyMap,2),4);
% outReshape = zeros(size(shapeMap,1),3);
% [val peakchan] = max(shapeMap,[],2);
% outReshape(peakchan==1,1)=val(peakchan==1);
% outReshape(peakchan==2,1)=0.5*val(peakchan==2);
% outReshape(peakchan==2,2)=0.5*val(peakchan==2);
% outReshape(peakchan==3,2)=val(peakchan==3);
% outReshape(peakchan==4,3)=val(peakchan==4);
% 
% outXY= reshape(outReshape,size(xyMap(:,:,1:3)));
% figure
% imshow(outXY*30);

ps2pdf('psfile', psfilename, 'pdffile', [psfilename(1:(end-2)) 'pdf']);
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
        imshow(polarMap(mapIn));
        %     imagesc(angle(mapIn))
        %     colormap(hsv)
        
        subplot(2,2,4)
        plot(mapIn(:),'.','MarkerSize',2)
        axis(1.5*[-ampMax ampMax -ampMax ampMax])
        axis square
    end
end


