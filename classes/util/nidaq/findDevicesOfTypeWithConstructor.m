function [matches]=findDevicesOfTypeWithConstructor(constructor,type)

if exist('type','var') && ~isempty(type)
    if ~( ischar(type) || (iscell(type) && all(cellfun(@(x) ischar(x) && isvector(x),type))) ) || ~isvector(type)
        error('type must be a string or cell array of strings like {''nidaq'',''parallel''}')
    end
    if ~iscell(type)
        type={type};
    end
else
	type=[];
end

if ~ismember(constructor,{'digitalio','analogoutput','analoginput'})
    error('constructor must be one of digitalio,analogoutput,analoginput')
end

matches={};

devices=daqhwinfo;
devices=devices.InstalledAdaptors;

%go through installed daq devices to find one that meets our requirements
for j=1:length(devices)
    device=devices{j};
    if isempty(type) || ismember(device,type)
        deviceInfo=daqhwinfo(device);
        for k=1:length(deviceInfo.InstalledBoardIds)
            board=deviceInfo.InstalledBoardIds{k};
            constructors={deviceInfo.ObjectConstructorName{k,:}};
            for i=1:length(constructors)
                availableConstructor=constructors{i};
                if strncmpi(availableConstructor,constructor,length(constructor))
                    matches{end+1}={device board};
                end
            end
        end
    end
end