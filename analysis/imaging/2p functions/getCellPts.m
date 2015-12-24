function [x y] = getCellPts(stdImg,greenframe)
%%% chooses potential cell bodies based on peaks of stdImg  
%%% and threshold for raw fluorescence intensity (to avoid picking up noise)
%%%
%%% stdImg is computed by alignStdMap, currently is standard deviation of dfof
%%% but could also be something more clever

%%% find peaks in stdImg
filt = fspecial('gaussian',5,0.75);
stdImg = imfilter(stdImg,filt);
region = ones(3,3); region(2,2)=0;
maxStd = stdImg > imdilate(stdImg,region);

%%% thresholds for raw fluorescence and stdImg
greenThresh = 200
stdThresh = 0.5

%%% give user opportunity to modify thresholds based on data
done=0
while ~done
    pts = find(maxStd);
    figure
    plot(stdImg(pts),greenframe(pts),'.')
    xlabel('std'); ylabel('green')
    
    pts = pts(stdImg(pts)>stdThresh & greenframe(pts)>greenThresh);
    hold on; plot(stdImg(pts),greenframe(pts),'g.');
    
    %%% remove points at border of image 
    %%%(may not be stable across sessions due to drift)
        [x y] = ind2sub(size(stdImg),pts);
        sz = size(stdImg,1);
    buffer=15;   
    y = y(x<sz-buffer); x= x(x<sz-buffer);
    y=y(x>buffer); x= x(x>buffer);
    x = x(y>buffer); y = y(y>buffer);
    x = x(y<sz-buffer); y = y(y<sz-buffer);
    
    
    sprintf('%d points ', length(x))
    figure
    imagesc(greenframe,[0 prctile(greenframe(:),98)]);
    hold on; colormap gray; plot(y,x,'*');
    figure
    imagesc(stdImg,[0 prctile(stdImg(:),98)]);
    hold on; colormap gray; plot(y,x,'*');
    done = input('okay points ? (0/1) :')
    if ~done
        stdThresh = input ('std thresh : ');
        greenThresh = input ('green thresh : ')
    end
end
