function dirOverview(base,n)
dbstop if error

if ~exist('base','var') || isempty(base)
    base = 'F:\data'; %'\\landis\data'; %remote is slow if local
end
if ~exist('n','var') || isempty(base)
    n = 0;
end

bases = {};
arrayfun(@f,dir(base),'UniformOutput',false);
if ~isempty(bases)
    cellfun(@(x,y)say([x ' (' num2str(y) ')']),bases(:,1),bases(:,2),'UniformOutput',false);
end

    function f(d)
        if d.isdir
            if ~ismember(d.name,{'..' '.'})
                say(d.name);
                dirOverview(fullfile(base,d.name),n+1)
            end
        elseif strcmp(d.name(end-3:end),'.tif')
            b = getBase(d.name);
            if ~isnan(b)
                if ~isempty(bases)
                    [tf, loc] = ismember(b,bases(:,1));
                else
                    tf = false;
                end
                if tf
                    bases{loc,2} = bases{loc,2}+1;
                else
                    bases(end+1,:)={b 1};
                end
            end
        else
            say(d.name);
        end
        
        function out = getBase(in)
            x = max(strfind(in,'_'));
            if ~isempty(x)
                out = in(1:x-1);
            else
                out = nan;
                say(in);
            end
        end
    end

    function say(s)
        for i=1:n
            fprintf('\t');
        end
        fprintf([s '\n']);
    end
end