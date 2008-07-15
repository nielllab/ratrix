function [out refreshRate vendorData]=accessSpyder

p = mfilename('fullpath');
[pathstr, name, ext, versn] = fileparts(p);

libpath=fullfile(pathstr,'spyder API');%'C:\Documents and Settings\rlab\Desktop\Spyder_Win_SDK_2.1\Spyder_Win_SDK_2.1\API\';
libname='CVSpyder';

[notfound warnings]=loadlibrary(fullfile(libpath, 'CVSpyder.dll'),fullfile(libpath,'cvimport.h'),'alias',libname,'addheader',fullfile(libpath,'cvtypes.h')); %,'includepath',[matlabroot '\sys\lcc\include']);

%libfunctions(libname, '-full');

%what are these?:
% [uint8, int32Ptr, int32Ptr, int32Ptr] CV_GetXYZEx(uint16, int32Ptr, int32Ptr, int32Ptr, uint8)
% [uint32, voidPtr] CV_GetXYZ_Start(uint16, voidPtr)
% [uint32, int32Ptr, int32Ptr, int32Ptr, uint8Ptr] CV_GetXYZ_Values(int32Ptr, int32Ptr, int32Ptr, uint8Ptr)

%note, all functions which take uint32* parameters (CV_GetReadings,CV_GetRawUnfiltered)
%as well as other functions (CV_ReadEEPROM,CV_WriteEEPROM) (reason?)
%raise 'Warning: The function was not found in the library'

%note, had to add line to cvtypes.h in the ifdef _WIN32 section:
%typedef unsigned long UINT32;
%possibly because matlab's windows.h (in matlab root\sys\lcc\include) doesn't have it?
%otherwise functions that return uint32's appeared to return lib.pointer instead

calllib(libname,'CV_Shutdown');

vendorData.DriverVersion=uint16(0);
vendorData.HardwareVersion=uint16(0);
vendorData.SerialNumber=uint8(zeros(1,8));

[success vendorData] = calllib(libname,'CV_Startup',libpointer('CV_VendorData_S',vendorData));

if success ~= 1
    'error calling CV_VendorData_S'
    doError(libname);
else
    [success refreshRate] = calllib(libname,'CV_GetRefreshRate',libpointer('int32Ptr',0));
    refreshRate=double(refreshRate)/1000;

    if success ~= 1
            'error calling CV_GetRefreshRate'
        doError(libname);
    else
        success = calllib(libname,'CV_UseCalibration',1); %1 for CRT, 2 for LCD

        if success ~= 1
            'error calling CV_UseCalibration'
            doError(libname);
        else
            numFrames=10;

            %expect warning 0x00020002 for dark screens (can't detect frame edges)
            [success, xP, yP, zP] = calllib(libname,'CV_GetXYZ',numFrames,libpointer('int32Ptr',0),libpointer('int32Ptr',0),libpointer('int32Ptr',0));
            out=[double(xP) double(yP) double(zP)]/1000;
            
            if success ~= 1
                'error calling CV_GetXYZ'
                doError(libname);
            end
        end
    end
end

calllib(libname,'CV_Shutdown');

unloadlibrary(libname);

function doError(libname)
[err sysFlag] = calllib(libname,'CV_GetDetailedError',libpointer('uint8Ptr',0));
sysFlag %will be 0 for API, 1 for system (as defined for GetLastError() in win32 API)
dec2hex(err)