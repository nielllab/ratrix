%by design: you can only have one sound playing at a time
%this call will override a previously running call to playSound.
function sm=playLoop(sm,newSound,station,keepPlaying)
sm=doSound(sm,newSound,station,keepPlaying,true);