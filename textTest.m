clear Screen;
clear all
close all
clc

Screen('Preference', 'VisualDebugLevel', 6);
Screen('Preference', 'SuppressAllWarnings', 0);
Screen('Preference', 'Verbosity', 4);

window=Screen('OpenWindow',0);

%Screen('Preference', 'TextRenderer', 0);  % consider moving to station.startPTB
Screen('Preference', 'TextAntiAliasing', 0); % consider moving to station.startPTB
Screen('Preference', 'TextAlphaBlending', 0);

oldStyle=Screen('TextStyle', window, 0)

%Screen('TextSize',window,11);

font = 'nimbus mono l';
font = 'palladio';
font = 'fixed';
%Screen('TextFont',window,font);

%[normBoundsRect, offsetBoundsRect]= Screen('TextBounds', window, 'TEST');
Screen('DrawText',window,'hello',100,100);

oldCopyMode=Screen('TextMode', window)

oldStyleFlag = Screen('Preference', 'DefaultFontStyle')
oldfontName = Screen('Preference', 'DefaultFontName')

Screen('Flip',window);
KbWait;
sca