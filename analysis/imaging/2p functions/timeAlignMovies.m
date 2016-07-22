

vr = VideoReader('G62EE8TT_001_004_FULL_FULL.avi');
load('G62EE8TT_001_004')
f= 0;

framerate = info.resfreq/info.sz(1)

while hasFrame(vr);
   f
   f=f+1;
    img(:,:,:,f) = readFrame(vr);
    if f>600
        break
    end
end

start = round(info.frame(1)/4)
start = start-15;
mov = immovie(uint8((double(img(:,:,:,start:start+450))- 20)*255/235));

obj = VideoWriter('G62EE8TT_001_004_snip.avi');
obj.FrameRate=15;
open(obj)
writeVideo(obj,mov);
close(obj)