function str=soundTypeToString(soundType)
% writes info about this soundType to a string output 

str = sprintf('%s %d', getName(soundType), getDuration(soundType));
