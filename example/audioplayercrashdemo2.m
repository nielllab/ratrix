function audioplayercrashdemo
clc
p=audioplayer(rand(1,10*44100),44100);
for i=1:9999
    play(p)
    waitsecs(.00005)
    stop(p)
end