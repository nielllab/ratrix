function [dfof responseMap responseMapNorm] = readTifAxons(in);
%%% an attempt to merge axons at level of readTiff
%%% need to unmix on raw fluorescence (otherwise can't get df on unknown
%%% baseline
%%% how will this affect blue/green subtraction?
%%% both will be equally affected, so after separation calculate dF/F then
%%% subtract off green reflectance
%%% how to deal with dF/F in areas with low expression? set threshold for
%%% abs level?
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

%framerate = input('acquistion framerate : ');
%movPeriod = input('stimulus period (usually 5 or 10 secs): ');
framerate = 10; movPeriod=10;

choosePix =0; %%% option to manually select pixels for timecourse analysis
maxGB = 1; %%% size to reduce data down to
binning = 0.5;
imcolor= {'green','red'};

selectFiles=1;
for chan=1:2
    if selectFiles || ~exist('in','var') || isempty(in)
        
        [f,p] = uigetfile({'*.tif'; '*.tiff'; '*.mat'},sprintf('choose %s pco data',imcolor{chan}));
        %'C:\Users\nlab\Desktop\macro\real\'
        %[f,p] = uigetfile('C:\Users\nlab\Desktop\data\','choose pco data');
        if f==0
            out = [];
            return
        end
        
        [a b] = fileparts(fullfile(p,f));
        a
        b
        
        in{chan} = fullfile(a,b);
        
    else
        %%% need to set up 2 autonames
    end
end
for chan=1:2
   sprintf('doing channel %d',chan)
   try
        basename = in{chan}(1:end-7);
        sz = size(imread([basename '_000001.tif']));
        namelength=6;
    catch
        basename = in{chan}(1:end-5);
        sz = size(imread([basename '_0001.tif']));
        namelength=4;
    end
   
    if chan==1
        fl = 0;
    else
        fl=0;
    end;
    [out frameT idx pca_fig]=readSyncMultiTif(basename,maxGB,fl,namelength);
 size(out)
 rangex = (-100:99) + round(size(out,1)/2);
 rangey = (-100:99) + round(size(out,2)/2);
 if chan==1
      out=  out(rangex,rangey,:);
  else
      out=  out(rangex-1,rangey+2,:);
  end
   mn = mean(out,3);
    figure
    imagesc(mn); colormap(gray); title(sprintf('channel %d',chan))
    figure
    plot(diff(frameT)*1000);
    title(sprintf('channel %d',chan))
    blue=1; green=2;
    display('interpolating ...')
    tic
    frms=1:size(out,3);
    LEDfrms = find(idx==blue);
    LEDout = double(interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap'));
    bluedata{chan} = shiftdim(LEDout,1);
    
    LEDfrms = find(idx==green);
    LEDout = double(interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap'));
    greendata{chan} = shiftdim(LEDout,1);
    clear out LEDout
    mn = mean(greendata{chan},3);
    for f = 1:size(greendata{chan},3)
        greendF{chan}(:,:,f) = (greendata{chan}(:,:,f)-mn) ./mn;
    end
    toc
end
frms = 10:(size(greendata{1},1)-10)
mn = zeros(length(frms),length(frms),3);
mn(:,:,1) = greendata{1}(frms,frms,4)/max(max(greendata{1}(:,:,4)));
mn(:,:,2) = greendata{2}(frms,frms,4)/max(max(greendata{2}(:,:,4)));
mn(:,:,3)=0;
figure
imshow(mn)

%%% perform spatial realignment???
display('doing subtraction')

bluemin = min(min(bluedata{1}(:,:,2)))
bluedata{1} = bluedata{1}-min(min(bluedata{1}(:,:,2)));
bluemin = min(min(bluedata{2}(:,:,2)))
bluedata{2} = bluedata{2}-min(min(bluedata{2}(:,:,2)));
figure
imagesc(mean(bluedata{2}./bluedata{1},3),[0 5]); title('red / green');

alpha = [1 -1]; beta =[-1/2.4 1/.75];
figure
for chan = 1:2
    unmix{chan} = alpha(chan)*bluedata{1} + beta(chan)*bluedata{2};
    unmix{chan}(unmix{chan}<0) = 0;
    mn = mean(bluedata{chan},3);
    subplot(2,2,chan); imagesc(bluedata{chan}(:,:,1),[0 prctile(mn(:),99)]); axis square; 
    mn = mean(unmix{chan},3);
    subplot(2,2,chan+2); imagesc(unmix{chan}(:,:,1),[0 prctile(mn(:),99)]); colormap gray;axis square ;
    
    peak = prctile(mn(:),99.5);
    amp{chan} = mn/peak; amp{chan}(amp{chan}>1)=1;
    
   usemap{chan} = mn>(0.1*peak);
    for f = 1:size(unmix{chan},3);
        dfof{chan}(:,:,f) = (unmix{chan}(:,:,f)-mn)./mn;
    end
    dfof{chan} = dfof{chan} - greendF{chan};
    for f = 1:size(unmix{chan},3)
        dfof{chan}(:,:,f) = dfof{chan}(:,:,f).* amp{chan};
    end
end
% figure
% for chan=1:2
% subplot(2,1,chan)
% imagesc(usemap{chan})
% end



psfilename = [basename '.ps']
if exist(psfilename,'file')==2;delete(psfilename);end

figure
plot(diff(frameT));
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

figure(pca_fig)
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');



gfp=1; flav =2; split=3;
for LED=1:2
    
    
    
    dx=25;
    
    pix = unmix{LED}(dx:dx:end,dx:dx:end,:);
    figure
    plot(reshape(pix,size(pix,1)*size(pix,2),size(pix,3))')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    
    out =dfof{LED};
    
    
    img = out(:,:,1);
    
    [map cycMap fullMov] =phaseMap(dfof{LED},framerate,movPeriod,binning);
    map(isnan(map))=0;
    mapFig(map)
    
    binMov{LED}=fullMov;  %%% binned version of dfof for each channel
    
    responseMap{LED}=map;  %%% polar map for each channel
    
    %%% dfof timecourse
%     t0 = linspace(1,size(cycMap,3),10);
%     figure
%     for t = 1:9;
%         subplot(3,3,t);
%         imagesc(squeeze(mean(cycMap(:,:,t0(t):t0(t+1)-1),3)),[-0.02 0.02]);
%         colormap(gray);
%     end
    
%     map = map-mean(map(:));
%     mapFig(map)
%     
    responseMapNorm{LED}=map;
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    
    done=0;
    
    cycMapAll{LED} = cycMap;  %%% cycle averaged binned movie for 3 channels
    
%     mapfig=figure
%     imshow(polarMap(map),'InitialMagnification','fit');
%     colormap(hsv);
%     colorbar
    done=0;
    
    
    while ~done
        
        if choosePix
           figure(mapfig)
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
        if LED==1
            range = [-0.125 0.125];
        else
            range = [-0.05 0.05];
        end
        
            plot(squeeze(cycMap(x,y,:))); ylim(range);

        subplot(2,2,4);
        imshow(polarMap(map),'InitialMagnification','fit');
        colormap(hsv);
        colorbar
        hold on
        plot(y,x,'w*','Markersize',8);
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end  %%%LED

try
ps2pdf('psfile', psfilename, 'pdffile', [psfilename(1:(end-2)) 'pdf']);
catch
    display('cant do pdf')
end
delete(psfilename);

    function mapFig(mapIn)
        figure
        
        subplot(2,2,1)
        imagesc(squeeze(unmix{LED}(:,:,1)))
        colormap(gray); axis equal
        freezeColors
        
        subplot(2,2,2);
        ampMax = prctile(abs(mapIn(:)),90);
        ampMax = max(ampMax,10^-5);
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


