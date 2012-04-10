function setupMice
names = {'wehrTest'};
%names = {'test','j10lt','j10ln','j8lt','j8ln'};
%names = {'test','j10rt','j8rt','j7rt','j6rt'};

ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
for i=1:length(names)
    standAloneRun(ratrixPath,'setProtocolMouse',names{i},[],[],true)
    makeBatFile(names{i},ratrixPath)
end
end