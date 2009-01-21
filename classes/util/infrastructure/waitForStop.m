function waitForStop(x)
s=psychportaudio('getstatus',x);
while s.Active
    s=psychportaudio('getstatus',x);
end