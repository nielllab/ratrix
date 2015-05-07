function [x y] = getAxonPts(dfofInterp,greenframe)
stdImg = std(dfofInterp,[],3);
filt = fspecial('gaussian',5,1);
stdImg = imfilter(stdImg,filt);
region = ones(5,5); region(3,3)=0;
maxStd = stdImg > imdilate(stdImg,region);
pts = find(maxStd);
figure
plot(stdImg(pts),greenframe(pts),'.')

greenThresh = 200
stdThresh = 0.75
done=0
while ~done 
    pts = find(maxStd);
    figure
    plot(greenframe(pts),stdImg(pts),'.')
    
    pts = pts(stdImg(pts)>stdThresh & greenframe(pts)>greenThresh);
    length(pts)
    [x y] = ind2sub(size(stdImg),pts);
    
    sz = size(stdImg,1);
    buffer=10;
    
    y = y(x<sz-buffer); x= x(x<sz-buffer);
    y=y(x>buffer); x= x(x>buffer);
    x = x(y>buffer); y = y(y>buffer);
    x = x(y<sz-buffer); y = y(y<sz-buffer);
       
    figure
    imagesc(greenframe,[0 prctile(greenframe(:),95)]);
    hold on; colormap gray; plot(y,x,'*');
    figure
    imagesc(stdImg,[0 prctile(stdImg(:),95)]);
    hold on; colormap gray; plot(y,x,'*');
    done = input('okay points ? (0/1) :')
    if ~done
        stdThresh = input ('std thresh : ');
        greenThresh = input ('green thresh : ')
    end
end
