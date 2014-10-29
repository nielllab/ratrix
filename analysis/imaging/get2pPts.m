function pts = get2pPts(img,dfofInterp);
clear dfof imgInterp

mn = mean(dfofInterp,3);
sigma = std(dfofInterp,[],3);


mn = mean(img,3);

range = [prctile(mn(10:10:end),2) prctile(mn(10:10:end),99)]
mapfig = figure
imagesc(mn, range);
colormap(gray)
hold on

dfReshape = reshape(dfofInterp,[size(dfofInterp,1)*size(dfofInterp,2),size(dfofInterp,3)]);
npts=0; done=0; clear pts
coverage=zeros(size(dfofInterp,1)*size(dfofInterp,2));
while ~done
    [y x b] = ginput(1);
    if b==3 %%% right click
        done = 1;
        break
    elseif b ==1
        npts =npts+1;
        pts(npts,1)=round(x);
        pts(npts,2)=round(y);
        plotdata(npts) = plot(round(y),round(x),'g*'); plotdata2(npts) = plot(round(y),round(x),'bo');
   
      cc=0;
    for f= 1:size(dfofInterp,3);
        cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(:,:,f)-mn);
    end
    cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma);
    figure
    imagesc(cc,[-1 1]);
    
    w=12;
    xmin=max(1,x-w); ymin=max(1,y-w);
    xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
    figure
   roi = cc; roi(1:xmin-1,:,:)=0; roi(:,1:ymin-1,:)=0; roi(xmax+1:end,:,:)=0; roi(:,ymax+1:end,:)=0;
   imagesc(roi,[0 1]);
    usePts{nPts} = find(roi>0.9);
    dF(nPts,:) = squeeze(mean(dfReshape(usePts{nPts},:),1));
    coverage(usePts{nPts})=nPts;
   
    
    
    elseif b==32 %%% spacebar
        delete(plotdata(npts)); delete(plotdata2(npts))
        npts=npts-1;    
    end
    
    
end

figure

imagesc(reshape(coverage,[size(dfofInterp,1) size(dfofInterp,2)]));
