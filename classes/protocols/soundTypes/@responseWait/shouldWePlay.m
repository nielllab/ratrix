function [play] = shouldWePlay(st,portSet, framesElapsed)
% returns TRUE if we should play this sound, FALSE otherwise
% plays the 'trySomethingElseSound' if we hit a response port

play = 0;
if strcmp(portSet, 'target') || strcmp(portSet, 'distractor')
    play = 1;
end

