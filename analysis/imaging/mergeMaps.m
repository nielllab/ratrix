maplist = {'G62G.1-LN_run2_TopoX_2screens_10Hz_15msexpmaps.mat','C:\data\imaging\022414 8mm window Gcamp6\G62G.1-LN_run9_whisker_stim_10Hz_3000framemaps.mat'}
img 
for c = 1:length(maplist);
load(maplist{c});
m=map{3};
if c ==1
    overlayMap = zeros(size(m,1),size(m,2),3);
end
amp = abs(m);
amp = amp/prctile(amp(:),98);
overlayMap(:,:,c)=amp;
end
