maplist = {'visualstepmaps.mat','whiskersmaps.mat','auditory_whitemaps.mat'}
maplist = {'visualstepmaps.mat','whiskersmaps.mat','audmovemap.mat'}
maplist = {'visualstepmaps.mat','whiskersmaps.mat','rundark2 map.mat'}
%maplist = {'audmovemap.mat','auditory_whitemaps.mat'}%
%maplist = {'topoxmaps','topoxRunmap'}



for c = 1:length(maplist);
load(maplist{c});
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
size(amp)
amp = amp/prctile(amp(:),98);
overlayMap(:,:,c)=imresize(amp,[size(overlayMap,1) size(overlayMap,2)]);
end
figure

imshow(overlayMap)
