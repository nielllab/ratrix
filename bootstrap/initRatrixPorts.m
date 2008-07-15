function st=initRatrixPorts(mac)
id='99Z';
width=1280;
height=1024;
path=fullfile('Stations','DefaultStation');
screenNum=int8(0);
macAddr=mac;
macLoc=int8([1 1 1]); % [rackID shelf position]
st=station(...
            id,...          %id
            width,...       %width
            height,...      %height
            path,...        %path
            screenNum,...   %screenNum
            true,...       %soundOn
            'localTimed',...%rewardMethod
            macAddr,...     %MACaddress
            macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
... %           int8(3));             %numPorts   %wrong constructor!
            '0378',...      %parallelPortAddress
            'parallelPort',...%responseMethod
            int8([6,7,8]),... %valveOpenCodes
            int8([4,2,3]),... %portCodes
            int8(1));       %framePulseCodes
currentValveStates=verifyValvesClosed(st)