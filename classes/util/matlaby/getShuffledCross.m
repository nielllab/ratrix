function out=getShuffledCross(in)
if iscell(in) && isvector(in)
    inds=[];
    out={};
    for i=1:length(in)
        if isvector(in{i})
            inds(end+1)=length(in{i});
        else
            error('entries of in must be vectors')
        end
    end

    while ~isempty(inds)
        oldOut=out;
        out={};
        for i=1:inds(end)
            if isempty(oldOut)
                out{end+1}={i};
            else
                for j=1:length(oldOut)
                    out{end+1}={i oldOut{j}{:}};
                end
            end
        end

        inds=inds(1:end-1);
    end

    final={};
    for i=1:length(out)
        final{i}={};
        for j=1:length(out{i})
            final{i}{end+1}=in{j}(out{i}{j});
        end
    end
    
    [garbage order]=sort(rand(1,length(final)));
    out=final(order);
else
    error('in must be a cell vector')
end