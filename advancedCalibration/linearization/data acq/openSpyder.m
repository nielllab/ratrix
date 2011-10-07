function [libname refreshRate]=openSpyder(displayType)
p = mfilename('fullpath');
[pathstr, name, ext] = fileparts(p);

libpath=fullfile(pathstr,'spyder API');
libname='CVSpyder';

[notfound warnings]=loadlibrary(fullfile(libpath, 'CVSpyder.dll'),fullfile(libpath,'cvimport.h'),'alias',libname,'addheader',fullfile(libpath,'cvtypes.h'));

if ~isempty(notfound)
    notfound
    error('loadlibrary couldn''t find some necessary files')
end

calllib(libname,'CV_Shutdown');

vendorData.DriverVersion=uint16(0);
vendorData.HardwareVersion=uint16(0);
vendorData.SerialNumber=uint8(zeros(1,8));

[success vendorData] = calllib(libname,'CV_Startup',libpointer('CV_VendorData_S',vendorData));

if success ~= 1
    'error calling CV_VendorData_S'
    spyderError(libname);
else
    [success refreshRate] = calllib(libname,'CV_GetRefreshRate',libpointer('int32Ptr',0)); %wants white screen for this!
    refreshRate=double(refreshRate)/1000;

    if success ~= 1
        'error calling CV_GetRefreshRate'
        spyderError(libname);
    else
        switch displayType
            case 'CRT'
                dType=1;
            case 'LCD'
                dType=2;
            otherwise
                error('displayType must be ''CRT'' or ''LCD''')
        end
        success = calllib(libname,'CV_UseCalibration',dType);

        if success ~= 1
            'error calling CV_UseCalibration'
            spyderError(libname);
        end
    end
end