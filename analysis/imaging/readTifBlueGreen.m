function dfof  = readTifBlueGreen(in);
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all


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

multiTif=1; %%% multi tif = lots of tif files
choosePix =0;

psfilename = [in '.ps']
if exist(psfilename,'file')==2;delete(psfilename);end


if multiTif
    [out frameT]=readMultiTif(in(1:end-5));
else
    try
        intf = [in '.tif'];
        info = imfinfo(intf);
        n = length(info);
    end
    
    mf = [in '.mat'];
    if exist(mf,'file')
        disp('loading .mat')
        tic
        out = load(mf);
        toc
        out = out.out;
    else
        disp('loading tiff')
        tic
        out = arrayfun(@(x)imread(intf,x,'Info',info),1:n,'UniformOutput',false); %can't read "subimages" (see detailedTif())
        % for multi-image TIFF, providing 'Info' speeds up read
        toc
        
        disp('reformatting')
        tic
        out = cell2mat(reshape(out,[ones(1,2) n]));
        toc
        
        disp('saving .mat')
        tic
        save(mf,'out','-v7.3'); %compresses to half the size, far faster to load, may need to set -v7.3 so can exceed 2GB
        toc
    end
    
    b = whos('out');
    disp(['movie is ' num2str(b.bytes/1000/1000/1000) ' GB'])
    
    try
        frameT=readStamps(out);
    end
    
    %rect = [950 600 500 650]; %left top width height
    %rect = [950 450 800 900];
    %rect = [1 1 500 100];
    
    plotTags = true;
    if plotTags
        u = [info.UnknownTags];
        if ~all([u.ID]==50495)
            error('unexpected unknown tag id')
        end
        v = [u.Value]';
        i = find(any(diff(v)));
        k = length(i);
        h = [];
        
        figure
        for j=1:k
            h(end+1) = subplot(k,1,j);
            plot(v(:,i(j)))
            title(['byte ' num2str(i(j))])
        end
        xlabel('frame')
        linkaxes(h,'x');
        
        if ~all(ismember(i,[15 17    19    20    21    22  23 453   454   455]))
            i
            warning('unexpected byte variability')
        end
    end
    
    if false
        doDetailed = false;
        if doDetailed
            frames = detailedTif(intf);
        else
            figure
            colormap gray
            stampHeight = 10;
            imagesc(mean(double(out(stampHeight:end,:,:)),3));
            axis equal
            title('select ROI by dragging mouse, double click on it when done')
            h = imrect('PositionConstraintFcn',makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'))); %also consdier rbbox, dragrect, getrect, others?
            rect = round(wait(h)) + [0 stampHeight 0 0]; %left top width height %top, not bottom, cuz imagesc
        end
        out = out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),:);
    end
    
    sizestruct = whos('out');
    shrinkfactor = 0.75*10^9 / sizestruct.bytes
    if shrinkfactor<1
        out = out(:,:,1:floor(shrinkfactor*size(out,3)));
    end
    size(out)
    
    out = out(:,:,101:end);  %%% avoid transients of first cycle
    %out = doNormalize(out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),:));
    
    %out = out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),:);
    %keyboard
    % for f=1:size(im,3)
    % out= imresize(out(:,:,f),binning,'box');
    % end
    
end

shrunkdata = out(10:10:end,10:10:end,:);

shrunkdata = reshape(shrunkdata,[size(shrunkdata,1)*size(shrunkdata,2) size(shrunkdata,3)]);

[coeff score latent] = princomp(double(shrunkdata)');
figure
plot(latent);

size(score)


idx = kmeans(score(:,1),2);

if sum(idx==2)>sum(idx==1);
    bl = find(idx==2); gr= find(idx==1);
else
    bl = find(idx==1); gr = find(idx==2);
end
bl = bl(abs(zscore(score(bl)))<5); gr = gr(abs(zscore(score(gr)))<5);
figure
hold on
plot(score(:,1),score(:,2),'ko');
plot(score(bl,1),score(bl,2),'bo');
plot(score(gr,1),score(gr,2),'go');

    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    

blue=1; green=2; split=3;
for LED=1:3
    frms = 1:size(out,3);
    if LED==blue
        LEDfrms = bl;
        LEDout = interp1(LEDfrms,shiftdim(double(out(:,:,LEDfrms)),2),frms,'linear','extrap');
        LEDout = shiftdim(LEDout,1);
        m = repmat(mean(double(LEDout),3),[1 1 size(LEDout,3)]);
        dfof{LED} = (double(LEDout)-m)./m;
        clear m
    elseif LED==green
        LEDfrms = gr;
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
    
    
    
    
    t0 = linspace(1,size(cycMap,3),10);
    figure
    for t = 1:9;
        subplot(3,3,t);
        imagesc(squeeze(mean(cycMap(:,:,t0(t):t0(t+1)-1),3)),[-0.02 0.02]);
        colormap(gray);
    end
    
    map = map-mean(map(:));
    mapFig(map)
    
    
    
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


