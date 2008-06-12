function args = getArguments(c)
args = {};
%c.arguments
if ~isempty(c.arguments)
    if ~isa(c.arguments,'java.lang.Object[]')
        error('Arguments should always be empty or java.lang.Object[]');
    end
    for i=1:length(c.arguments)
        arg = c.arguments(i);
        if isa(arg,'int8')
            tmp = mdeserialize(arg);
            arg = tmp;
        elseif isa(arg,'java.util.Vector')
            % Vectors translate to cell arrays
            cellArg = {};
            vec = arg;
            for j=1:vec.size()
                argj = vec.elementAt(j-1);
                if isa(argj,'java.lang.String')
                    argj = argj.toCharArray();
                end
                cellArg{j}=argj;
            end
            arg = cellArg;
        elseif isa(arg,'java.lang.Boolean[]')
            % Arrays of booleans translate into 1xn logicals
            mArg = logical([]);
            for j=1:arg.length
                mArg(j) = arg(j).booleanValue;
            end
            arg = mArg;
        elseif isa(arg,'java.lang.Integer[]')
            % Arrays of doubles translate into 1xn doubles
            mArg = [];
            for j=1:arg.length
                mArg(j) = int32(arg(j));
            end
            arg = mArg;
        elseif isa(arg,'java.lang.Double[]')
            % Arrays of doubles translate into 1xn doubles
            mArg = [];
            for j=1:arg.length
                mArg(j) = double(arg(j));
            end
            arg = mArg;
        elseif isa(arg,'java.lang.Integer') || isinteger(arg)
            arg = int32(arg);
        elseif isa(arg,'java.lang.Double') || isnumeric(arg)
            arg = double(arg);
        elseif isa(arg,'java.lang.Boolean')
            arg = arg.booleanValue;
        elseif islogical(arg)
            arg = logical(arg);
        elseif ischar(arg)
            % Nothing to do
        elseif isa(arg,'java.lang.String')
            arg = arg.toCharArray();
        elseif isa(arg,'java.io.File')
            str = arg.getPath();
            fpath = str.toCharArray();
            fprintf('Reading .mat file in\n');
            load(fpath,'tmp');
            arg = tmp;
        else
            fprintf('Unable to handle this argument type %s in getArguments()\n',class(arg));
            error('Unable to handle type');
        end
        args{i} = arg;
    end
end