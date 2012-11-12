function setupDBPaths()
if usejava('jvm')
    % This function is used to dynamically load two .jar files
    % jdbc jar - postgresql-9.2-1001.jdbc4.jar  : postgres jdbc class
    % cpath jar - cpath.jar       : Utility function that allows us to
    % dynamically add a file to the java class path in the system loader
    % finalizeDBPaths is called to actually do the work
    jdbcFile = 'postgresql-9.2-1001.jdbc4.jar';
    cpathFile = 'cpath.jar';
    [dbPath, name, ext] = fileparts(mfilename('fullpath'));
    jdbcPath = fullfile(dbPath,jdbcFile);
    cpathPath = fullfile(dbPath,cpathFile);
    
    if ~any(strcmp(javaclasspath('-all'),jdbcPath))
        javaaddpath(jdbcPath);
    else
        fprintf('postgres jdbc jar file already present\n')
    end
    
    if ~any(strcmp(javaclasspath('-all'),cpathPath))
        javaaddpath(cpathPath);
    else
        fprintf('Class Path Hacker cpath.jar file already present\n')
    end
    
    finalizeDBPaths(jdbcPath);
else
    warning('no db connectivity without java')
end