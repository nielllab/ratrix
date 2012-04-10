function drawVector(vector)
close all

if exist('vector','var') && ~isempty(vector)
    if isvector(vector)
        vector = vector(:)';
        nx = length(vector);
    else
        error('input must be vector')
    end
else
    nx = 100;
    vector = rand(1,nx);
end

ny = 100;

m = minmax(vector);
    function out = minmax(in)
        out = cellfun(@(f) f(in(:)),{@min @max});
    end

inds = 1+round((ny-1)*(vector-m(1))/(m(2)-m(1)));
matrix = nan(ny,2*nx);
matrix(sub2ind(size(matrix),inds,2*(1:nx)-1)) = 1;

for i = 2:nx
    matrix(count(inds(i-[1 0])),2*(i-1)) = 1;
end
    function out = count(in)
        s = sign(diff(in));
        if s~=0
            out = in(1):s:in(2);
        else
            out = in(1);
        end
    end

subplot(2,1,1)
plot(vector)
subplot(2,1,2)
imagesc(matrix)
axis xy

tick('XTick',[1 nx],0);
tick('YTick',m,2);
    function tick(s,vals,p)
        t = get(gca,s);
        vals = vals(1)+(vals(2)-vals(1))*t/max(t);
        for i=1:length(vals)
            ts{i}=sprintf('%.*f',p,vals(i));
        end
        set(gca,[s 'Label'],ts);
    end
end