function out=checkImages(s,n,dups)
try
    d=dir(fullfile(s.directory,'*.png'));
catch
    error('can''t load that directory')
end

prefix='';
theExt='';
digits={};

tic
for i=1:length(d)
    if ~d(i).isdir
        [pathstr,name,ext,ver] = fileparts(d(i).name);
        try
            [im m alpha]=imread(fullfile(s.directory,[name ext]));
            size(im)
            if ~strcmp(class(im),'uint8') || ~ismember(length(size(im)),[2 3]) || (length(size(im))==3 && size(im,3)~=3) || isempty(alpha) || ~isempty(m)
                size(im)
                error('unexpected image format for %s: %s',fullfile(s.directory,[name ext]),class(im))
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
    end
end

disp(sprintf('\nwasted %g secs checking %d images\n',toc,i))

%sort, but preserve leading zeros
digs=[];
for i=1:length(digits)
    digs(i)=str2num(digits{i});
end
[digs order]=sort(digs);
digits=digits(order); %note the ROUND parens!

if dups
    r=ceil(rand(1,n)*length(digits));
else
    [garbage order]=sort(rand(1,length(digits)));
    r=order(1:n);
end
r=sort(r);

for i=1:n
    [out{i,1} garbage out{i,3}]=imread(fullfile(s.directory,[prefix digits{r(i)} ext])); %,'BackgroundColor',zeros(1,3)); this would composite against black and return empty alpha
    rec.directory=s.directory;
    rec.prefix=prefix;
    rec.digits=digits{r(i)};
    rec.ext=ext;
    out{i,2}=rec;
end