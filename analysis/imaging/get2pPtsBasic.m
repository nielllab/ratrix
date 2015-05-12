function [pts dF] = get2pPts(dfofInterp);
%%% uses dfof images to collect rois for analysis
%%% identifies all nearby pixels that are correlated with selected point

%%% select points using left click, delete last selection with spacebar
%%% and quit with a right click
%%% cmn 11/14, based on concepts from D. Ringach and S. Smith

 w=12;  %%% size of window for ROI
 corrThresh=0.75; %%% threshold for 

%%% use stdev as reference image to select points
%%% GC6 expressing cells have difference stdev from background
sigma = std(dfofInterp,[],3);
mapfig = figure
imagesc(imresize(sigma,2),[0 2])
hold on

dfReshape = reshape(dfofInterp,[size(dfofInterp,1)*size(dfofInterp,2) size(dfofInterp,3)]);
npts=0; done=0; clear pts usePts dF
coverage=zeros(size(dfofInterp,1)*size(dfofInterp,2),1);
while ~done
    figure(mapfig)
    [y x b] = ginput(1); x= round(x/2); y=round(y/2);
    if b==3 %%% right click = finished
        done = 1;
        break
    elseif b ==1  %%% left click = select point
        npts =npts+1;
        pts(npts,1)=round(x);
        pts(npts,2)=round(y);
        plotdata(npts) = plot(round(y)*mag,round(x)*mag,'g*'); plotdata2(npts) = plot(round(y)*mag,round(x)*mag,'bo');
       
        %%% calculate window boundaries
        xmin=max(1,x-w); ymin=max(1,y-w);
        xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
        
        %%% calculate correlation
        cc=0;
        for f= 1:size(dfofInterp,3);
            cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
        end
        cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));
        if npts==1
            cellfig=figure;
        else
            figure(cellfig);
        end
   
        roi = zeros(size(sigma));
        roi(xmin:xmax,ymin:ymax) =cc;
        
       %%% show correlation values on full image field
       subplot(2,2,1);
        imagesc(roi,[0 1]);
        axis equal
        
        %%% show selected pixels and get dF
        subplot(2,2,2);
        imagesc(roi>corrThresh); axis equal
        usePts{npts} = find(roi>corrThresh);
        dF(npts,:) = squeeze(mean(dfReshape(usePts{npts},:),1));
        coverage(usePts{npts})=npts;
        
        %%% zoom in of cc in window
        subplot(2,2,3);
        imagesc(cc,[0 1]);
        
    elseif b==32 %%% spacebar
        delete(plotdata(npts)); delete(plotdata2(npts))
        npts=npts-1;
    end
    
end

figure
plot(dF')

c = 'rgbcmk'
figure
hold on
for i = 1:npts;
    plot(dF(i,50:1250)/max(dF(i,:)) + i/2,c(mod(i,6)+1));
end


