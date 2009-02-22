function clearJavaComponents()
% Remove all java references, remove the jar path, then garbage collect
% java.lang.System.gc();
% clear java;

if usejava('jvm')
    java.lang.System.gc();
    clear java;
    warning('off','MATLAB:GENERAL:JAVARMPATH:NotFoundInPath')
    javarmpath(getRlabJarPath);
    warning('on','MATLAB:GENERAL:JAVARMPATH:NotFoundInPath')
end