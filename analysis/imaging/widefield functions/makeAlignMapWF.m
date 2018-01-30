%%%manual align to create a map based on doTopography
%%%for full skull, set y0=round(size(img,2)*(3/5)) in shiftImageRotate
close all; clear all
batchPhilIntactSkull %select batch file

%select which subset of animals to use
use = find(strcmp({files.notes},'good darkness and stimulus') | strcmp({files.notes},'good darkness'))
sprintf('%d experiments for individual analysis',length(use)/2)

alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography

for s=1:1 %needed for doTopography
    doTopography; %%%align across animals second
end

img = avgmap;
satisfied=0;
while satisfied~=1 %rotate
    figure;
    imshow(img*10)
    title('select back then front')
    [y x] = ginput(2);
    x=round(x);y=round(y);

    theta = -rad2deg(atan((x(1)-x(2))/(y(2)-y(1))));

    img2 = imrotate(img,theta,'crop');
    
    figure;imshow(img2*10)
    
    satisfied = input('satisfied? 1=f*&$ yea!, 0=plz no: ');
end

avgmap = img2;
avgmap4d = imrotate(avgmap4d,theta,'crop');

save('referenceMapFullSkull.mat','avgmap4d','avgmap')
