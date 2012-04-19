function psychKeyboard

Screen('Preference', 'WindowShieldingLevel', 0);

for i=1:20
    ShowCursor; %seems to get stuck in multiple layers of hidecursor
end
ListenChar(0)
dbstack
keyboard

end