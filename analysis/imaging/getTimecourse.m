close all
clear all
batchBehavNew;

alluse = find(strcmp({files.monitor},'vert')&  strcmp({files.notes},'good imaging session')  &    strcmp({files.label},'camk2 gc6') &  strcmp({files.task},'HvV_center') &strcmp({files.spatialfreq},'100') & strcmp({files.subj},'g62b7lt'))
subj=unique({files(alluse).subj})

f = alluse(1);

load([pathname files(f).topox],'map','cycle_mov')
if exist('cycle_mov','var')
    cycMap = cycle_mov;
end

map = map{3};

mapfig=figure
imshow(polarMap(map),'InitialMagnification','fit');
colormap(hsv);
colorbar
done=0;
axis on


while ~done
    figure(mapfig)
        [y x b] = ginput(1)
        if b==3 %%%% right click
            done=1;
            break;
        end

    y = 2*round(y); x= 2*round(x);
   
    figure
    
    subplot(2,1,1);
    plot(squeeze(cycMap(x,y,:))); ylim([-0.1 0.1]);
 
    subplot(2,1,2);
    imshow(polarMap(map,95),'Initial
    Magnification','fit');
 
    hold on
    plot(y,x,'w*');
   
end
