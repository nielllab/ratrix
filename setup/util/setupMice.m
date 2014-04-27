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
%names = {'57331','57332','57751','57752' }
%names = {'50141','50142','50143'}
%names = {'82551', '82553'}
%names = {'47899' , '47800', '51008', '51009'}
%names = {'WMtest'};
%names = {'20406', '20407', '20410', '20523', '20524'}
%names = {'Phonemetest'}
%names = {'WNtest'}
%names = {'2445', '2446', '2447', '94179', '94181','94182'}
%names = {'b2445', 'b2446', 'b2447', 'b94179', 'b94181','b94182'}
%names = {'b20407', 'b20406', 'b20410', 'b20523', 'b20524'}
%names = {'20407', '20406', '20410', '20523', '20524'}
%names = {'Mtest'}
%names = {'20407'}
%names = {'Mtest2'}
%names = {'PBtest'}
%names = {'WSBtest'}
%names = {'3579', '3580', '3578', '3582'}
%names = {'70459' , '70461'}
%names = {'3813', '3814', '3815'}
%names = {'VD-47899', 'VD-51008'}
%names = {'5620', '5622'}
%names = {'TEST_LASER'}
%names= {'5917', '5919'}
%names={'PLasertest'}
names={'PMultiLasertest'}
%names={'5625MultiIntLaser'}

lab = 'wehrCNM'

switch lab
    case 'wehr'
        ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
        p = 'setProtocolWehr';
    case 'wehrCNM'
        %ratrixPath = 'C:\Users\nlab\Desktop\wehrData';
        ratrixPath = 'C:\Users\nlab\Desktop\laserData';
        p = 'setProtocolPhonemeLaserMultiInterval';
 %       p = 'setProtocolPhonemeBackup';
 %p = 'setProtocolWMStackWarbleBackup'
 %       p = 'setProtocolWMStackWarble';
 %p='setProtocolWMToneWN'
  %p = 'setProtocolWMToneWNVariableDelay'
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