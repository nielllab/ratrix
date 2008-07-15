function isGood=checkRecording(et)

if Eyelink('IsConnected')
    %good
    isGood=1;
else
    eyeERR = Eyelink('CheckRecording')
    error(sprintf('lost connection with eye tracker: %s',eyeERR))
end


