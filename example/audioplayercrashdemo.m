p=audioplayer(rand(1,10*44100),44100)
for i=1:5
    play(p)
    %pause(.0005)
    stop(p)
end