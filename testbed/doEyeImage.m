w = Screen('OpenWindow', 1)
Eyelink('Verbosity', 7)
PsychEyelinkDispatchCallback(w) 
status = Eyelink('Initialize', 'PsychEyelinkDispatchCallback')

result = Eyelink('ImageModeDisplay')
result = Eyelink('WaitForModeReady', 10)
mode = Eyelink('CurrentMode')

result = Eyelink('StartSetup')
result = Eyelink('WaitForModeReady', 10)
mode = Eyelink('CurrentMode')

status = Eyelink('DriftCorrStart', 30, 30)
result = Eyelink('WaitForModeReady', 10)
mode = Eyelink('CurrentMode')

result = Eyelink('StartSetup',1)

status = Eyelink('DriftCorrStart', 30, 30, 1)

status = Eyelink('DriftCorrStart', 30, 30, 1, 1, 1)

pause
Eyelink('Shutdown'); 
sca;