% Copyright (C) 2008 Erik Flister, UCSD, e_flister@REMOVEME.yahoo.com
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
% USA

function spyderError(libname,fName)
[err sysFlag] = calllib(libname,'CV_GetDetailedError',libpointer('uint8Ptr',0));
switch sysFlag
    case 0
        h=dec2hex(err);
        switch h
            case '10001'
                str='API not yet intitialized';
            case '10002'
                str='Invalid parameter passed to function';
            case '10003'
                str='Refresh rate has not yet been determined';
            case '10004'
                str='Commands can not be sent to the serial device';
            case '10005'
                str='The FPGA has not been configured for operation';
            case '20001'
                str='API is already initialized';
            case '20002'
                str='Can’t find rising edge to trigger on';
            case '20003'
                str='Not enough triggers occurred to determine refresh rate';
            case '20004'
                str='Decay rate indicates device may not be attached to a CRT';
            case '20005'
                str='The device does not have CRT calibration factors';
            case '20006'
                str='The device does not have LCD calibration factors';
            otherwise
                error('unrecognized spyder API error')
        end
        switch h(1)
            case '1'
                error(sprintf('calling %s: %s\n',fName,str))
            case '2'
                warning(sprintf('calling %s: %s\n',fName,str))
            otherwise
                error('unrecognized spyder API error type')
        end
    case 1
        if strcmp(dec2hex(err),'20103')
            error('go to http://support.colorvision.ch/index.php?_m=downloads&_a=view and download the latest spyder driver and/or the latest version of spyder2PRO.  install, reboot, and run spyder2PRO.  make sure the spyder is attached via USB and appears in device manager attached to driver C:\WINDOWS\system32\drivers\Spyder2.sys (modified 1/17/2007)')
        else
        	error(sprintf('system error calling %s (outside of spyder SDK), error code as defined for GeLastError() in win32 API (http://msdn.microsoft.com/en-us/library/ms681381(VS.85).aspx)\n',fName));
        end
    otherwise
        error('unrecognized sysflag')
end