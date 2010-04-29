function strOut=restoreControls(str)
strOut=[];
for lNum=1:length(str)
    if str(lNum)=='\'
        code='\\';
    else
        code=fix(str(lNum),{'\t','\n'});
    end
    strOut=[strOut code];
end
end

function out=fix(in,list)
    out={list{in==cellfun(@(x) uint64(sprintf(x)),list)}};
    switch length(out)
        case 1
            out=char(out{:});
        case 0
            out=in;
        otherwise
            error('nonunique list members?')
    end
end