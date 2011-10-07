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

function [libname refreshRate]=openSpyder(displayType)
p = mfilename('fullpath');
[pathstr, name, ext] = fileparts(p);

libpath=fullfile(pathstr,'spyderAPI'); %in osx, this path must not have spaces (at least in intel/2007a
libname='CVSpyder';

switch computer
    case 'PCWIN'
        %note i had to make the following changes to the header files:
        %cvimport.h: comment out DLLIMPORT lines mentioning  'CV_GetRawUnfiltered'    'CV_GetReadings'    'CV_ReadEEPROM'    'CV_WriteEEPROM'
        %            these functions were not meant to be exported, according to colorvision
        %cvtypes.h: the line "typedef unsigned long UINT32;" was present in the __MACOS__ #ifdef, but needed to be added to the _WIN32 #ifdef
        shLib=fullfile(libpath, 'CVSpyder');

    case 'MAC'
        libpath=fullfile(libpath,'Spyder_Mac_SDK_2.0-Xcode','OS_X');
        shLib=fullfile(libpath,'build-ppc','release','Spyder.dylib');
    case 'MACI'
        libpath=fullfile(libpath,'Spyder_Mac_SDK_2.0-Xcode','OS_X');
        shLib=fullfile(libpath,'build-intel','release','Spyder.dylib');
    otherwise
        error('only ismember(computer,{''PCWIN'',''MAC'',''MACI''}) supported')
end

[notfound warnings]=loadlibrary(shLib,fullfile(libpath,'cvimport.h'),'alias',libname,'addheader',fullfile(libpath,'cvtypes.h'));

if ~isempty(notfound)
    warning('loadlibrary couldn''t find some exported functions')
    notfound
end

calllib(libname,'CV_Shutdown');

vendorData.DriverVersion=uint16(0);
vendorData.HardwareVersion=uint16(0);
vendorData.SerialNumber=uint8(zeros(1,8));

[success vendorData] = calllib(libname,'CV_Startup',libpointer('CV_VendorData_S',vendorData));

if success ~= 1
    spyderError(libname,'CV_VendorData_S');
end

vendorData

[success refreshRate] = calllib(libname,'CV_GetRefreshRate',libpointer('int32Ptr',0)); %wants white screen for this!
refreshRate=double(refreshRate)/1000;

if success ~= 1
    spyderError(libname,'CV_GetRefreshRate');
end

lcdStr=['on LCDs, expect CV_GetRefreshRate call to fail and complain that it expected a CRT, and return 60Hz no matter what\n'...
    'presumably the spyder cannot detect LCD refreshes because of the long decay, so it gives up and makes worst case assumptions\n'...
    'no idea why it doesn''t take the display type provided to CV_UseCalibration into account\n'];
%the docs say to call CV_GetRefreshRate before CV_UseCalibration, but transposing these has no effect

switch displayType
    case 'CRT'
        dType=1;
    case 'LCD'
        dType=2;
        fprintf(lcdStr);
    otherwise
        error('displayType must be ''CRT'' or ''LCD''')
end
success = calllib(libname,'CV_UseCalibration',dType);

if success ~= 1
    spyderError(libname,'CV_UseCalibration');
end