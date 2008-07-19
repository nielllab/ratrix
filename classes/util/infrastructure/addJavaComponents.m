function addJavaComponents()
jarPath = getRlabJarPath;
matches = strfind(javaclasspath,jarPath);
if isempty(strcat(matches{:,:},[]))
    javaaddpath(getRlabJarPath);
end