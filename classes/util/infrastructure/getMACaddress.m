function [success mac]=getMACaddress()
success=false;
if IsWin
    macidcom = fullfile(PsychtoolboxRoot,'PsychContributed','macid');
    [rc mac] = system(macidcom);
    mac=mac(~isstrprop(mac,'wspace'));
    if rc==0 && isMACaddress(mac)
        success=true;
    end
elseif IsOSX || IsLinux
        compinfo = Screen('Computer');
        if isfield(compinfo, 'MACAddress')
            mac = compinfo.MACAddress;
            % Remove the : that are a part of the string
            mac = mac(mac~=':');
            if isMACaddress(mac)
                success = true;
            end
        end
            
else
    error('In getMACaddress() unknown OS');
end