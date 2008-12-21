function testsound
clear mex
clear psychportaudio

p=maxpriority('getsecs');
priority(p);
initializepsychsound(1);
try
    x=psychportaudio('open',[],[],4); %doesn't work with asio4all + enhanced dll
catch ex
    ple(ex)
    x=psychportaudio('open');
end
psychportaudio('fillbuffer',x,rand(2,40000)-.5);
getsecs;
psychportaudio('start',x);
psychportaudio('stop',x);

for i=1:10
    y=getsecs;
    psychportaudio('start',x);
    s=getsecs-y;
    pause(.5);
    y=getsecs;
    psychportaudio('stop',x,2);
    t=getsecs-y;
    fprintf('%g\t%g\n',s,t)
end

psychportaudio('close')

x=audioplayer(rand(2,40000)-.5,44100);
for i=1:10
    y=getsecs;
    play(x);
    s=getsecs-y;
    pause(.5);
    y=getsecs;
    stop(x);
    t=getsecs-y;
    fprintf('%g\t%g\n',s,t)
end
priority(0);