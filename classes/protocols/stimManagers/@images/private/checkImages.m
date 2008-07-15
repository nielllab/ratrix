function [s updateSM out]=checkImages(s,n,dups,backgroundcolor)
try
    d=dir(fullfile(s.directory,'*.png'));
catch
    error('can''t load that directory')
end

prefix='';
theExt='';
digits={};
ims={};
alphas={};

tic
for i=1:length(d)
    if ~d(i).isdir
        [pathstr,name,ext,ver] = fileparts(d(i).name);
        try
            [im m alpha]=imread(fullfile(s.directory,[name ext]));  %,'BackgroundColor',zeros(1,3)); this would composite against black and return empty alpha
            size(im)
            if ~strcmp(class(im),'uint8') || ~ismember(length(size(im)),[2 3]) || (length(size(im))==3 && size(im,3)~=3) || isempty(alpha) || ~isempty(m)
                size(im)
                error('images must be png with alpha channel - unexpected image format for %s: %s',fullfile(s.directory,[name ext]),class(im))
            end
            
            if length(size(im))==3
                im=uint8(floor(sum(im,3)/3)); %convert to greyscale
            end
        catch
            fullfile(s.directory,[name ext])
            error('non-image file in directory')
        end
        digs=isstrprop(name,'digit');
        if any(diff(int8(digs))<0)
            name
            error('digits found mid-name')
        end
        if isempty(prefix)
            prefix=name(~digs);
            theExt=ext;
        elseif ~strcmp(prefix,name(~digs))
            prefix
            name(~digs)
            error('more than one prefix in directory')
        elseif ~strcmp(theExt,ext)
            theExt
            ext
            error('extensions don''t match')
        end
        digits{end+1}=name(digs);
        ims{end+1}=im;
        alphas{end+1}=alpha;
    end
end

cacheFresh=true;
if isempty(s.cache)
    cacheFresh=false;
else
    if length(s.cache.digits)==length(digits) && strcmp(s.cache.prefix,prefix) && all(ismember(digits,s.cache.digits)) && s.cache.n==n
        for i=1:length(s.cache.digits)
            ind=find(strcmp(s.cache.digits{i},digits));
            if ~isscalar(ind)
                digits
                s.cache.digits
                error('dupe digits found')
            end
            if ~(all(s.cache.ims{i}(:)==ims{ind}(:)) && all(s.cache.alphas{i}(:)==alphas{ind}(:)))
                cacheFresh=false;
                break
            end
        end
    else
        cacheFresh=false;
    end
end
updateSM=~cacheFresh;

disp(sprintf('\nwasted %g secs checking %d images\n',toc,i))

if ~cacheFresh
    
    s.cache=[];
    
    s.cache.prefix=prefix;
    s.cache.ims=ims;
    s.cache.alphas=alphas;
    s.cache.digits=digits;
    s.cache.n=n;
    
    [allIms s.cache.deltas]=prepareImages(ims,alphas,[getMaxHeight(s) floor(length(digits)*getMaxWidth(s)/n)],.95,.9, backgroundcolor);

    imWidth=size(allIms,2)/length(ims);
    for i=1:length(ims)
        colRange=(1:imWidth)+(i-1)*imWidth;
        s.cache.preparedIms{i}=allIms(:,colRange);
    end
end

clear('digits','ims','alphas')

%choose n image indices
if n>length(s.cache.digits)
    error('n must be <= num images')
end
if dups
    inds=ceil(rand(1,n)*length(s.cache.digits));
else
    [garbage ord]=sort(rand(1,length(s.cache.digits)));
    inds=ord(1:n);
end

%sort indices according to corresponding digits
digs=[];
for i=1:length(inds)
    digs(i)=str2num(s.cache.digits{inds(i)});
end
[digs order]=sort(digs);
inds=inds(order);

for i=1:n
    out{i,1}=s.cache.preparedIms{inds(i)};
    
    rec.directory=s.directory;
    rec.prefix=prefix;
    rec.digits=s.cache.digits{inds(i)};
    rec.ext=ext;
    rec.delta=s.cache.deltas{inds(i)};
    out{i,2}=rec;
end
