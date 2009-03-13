function testsound
clear mex
clear psychportaudio

p=maxpriority('getsecs');
priority(p);
initializepsychsound(1);
try
    x=psychportaudio('open',[],[],4,[],[],4096); %reqclass 4 doesn't work with asio4all + enhanced dll
catch ex
    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
    x=psychportaudio('open',[],[],2,[],[],4096);
end
s=psychportaudio('getstatus',x);
s.SampleRate
psychportaudio('fillbuffer',x,rand(2,400000)-.5);
getsecs;

PsychPortAudio('RunMode', x, 1);

psychportaudio('start',x);
psychportaudio('stop',x);

val=true;
for i=1:10
    val=~val;
    y=getsecs;
    psychportaudio('fillbuffer',x,val*rand(2,round(2*44100*i/10))-.5);
    t=getsecs-y;
    if val
        fprintf('yes:')
    else
        fprintf('no:')
    end
    fprintf('\t%g\n',t)
end
y=getsecs;
psychportaudio('start',x);
psychportaudio('stop',x,2,0);
t=getsecs-y;
fprintf('%g\n',t)
pause
for i=1:10
    waitForStop(x);
    y=getsecs;
    psychportaudio('start',x);
    s=getsecs-y;
    pause(.5);
    y=getsecs;
    psychportaudio('stop',x,2,0);
    t=getsecs-y;
    fprintf('%g\t%g\n',s,t)
end

pause
for i=1:10
    waitForStop(x);
    y=getsecs;
    psychportaudio('start',x);
    s=getsecs-y;
    pause(.5);
    y=getsecs;
    psychportaudio('stop',x,0,0);
    t=getsecs-y;
    fprintf('%g\t%g\n',s,t)
end

psychportaudio('close')

x=audioplayer(rand(400000,2)-.5,44100);
play(x);
stop(x);
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