% the stimulus isolator is essentially a current source, battery powered so it is electrically isolated from electrical noise that could harm tissue.
% it takes TTL command signals (0/+5V voltages) into its serial port, and outputs a specific current over its banana plugs output.
% because it is a current source, the output current is supposed to be relatively independent of the resistance over which it is pushing the current.
% 
% first check the battery level on the stimulus isolator: set power to off, push battery/test button. light should come on.
% you don't want to be connected to AC, so charge up if necessary.
% rechargable batteries can be ruined by certain charging practices, so see the manual for whether you need to recharge fully, etc.
% 
% manually verify that you get expected current over a ~1k resistor:
% 	hook up the stim isolater (still not plugging into control cable) so that it will push the current over the resistor. 
% 	put the multimeter in series with the resistor (be sure you're using the small current input on the multimeter, NOT the volt
% 	on front panel of stimulus isolator, set baseline to 0, range to 10ua, pulse to .1, so that's 1ua
% 
% hook up serial and parallel breakout cards to map pins [2 3 4] parallel to [4 8 9] serial (on the stimulus isolator these mean "gate", "sign", "pulse baseline")
% also hook up pins [any 18-25] parallel to [3 and 7] serial (these are the TTL ground lines)
%
% don't plug the cable into the stimulus isolator until you have made sure to initialize the pins to zero on the parallel port (see below).
% 
% during the actual experiment, watch your multimeter current reading to make sure you got what you wanted.
% also make sure the stimulus isolator's error light never goes on (which would most likely mean that the resistance it encountered was too high).
% 
% where millisecond-accurate timing is important, most people would use a (eg grass) stimulator, rather than a comptuer, to provide the stimulus isolator with precisely timed control signals.
% http://www.grasstechnologies.com/products/stimulators/stimulators.html
%
% to output TTL signals from matlab:
% navigate to ratrix trunk\classes\util\parallelPort

addr='0378'; %find parallel port address in device manager
vals='00000111';  %8 binary digits, corresponding to output pins [9 8 7 6 5 4 3 2] on the parallel port -- verify mapping w/multimeter!
		  %'00000111' should mean "do a positive pulse"
dur=1; %pulse duration in seconds


GetSecs;WaitSecs(0.1); %load these psychtoolbox mex routines into memory (avoids timing error in next call) -- note that matlab's pause command is inaccurate
lptwrite(hex2dec(addr), bin2dec('00000000')); %initialize the pins (seem to boot into undefined states)
disp('starting')
lptwrite(hex2dec(addr), bin2dec(vals));
time=GetSecs();
timeDone= WaitSecs('UntilTime', time+dur);
lptwrite(hex2dec(addr), bin2dec('00000000'));
disp(sprintf('gave pulse for %g secs',timeDone-time)) %actual value may be different than requested