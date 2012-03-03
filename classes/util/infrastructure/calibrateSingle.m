function calibrateSingle
n = 200;
duration = .03;
gap = .25;
accuracy = .1;

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(fileparts(pathstr))),'bootstrap'));
setupEnvironment;

input('hit enter to prime the ports (get all bubbles out of lines)')
portTest;
clc

start = input('\nenter the water level (ml)\n');
calibrateLocal( n, [0 duration 0], gap, accuracy );
stop = input('\nenter the water level (ml)\n');

rate = 10*(start - stop)/(duration*n); % ul/10ms
fprintf('volume per 10ms was %gul\nthat means 2ml in 150 rewards needs %dms each\n',rate,round((2*10^4)/(150*rate)));
end