function setupMice
%names = {'3350'};
%names = {'test','j10lt','j10ln','j8lt','j8ln'};
%names = {'test','j10rt','j8rt','j7rt','j6rt'};

%names = {'c2rt','c1rt'};
%names = {'c2rn','c1rn'};
names = {'c1rt'};

lab = 'wehr';

switch lab
    case 'wehr'
        ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
        p = 'setProtocolWehr';
    case 'niell'
        ratrixPath = 'C:\Users\nlab\Desktop\mouseData0512';
        p = 'setProtocolCMN';
    otherwise
        error('huh?')
end

for i=1:length(names)
    standAloneRun(ratrixPath,p,names{i},[],[],true)
end

end