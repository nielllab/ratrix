function memTest
clc

gb = 4;
n = round(gb*1000*1000*1000/500/500/2);

base = 'D:\Widefield (12-10-12+)\022213\gcam13tt_r2'; %12GB
b = fullfile(base,'gcam13tt_r2.pcoraw');
t = fullfile(base,'gcam13tt_r2g\gcam13tt_r2_'); % 000001.tif ...

x3 = readSeparateTiffs(t,n); %imread to read separates
x1 = detailedTif(b,n); %tiff object to read bigtiff
end

function out = readSeparateTiffs(t,n)
[d,base] = fileparts(t);

out = zeros(464,480,n,'uint16');

arrayfun(@getFrame,1:n);

    function getFrame(i)
        fn = sprintf('%s%06d.tif',base,i);
        out(:,:,i) = imread(fullfile(d,fn));
    end
end

function frames = detailedTif(file,n)
t = Tiff(file,'r');
frames = zeros(464,480,n,'uint16');
arrayfun(@getFrame,1:n);
t.close();

    function getFrame(i)
        frames(:,:,i) = t.read();
        if i < n
            t.nextDirectory();
        end
    end
end