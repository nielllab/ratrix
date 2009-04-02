%by design: you can only have one sound playing at a time
%this call will override a previously running call to playSound or playLoop.
%negative durations mean play the native clip length
function sm=playSound(sm,soundName,duration,station)
sm=doSound(sm,soundName,station,duration,false);