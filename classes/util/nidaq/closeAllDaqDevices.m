function closeAllDaqDevices
existingDevices=daqfind;
for i=1:length(existingDevices)
    delete(existingDevices(i));
end
clear existingDevices