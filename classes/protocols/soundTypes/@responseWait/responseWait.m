function st=responseWait()
% responseWait  class constructor. 
% This soundType plays the 'trySomethingElseSound' at the port = [responseOptions]
% when we are in the wait phase, and we get a response (not a request)
% Does not care about framesElapsed


a = soundType('trySomethingElseSound', 500);
st.name = 'trySomethingElseSound'; %name of the sound clip as a string
st.duration = 500; %number of ms to play this clip (as an argument to playLoop) - 0 = repeat forever (in case of no sound)

st = class(st, 'responseWait', a);

st = setSuper(st, st.soundType);
