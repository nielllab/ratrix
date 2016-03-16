function [pts dF neuropil ptsfname] = get2pPtsManual(dfofInterp, greenframe);
%%% manually select cell bodies for analysis by clicking
%%% based on selected points, uses local cross-correlation to choose ROI
%%% After cell bodies are selected, choose 5 neuropil points for subtraction
mn = mean(dfofInterp,3);
sigma = std(dfofInterp,[],3);

figure
imagesc(sigma,[0.2 0.8])

mag=2;
mapfig = figure
imagesc(imresize(sigma,mag),[0 1.5])
hold on

dfReshape = reshape(dfofInterp,[size(dfofInterp,1)*size(dfofInterp,2) size(dfofInterp,3)]);
npts=0; done=0; clear pts usePts dF
coverage=zeros(size(dfofInterp,1)*size(dfofInterp,2),1);
while ~done
    figure(mapfig)
    [y x b] = ginput(1); x= round(x/2); y=round(y/2);
    if b==3 %%% right click
        done = 1;
        break
    elseif b ==1
        npts =npts+1;
        pts(npts,1)=round(x);
        pts(npts,2)=round(y);
        plotdata(npts) = plot(round(y)*mag,round(x)*mag,'g*'); plotdata2(npts) = plot(round(y)*mag,round(x)*mag,'bo');
        w=12; corrThresh=0.75; neuropilThresh=0.5;
        xmin=max(1,x-w); ymin=max(1,y-w);
        xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
        
        cc=0;
        for f= 1:size(dfofInterp,3);
            cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
        end
        cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));
        if npts==1
            cellfig=figure
        else
            figure(cellfig);
        end
       
        roi = zeros(size(sigma));
        roi(xmin:xmax,ymin:ymax) =cc;
        
        subplot(2,2,1);
        imagesc(roi,[0 1]);
        axis equal
        
        subplot(2,2,2);
        imagesc(roi>corrThresh); axis equal
        usePts{npts} = find(roi>corrThresh);
        dF(npts,:) = squeeze(mean(dfReshape(usePts{npts},:),1));
        coverage(usePts{npts})=npts;
        
        subplot(2,2,3);
        imagesc(cc,[0 1]);
        
    elseif b==32 %%% spacebar
        delete(plotdata(npts)); delete(plotdata2(npts))
        npts=npts-1;
    end
    
end

figure
imagesc(reshape(coverage,[size(dfofInterp,1) size(dfofInterp,2)]));

clear neuropilDF
for i = 1:5
    doneNeuropil=0;
    while ~doneNeuropil
        figure(mapfig); hold on
        plot(round(y)*2,round(x)*2,'ro');
        [y x b] = ginput(1); x= round(x/2); y=round(y/2);
        cc=0;
        for f= 1:size(dfofInterp,3);
            cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(:,:,f)-mn);
        end
        cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma);
        figure
        imagesc(cc,[-1 1]);
        figure
        imagesc(cc>neuropilThresh);
        [y2 x2 b] = ginput(1)
        if b==1
            doneNeuropil =1;
        end
    end
    neuroPts{i} = find(cc>0.5);
    neuropilDF(i,:) = squeeze(mean(dfReshape(neuroPts{i},:),1));
    
end

neuropil = mean(neuropilDF,1)

figure
plot(dF')

c = 'rgbcmk'
figure
hold on
for i = 1:npts;
    plot(dF(i,50:1250)/max(dF(i,:)) + i/2,c(mod(i,6)+1));
end

c = 'rgbcmk'
figure
hold on
for i = 1:npts;
    plot((dF(i,50:1250)-neuropil(50:1250))/max(dF(i,:)) + i/2,c(mod(i,6)+1));
end

c = 'rgbcmk'
figure
hold on
for i = 1:npts;
    plot((dF(i,50:1250)-neuropil(50:1250)) + i,c(mod(i,6)+1));
end

c = 'rgbcmk'
figure
hold on
for i = 1:5;
    plot(neuropilDF(i,50:1250)/max(neuropilDF(i,:)) + i,c(mod(i,6)+1));
end

[f p] = uiputfile('*.mat','save points data');
save(fullfile(p,f),'pts','dF','neuropil','coverage','greenframe');
ptsfname = fullfile(p,f);


