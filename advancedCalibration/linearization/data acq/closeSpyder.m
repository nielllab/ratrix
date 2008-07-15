function closeSpyder(libname)
calllib(libname,'CV_Shutdown');
unloadlibrary(libname);