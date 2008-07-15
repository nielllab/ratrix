function st=startCorrect()
% startCorrect  class constructor. 
% This soundType plays the 'correctSound' at beginning of the Correct phase
% Does not care about port responses


a = soundType('correctSound', 1000);
st.name = 'correctSound'; %name of the sound clip as a string
st.duration = 1000; %number of ms to play this clip (as an argument to playLoop) - 0 = repeat forever (in case of no sound)

st = class(st, 'startCorrect', a);

st = setSuper(st, st.soundType);
