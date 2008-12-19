function testsound
clear psychportaudio
initializepsychsound(1)
x=psychportaudio('open',[],[],4)
psychportaudio('fillbuffer',x,rand(2,100))
psychportaudio('start',x);y=getsecs;psychportaudio('stop',x);getsecs-y
psychportaudio('close')