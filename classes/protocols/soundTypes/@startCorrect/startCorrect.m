function st=startCorrect(duration)
% startCorrect  class constructor. 
% This soundType plays the 'correctSound' at beginning of the Correct phase
% Does not care about port responses
if ~isscalar(duration)
    error('duration must be a scalar');
end

a = soundType('correctSound', duration);
st.name = 'correctSound'; %name of the sound clip as a string
st.duration = duration; %number of ms to play this clip (as an argument to playLoop) - 0 = repeat forever (in case of no sound)

st = class(st, 'startCorrect', a);

st = setSuper(st, st.soundType);
