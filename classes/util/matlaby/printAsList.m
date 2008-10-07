function out=printAsList(strCells)
    out='[';
    for i=1:length(strCells)
        if ischar(strCells{i})
            if i==length(strCells)
                out = [out strCells{i} ']'];
            else
                out = [out strCells{i} ', '];
            end
        else
            error('must pass in cell array of strings')
        end
    end