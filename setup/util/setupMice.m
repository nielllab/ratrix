function setupMice
names = {'a','b','c'};

ratrixPath = 'C:\Users\nlab\Desktop\mouseData';
for i=1:length(names)
    standAloneRun(ratrixPath,'setProtocolMouse',names{i},[],[],true)
end
end