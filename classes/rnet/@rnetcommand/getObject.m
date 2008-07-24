function obj = getObject(cmd,argument)
try
    tmp = arguments;
    fName = ['.' filesep 'tmp-java-matlab-var-transfer' ];
    fd=fopen(fName,'w+');
    fwrite(fd,argument.toCharArray());
    frewind(fd);
    load(fd,'tmp');
    fclose(fd);
catch ex
    ple(ex)
    error('Unable to handle given argument %s',class(arguments{i}));
end