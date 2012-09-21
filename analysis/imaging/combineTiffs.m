function data = combineTiffs
dbstop if error

addpath('C:\Users\nlab\Desktop\ratrix\bootstrap');
setupEnvironment;

base = 'test';
d = 'C:\Users\nlab\Desktop\test';
sz = 100*ones(1,2);

ds = dir(fullfile(d,[base '_*.tif']));

data = nan(sz(1),sz(2),length(ds));
stamps = zeros(20,300,length(ds),'uint16');

for i=1:length(ds)
    fprintf('%d\t%d\t%g%% done\n',i,length(ds),100*i/length(ds))
    fn = sprintf('%s_%04d.tif',base,i);
    if ~ismember(fn,{ds.name})
        error('hmmm')
    end
    frame = imread(fullfile(d,fn));
    data(:,:,i) = imresize(frame,sz);
    stamps(:,:,i) = frame(1:size(stamps,1),1:size(stamps,2));
end

t = readStamps(stamps);
keyboard

end