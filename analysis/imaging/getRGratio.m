%%% open pairs of r/g images for each butterfly line to get ratio
done=0;
while ~done
    bfly = input('which line: ');
    
    if bfly<=0
        done=1;
        break
    end
    
    [f p ] = uigetfile('*.tif','green image');
    im_gr = imread(fullfile(p,f));
        [f p ] = uigetfile('*.tif','red image');
    im_red = imread(fullfile(p,f));
    figure
    imagesc(im_gr); colormap(gray);
    select_done=0;
    npts=0;
    red=[]; green=[]; range = -5:5;
    while ~select_done
        npts=npts+1;
                       [y x b] = ginput(1);
                       x=round(x); y= round(y);
                if b==3 %%%% right click
                    select_done=1;
                    break;
                end
                green(npts)=mean(mean(im_gr(x+range,y+range)));
                red(npts)=mean(mean(im_red(x+range,y+range)));
    end
    
    red
    green
    rgratio(bfly) = mean(red./green);
    rgerror(bfly) = std(red./green)/sqrt(npts);
    exp(bfly) = input('exposure duration: ');
    green = green/exp(bfly);
    gr_bright(bfly) = mean(green);
    gr_bright_std(bfly) = std(green)/sqrt(npts);
    
end

figure
rgratio(3)=0/0;
bar(rgratio);
hold on
errorbar(1:length(rgratio),rgratio,rgerror,'o');
xlabel('bfly line'); ylabel('r/g ratio');

figure
gr_bright(3)=0/0;
bar(gr_bright);
hold on
errorbar(1:length(rgratio),gr_bright,gr_bright_std,'o');
xlabel('bfly line'); ylabel('green brightness');
                
                