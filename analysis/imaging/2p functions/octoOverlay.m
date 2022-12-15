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
 
    for ax = 1:2
        for rep = 1:2;
            subplot(2,2,2*(rep-1)+ax)
            
            if f ==1
                imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
                 hold on
            end
            if rep==1
                data = useOn;
            else data = useOff;
            end
            
            for i = 1:length(data)
                if ax ==1
                    plot(xpts(data(i)),ypts(data(i)),[cols(f) '.']);
                else
                    plot(xpts(data(i)),ypts(data(i)),[cols(f) '.']);
                end
            end
            if ax ==1 & rep==1
                title(sprintf('x0 = %0.1f y0=%0.1f',x0,y0))
            else
                title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
            end
            
        end
    end
end

    