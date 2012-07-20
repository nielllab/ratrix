function t = readStamps(in)
w = 6;
h = 7;
n = size(in,3);
c = 50;

stamps = in(1:h,1:w*c,:);

if false
    figure
    imagesc(reshape(permute(stamps,[1 3 2]),[h*n,w*c]))
    axis equal
    colormap gray
end

inds = (1:w+2:size(stamps,2))-3;
inds = inds(inds>0);
inds = inds(1:end-1);

f = 9;
lib = stamps(:,inds(9)+[0:w-1],1:10);

if false
    figure
    imagesc(reshape(permute(lib,[1 3 2]),[h*10,w]))
    axis equal
    colormap gray
end

out = nan(n,length(inds));

for i = 1:n
    for j = 1:length(inds)
        this = stamps(:,inds(j)+(0:w-1),i);
        match = findPlane(this,lib);
        if isscalar(match)
            out(i,j) = match;
        end
    end
end

out(out==10)=0;

hrs = 22:23;
min = 25:26;
sec = 28:29;
frc = 31:36;

t = sum(cell2mat(cellfun(@convert,{hrs min sec frc},'UniformOutput',false)) .* repmat([60*60 60 1 10^-length(frc)],size(out,1),1),2);

    function x = convert(x)
        d = length(x);
        x = sum(out(:,x).*repmat(10.^(d-1 : -1 : 0),size(out,1),1),2);
    end

if any(isnan(t))
    error('bad')
end

figure
plot(diff(t)*1000)
xlabel('frame')
ylabel('ms')
end

function out = findPlane(in,lib)
out = [];

for i=1:size(lib,3)
    test = lib(:,:,i)==in;
    if all(test(:))
        out(end+1) = i;
    end
end
end