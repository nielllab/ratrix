function newArg = packageObjectArgument(r,com,arg)
try
    tmp = arg;
    % This name should be unique per process, command, and argument
    fname = sprintf('.tmp-java-matlab-%d-%d-%d-outgoing.mat',r.type,com.getUID(),i);
    fpath = fullfile(matlabroot,fname);
    save(fpath,'tmp');
    newArg=java.io.File(java.lang.String(fpath));
catch
    ex=lasterror;
    ple(ex)
    error('Unable to handle given argument %s',class(arg));
end
