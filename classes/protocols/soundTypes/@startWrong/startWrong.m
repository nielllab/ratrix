function st=startWrong(duration)
% startWrong  class constructor. 
% This soundType plays the 'wrongSound' at beginning of the Wrong phase
% Does not care about port responses
if ~isscalar(duration)
    error('duration must be a scalar');
end

a = soundType('wrongSound', duration);
st.name = 'wrongSount'; %name of the sound clip as a string
st.duration = duration; %number of ms to play this clip (as an argument to playLoop) - 0 = repeat forever (in case of no sound)

st = class(st, 'startWrong', a);

st = setSuper(st, st.soundType);
