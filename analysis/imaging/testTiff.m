function testTiff
clc

gb = 3;
n = round(gb*1000*1000*1000/500/500/2);

base = 'D:\Widefield (12-10-12+)\022213\gcam13ln\gcam13ln_r1'; %31GB
b = fullfile(base,'gcam13ln_r1.pcoraw');
t = fullfile(base,'gcam13ln_r1_e\gcam13ln_r1_'); % 000001.tif ...

base = 'D:\Widefield (12-10-12+)\022213\gcam13tt_r2'; %12GB
b = fullfile(base,'gcam13tt_r2.pcoraw');
t = fullfile(base,'gcam13tt_r2g\gcam13tt_r2_'); % 000001.tif ...

d = dir(b)
keyboard

fprintf('imfinfo on pcoraw\n')
tic
info = imfinfo(b); %takes a minute on a big pcoraw
toc

fprintf('%d of %d frames\n',n,length(info))

n = min(n,length(info));

x1 = detailedTif(b,n,info); % tiff object to read bigtiff
x2 = readBigTiff(b,n,info); % imread to read bigtiff
x3 = readSeparateTiffs(t,n); %imread to read separates
% do we want to test tiff object on separates?

whos('x1')

all(x1(:)==x2(:))
all(x2(:)==x3(:))
all(x1(:)==x3(:))
end

function out = readBigTiff(f,num,info)
fprintf('imread bigtiff frame by frame\n')

tic
try
out = arrayfun(@(x)imread(f,x,'Info',info),1:num,'UniformOutput',false); %can't read "subimages" (see detailedTif())
% for multi-image TIFF, providing 'Info' speeds up read
% dies on bigtiffs at high frame numbers with:
% Error using rtifc
% TIFF library error - 'TIFFFetchDirectory:  Sanity check on directory count failed, this is probably not a valid IFD offset.'
out = [out{:}];
catch ex
    getReport(ex)
    out = [];
end
toc
end

function out = readSeparateTiffs(t,n)
[d,base] = fileparts(t);

tic
sz = size(imread([t '000001.tif']));
ids = dir([t '*.tif']);
n = min(n,length(ids));
fprintf('reading separate (%d of %d)\n',n,length(ids))

out = zeros(sz(1),sz(2),n,'uint16');
whos('out')
fprintf('allocated\n')

if true
    arrayfun(@getFrame,1:n);
else
    for i=1:n %something in this loop is leaking
        getFrame(i);
    end
end
toc

    function getFrame(i)
        if false && rand>.95
            fprintf('%d\t%d\t%g%% done\n',i,n,100*i/n)
        end
        
        fn = sprintf('%s%06d.tif',base,i);
        
        out(:,:,i) = imread(fullfile(d,fn));
    end
end

function frames = detailedTif(file,n,info)
fprintf('tiff object read bigtiff\n')

warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')

tic
t = Tiff(file,'r');
frames = zeros(t.getTag('ImageLength'),t.getTag('ImageWidth'),n,'uint16');
whos('frames')
fprintf('allocated\n')
arrayfun(@getFrame,1:n);
t.close();
toc

warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')

    function getFrame(i)
        frames(:,:,i) = t.read();
        if i < n
            t.nextDirectory();
        end
        if false && rand>.95
            fprintf('%d\t%d\t%g%% done\n',i,n,100*i/n)
        end
    end
end