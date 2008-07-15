function [play] = shouldWePlay(st,portSet, framesElapsed)
% returns TRUE if we should play this sound, FALSE otherwise
% plays the 'keepGoingSound' if we hit a request port

play = 0;
if strcmp(portSet, 'request')
    play = 1;
end

