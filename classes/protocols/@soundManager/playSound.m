%due to a bug in matlab, you have to keep a reference to the audio player
%that implements the sound playing.  if you don't keep a reference, it gets
%garbage collected before it's done playing.  so keep the soundmanager i
%pass back til you don't want the sound to play anymore; it contains the
%reference.
function sm=playSound(sm,soundName,duration,station)
sm=playSnd(sm,soundName,duration,station,0);