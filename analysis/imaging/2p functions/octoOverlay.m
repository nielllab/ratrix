clear all
zthresh = 5.5

cols = 'rg';

figure
for f = 1:2
    [fn p] = uigetfile('*mat');
    fname{f} = fullfile(p,fn);
end

for f = 1:2;
    
    load(fname{f},'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','meanGreenImg')
    
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    
    if length(useOn)<3
        useOn =1:3;
    end
    if length(useOff)<3
        useOff = 1:3;
    end
    
    rfxs = [rfx(useOn,1); rfx(useOff,2)];
    rfys = [rfy(useOn,1); rfy(useOff,2)];
    x0 = nanmedian(rfxs);
    y0 = nanmedian(rfys);
    
    axLabel = {'X','Y'};
    onoffLabel = {'On','Off'};
    
    for rep = 1:2;
        subplot(1,2,rep)
        
        if f ==1
            imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
            hold on
        end
        if rep==1
            data = useOn;
        else data = useOff;
        end
        
            
            plot(xpts(data),ypts(data),[cols(f) '.']);
            

        if  rep==1
            title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
        else
            title(sprintf('%s',onoffLabel{rep}))
        end
        
    end
end
figure

cols = 'rgby'
for f = 1:2;
    
    load(fname{f},'xpts','ypts','rfx','rfy','tuning','zscore','xb','yb','meanGreenImg')
    
    use = find(zscore(:,1)>zthresh | zscore(:,2)<-zthresh);
    useOn = find(zscore(:,1)>zthresh); useOff = find(zscore(:,2)<-zthresh);
    
    if length(useOn)<3
        useOn =1:3;
    end
    if length(useOff)<3
        useOff = 1:3;
    end
    
    rfxs = [rfx(useOn,1); rfx(useOff,2)];
    rfys = [rfy(useOn,1); rfy(useOff,2)];
    x0 = nanmedian(rfxs);
    y0 = nanmedian(rfys);
    
    axLabel = {'X','Y'};
    onoffLabel = {'On','Off'};
    
    for rep = 1:2;
        
        
        if f ==1 & rep ==1
            imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
            hold on
        end
        if rep==1
            data = useOn;
        else data = useOff;
        end
        

            
            plot(xpts(data)+rand(1)*5,ypts(data)+rand(1)*5,[cols(f +2*(rep-1)) '.']);

        if  rep==1
            title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
        else
            title(sprintf('%s',onoffLabel{rep}))
        end
        
    end
end
