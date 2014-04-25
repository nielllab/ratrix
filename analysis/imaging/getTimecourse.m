close all
[f p] = uigetfile('*.mat','map file');
load(fullfile(p,f));

map = map{3};

mapfig=figure
imshow(polarMap(map),'InitialMagnification','fit');
colormap(hsv);
colorbar
done=0;


while ~done
    figure(mapfig)
        [y x b] = ginput(1);
        if b==3 %%%% right click
            done=1;
            break;
        end

    y = round(y); x= round(x);
   
    subplot(2,1,1);
    plot(squeeze(cycMap(x,y,:))); ylim([0 0.25]);
 
    subplot(2,1,2);
    imshow(polarMap(map,95),'InitialMagnification','fit');
 
    hold on
    plot(y,x,'w*');
   
end
