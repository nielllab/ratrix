function setupMice
[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(pathstr)),'bootstrap'));
setupEnvironment

%names = {'3350'};
%names = {'test','j10lt','j10ln','j8lt','j8ln'};
%names = {'test','j10rt','j8rt','j7rt','j6rt'};

%names = {'c2rt','c1rt'};
%names = {'c2rn','c1rn'};
%names = {'3691'};
names = {'c4rt','c5rt','c4rn','c5rn'}

lab = 'niell'

switch lab
    case 'wehr'
        ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
        p = 'setProtocolWehr';
    case 'niell'
        ratrixPath = 'C:\Users\nlab\Desktop\mouseData0512';
        p = 'setProtocolAbstOrient';
    otherwise
        error('huh?')
end

for i=1:length(names)
    standAloneRun(ratrixPath,p,names{i},[],[],true)
end

end