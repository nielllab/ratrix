function waitForStop(x)
s=psychportaudio('getstatus',x);
while s.Active
        s
    warning('when trying to start a sound, had to wait for psychportaudio to stop from previous sound -- check how recent last call to stop was')
    s=psychportaudio('getstatus',x);
end