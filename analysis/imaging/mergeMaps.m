function mergemaps(map1,map2,map3,pathname,label);
maplist{1} = map1;
maplist{2}=map2;
maplist{3}=map3;


% maplist = {'visualstepmaps.mat','whiskersmaps.mat','auditory_whitemaps.mat'}
% maplist = {'visualstepmaps.mat','whiskersmaps.mat','audmovemap.mat'}
% maplist = {'visualstepmaps.mat','whiskersmaps.mat','rundark2 map.mat'}
%maplist = {'audmovemap.mat','auditory_whitemaps.mat'}%
%maplist = {'topoxmaps','topoxRunmap'}


figure

for c = 1:length(maplist);
subplot(2,2,c)
% load([pathname maplist{c}],'map');

map = maplist{c};
c
if length(map)==3
    m=map{3};
else 
    m=map;
end
if c ==1
    overlayMap = zeros(size(m,1),size(m,2),3);
end
amp = abs(m);
size(amp);
if c>1
amp = amp-prctile(amp(:),40);
else 
    amp = amp-prctile(amp(:),1);
end
amp(amp<0)=0;
amp = amp/prctile(amp(:),98);
imshow(amp);
overlayMap(:,:,c)=imresize(amp,[size(overlayMap,1) size(overlayMap,2)]);
end
subplot(2,2,4)

imshow(overlayMap)
title(label)
