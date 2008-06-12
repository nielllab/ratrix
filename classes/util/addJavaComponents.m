function addJavaComponents()
jarPath = getRatrixJarPath;
matches = strfind(javaclasspath,jarPath);
if isempty(strcat(matches{:,:},[]))
    javaaddpath(getRatrixJarPath);
end