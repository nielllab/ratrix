function [t,drops] = readStamps(in)
w = 6;
h = 7;
n = size(in,3);
%c = 50; %% too big for some images
c=20;

stamps = in(1:h,1:w*c,:);

if false
    figure
    t = 22;
    x = in(1,1:t,:);
    imagesc(reshape(permute(x,[1 3 2]),[n t]))
    colormap gray
    cellfun(@(f)f(x(:)),{@min @max})
end

if true
    % http://en.wikipedia.org/wiki/Binary-coded_decimal
    %
    % pixel
    % 1 - image num MSB (00-99)
    % 2 - image num
    % 3 - image num
    % 4 - image num LSB
    % 5 - year MSB (20)
    % 6 - year LSB (03-99)
    % 7 - month (01-12)
    % 8 - day (01-31)
    % 9 - hour (00-23)
    % 10 - min (00-59)
    % 11 - sec (00-59)
    % 12 - us*10000 (00-99)
    % 13 - us*100
    % 14 - us
    
    t = 14;
    x = in(1,1:t,:);
    figure
    imagesc(squeeze(in(1,:,:)))
    f = dec2bin(x,16); 
%    keyboard
    if any(any(f(:,1:8)~='0'))
        %for some reason saving pcoraws uses bits 7-14 instead of 9-16
        f = f(:,[15:16 1:14]);
        
        if any(any(f(:,1:8)~='0'))
            imagesc(double(f))
            figure
            hist(double(x(:)))
            figure
            imagesc(squeeze(x)')
            figure
            imagesc(squeeze(x)'>intmax('uint8'))
            t = nan; drops=nan;
            %%error('bad bcd')
            display('bad bcd')
            
            return
        end
    end
    x = reshape([bin2dec(f(:,9:12)) bin2dec(f(:,13:16))]*10.^[1 0]',[t n])';
    bSecs = x(:,9:14)*[60*60 60 1 .01 .0001 .000001]';
    
    drops = x(:,1:4)*10.^(2*(3 : -1 : 0))';
end

%%% no need to do ascii? and it doesn't work on small images
t=bSecs;
return;

if false
    figure
    imagesc(reshape(permute(stamps,[1 3 2]),[h*n w*c]))
    axis equal
    colormap gray
end

inds = (1:w+2:size(stamps,2))-3;
inds = inds(inds>0);
inds = inds(1:end-1);

f = 9;
lib = stamps(:,inds(f)+(0:w-1),1:10);

if false
    figure
    imagesc(reshape(permute(lib,[1 3 2]),[h*10,w]))
    axis equal
    colormap gray
end

out = nan(n,length(inds));

disp('reading timestamps')
tic
for i = 1:n
    for j = 1:length(inds)
        this = stamps(:,inds(j)+(0:w-1),i);
        match = findPlane(this,lib);
        if isscalar(match)
            out(i,j) = match;
        end
    end
end
toc

out(out==10)=0;

hrs = 22:23;
mn = 25:26;
sec = 28:29;
frc = 31:36;

t = sum(cell2mat(cellfun(@convert,{hrs mn sec frc},'UniformOutput',false)) .* repmat([60*60 60 1 10^-length(frc)],size(out,1),1),2);

num = 3:9;
num = convert(num);

    function x = convert(x)
        d = length(x);
        x = sum(out(:,x).*repmat(10.^(d-1 : -1 : 0),size(out,1),1),2);
    end

if any(isnan(t))
    warning('ascii stamps didn''t work, returning binaries')
    t = bSecs;
else
    if any(abs(t-bSecs)>10^-10) %why aren't these exact?  they differ by 8x10^-12
        error('bad')
    end
    
    if ~all(num==drops)
        error('ascii and binary frame nums didn''t match')
    end
end

figure
plot(diff(t)*1000,'LineWidth',2)
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