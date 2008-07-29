function com = packageArguments(r,com,arguments)
if ~iscell(arguments)
    error('Arguments not a cell array in packageArguments()');
end
if ~isempty(arguments)
    toObj = zeros(length(arguments));
    cmdArgs = javaArray('java.lang.Object',length(arguments));
    for i=1:length(arguments)
        arg = arguments{i};
        if isinteger(arg) && length(arg) == 1
            cmdArgs(i) = java.lang.Integer(arg);
        elseif isnumeric(arg) && length(arg) == 1
            cmdArgs(i) = java.lang.Double(arg);
        elseif islogical(arg) && length(arg) == 1
            cmdArgs(i) = java.lang.Boolean(arg);
        elseif isa(arg,'java.lang.Double') || isa(arg,'java.lang.Integer')
            cmdArgs(i) = arg;
        elseif ischar(arg)
            cmdArgs(i) = java.lang.String(arg);
        elseif isa(arg,'java.lang.String')
            cmdArgs(i) = arg;
        elseif isa(arg,'java.util.Vector')
            cmdArgs(i) = arg;
        elseif isvector(arg) && iscell(arg)
            vec = java.util.Vector();
            setVector = 1;
            for j=1:length(arg)
                argj = arg{j};
                if isinteger(argj) && length(argj) == 1
                    vec.add(java.lang.Integer(argj));
                elseif isnumeric(argj) && length(argj) == 1
                    vec.add(java.lang.Double(argj));
                elseif ischar(argj)
                    vec.add(java.lang.String(argj));
                elseif islogical(argj) && length(argj) == 1
                    vec.add(java.lang.Boolean(argj));
                else
                    % Give up on making the vector, it has to be an object
                    fprintf('Had to give up on making the vector, could not handle element %s',class(argj));
                    setVector = 0;
                    break;
                end
            end
            % If the vector transformation was successful, set it
            if setVector
                cmdArgs(i) = vec;
            else
                cmdArgs(i) = packageObjectArgument(r,com,arg);
            end
        elseif isvector(arg) && ~iscell(arg) && isinteger(arg)
            arr = javaArray('java.lang.Integer',length(arguments));
            for  j=1:length(arg)
                arr(j) = java.lang.Integer(arg(j));
            end
            cmdArgs(i) = arr;
        elseif isvector(arg) && ~iscell(arg) && isnumeric(arg)
            arr = javaArray('java.lang.Double',length(arguments));
            for  j=1:length(arg)
                arr(j) = java.lang.Double(arg(j));
            end
            cmdArgs(i) = arr;
        elseif isvector(arg) && ~iscell(arg) && islogical(arg)
            arr = javaArray('java.lang.Boolean',length(arguments));
            for  j=1:length(arg)
                arr(j) = java.lang.Boolean(arg(j));
            end
            cmdArgs(i) = arr;
        else % Multidim cell arrays, matrices, and objects should all hit this case
            cmdArgs(i) = packageObjectArgument(r,com,arg);
        end
    end
    com.setArguments(cmdArgs);
end
