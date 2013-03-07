function [data t idx pca_fig] = readSyncMultiTif(iPath, maxGB);

ids = dir([iPath '_*.tif'])

bytesPerPix = 2;
pixPerFrame = maxGB*1000*1000*1000/length(ids)/bytesPerPix;
sz = size(imread([iPath '_0001.tif']));
stampHeight = 20;
sz(1) = sz(1)-stampHeight;
scale = pixPerFrame/prod(sz);
if scale<1
    sz = round(sqrt(scale)*sz);
end

mfn = [iPath '_' sprintf('%d_%d_%d',sz(1),sz(2),length(ids)) '.mat'];
if exist(mfn,'file') 
    load(mfn,'maxGBsaved');
end

exist(mfn,'file')
exist('maxGBsaved','var')
maxGBsaved=maxGB

if exist(mfn,'file') && exist('maxGBsaved','var') && maxGBsaved==maxGB
    fprintf('loading preshrunk\n')
    tic
    f = load(mfn);
    toc
    
    data = f.data;
    t = f.t;
   
    
    clear f
else
    fprintf('reading from scratch\n')
    % fprintf('requesting %g GB memory\n',length(ids)*prod(sz)*bytesPerPix/1000/1000/1000)
    
    data = zeros(sz(1),sz(2),length(ids),'uint16');
    stamps = zeros(stampHeight,300,length(ids),'uint16');
    
    [d,base, ext] = fileparts(iPath);
    tic
    for i=1:length(ids) %something in this loop is leaking
        if rand>.99
            fprintf('%d\t%d\t%g%% done\n',i,length(ids),100*i/length(ids))
        end
        fn = sprintf('%s_%04d.tif',[base ext],i);
        if ~ismember(fn,{ids.name})
            error('hmmm')
        end
        frame = imread(fullfile(d,fn));
        data(:,:,i) = imresize(frame((stampHeight+1):end,:),sz); %is imresize smart about unity?  how do our data depend on method?  (we use default 'bicubic' -- "weighted average of local 4x4" (w/antialiasing) -- we can specify kernel if desired)
        stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
    end
    toc
    
    t = readStamps(stamps);
    
    maxGBsaved = maxGB;
    fprintf('saving...\n')
    tic
    save(mfn,'data','t','maxGBsaved','-v7.3') %7.3 required for >2GB vars
    toc
    
    clear stamps
end


%%% assign blue and green frames based on clustering

%subsample data to make pca calculation manageable
shrunkdata = data(10:10:end,10:10:end,:);
shrunkdata = reshape(shrunkdata,[size(shrunkdata,1)*size(shrunkdata,2) size(shrunkdata,3)]);

%%% calculate pca and cluster on them
[coeff score latent] = princomp(double(shrunkdata)');
idx = kmeans(score(:,1),2);

%%% blue is the larger cluster
if sum(idx==2)>sum(idx==1);
    bl = find(idx==2); gr= find(idx==1);
else
    bl = find(idx==1); gr = find(idx==2);
end
%%% get rid of outliers
bl = bl(abs(zscore(score(bl)))<5); gr = gr(abs(zscore(score(gr)))<5);
idx = nan(size(idx)); idx(bl)=1;  idx(gr)=2;

%%% plot a figure for sanity check
pca_fig=figure
hold on
plot(score(:,1),score(:,2),'ko');
plot(score(bl,1),score(bl,2),'bo');
plot(score(gr,1),score(gr,2),'go');

