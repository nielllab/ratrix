w = Screen('OpenWindow', 0, 0, [0 0 650 500]); 
PsychEyelinkDispatchCallback(w); 
%status = Eyelink('InitializeDummy', 'PsychEyelinkDispatchCallback');
status = Eyelink('Initialize', 'PsychEyelinkDispatchCallback'); 
Eyelink('Shutdown'); 
sca;