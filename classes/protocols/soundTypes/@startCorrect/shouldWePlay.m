function [play] = shouldWePlay(st,portSet, framesElapsed)
% returns TRUE if we should play this sound, FALSE otherwise
% plays the 'correctSound' if we are at the beginning of the phase (no frames elapsed)

play = 0;
if framesElapsed == 1
    play = 1;
end

