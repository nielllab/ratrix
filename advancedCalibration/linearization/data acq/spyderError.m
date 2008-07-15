function spyderError(libname)
[err sysFlag] = calllib(libname,'CV_GetDetailedError',libpointer('uint8Ptr',0));
sysFlag %will be 0 for API, 1 for system (as defined for GetLastError() in win32 API)
dec2hex(err)
if sysFlag && strcmp(dec2hex(err),'20103')
    error('go to http://www.colorvision.com/dl_software.php and download the latest spyder driver and/or the latest version of spyder2PRO (serial: 112710-692340-550088).  install, reboot, and run spyder2PRO.  make sure the spyder is attached via USB and appears in device manager attached to driver C:\WINDOWS\system32\drivers\Spyder2.sys (modified 1/17/2007)')
end