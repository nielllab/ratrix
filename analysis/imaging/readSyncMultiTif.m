function [data t idx pca_fig] = readSyncMultiTif(iPath, maxGB,fl,namelength, rigzoom);

ids = dir([iPath '_*.tif'])

if exist('fl','var') && fl==1
    flipim = 1;
    display('flipping')
else
    flipim=0;
end

bytesPerPix = 2;
pixPerFrame = maxGB*1000*1000*1000/length(ids)/bytesPerPix;
if namelength==6;
    sz = size(imread([iPath '_000001.tif']));
elseif namelength==4
    sz = size(imread([iPath '_0001.tif']));
end
origW = sz(2);
stampHeight = 20;
sz(1) = sz(1)-stampHeight;
sz = round(sz*rigzoom);

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

if exist(mfn,'file') && exist('maxGBsaved','var') && maxGBsaved==maxGB && false
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
    %stamps = zeros(stampHeight,300,length(ids),'uint16'); %%%300?
    stamps = zeros(stampHeight,origW,length(ids),'uint16');
    
    [d,base, ext] = fileparts(iPath);
    tic
    for i=1:length(ids) %something in this loop is leaking
        if rand>.99
            fprintf('%d\t%d\t%g%% done\n',i,length(ids),100*i/length(ids))
        end
        if namelength==6
            fn = sprintf('%s_%06d.tif',[base ext],i);
        elseif namelength==4
            fn = sprintf('%s_%04d.tif',[base ext],i);
        end
        if ~ismember(fn,{ids.name})
            error('hmmm')
        end
       if flipim
           frame =imread(fullfile(d,fn));
           frm = frame((stampHeight+1):end,:);
           stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
           frm = flip(frm,2);
           
       else
           frame = (imread(fullfile(d,fn)));
           frm = frame((stampHeight+1):end,:);
           stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
       end
        
        if rigzoom<1
            s = size(frm); news = round(s*rigzoom);
            frm = frm(round(s(1)/2 - news(1)/2) + 1:news(1), round(s(2)/2 - news(2)/2) + 1:news(2));
        elseif rigzoom>1
            display('need to fix zoom >1')
            break
        end
        
        
        data(:,:,i) = imresize(frm,sz); %is imresize smart about unity?  how do our data depend on method?  (we use default 'bicubic' -- "weighted average of local 4x4" (w/antialiasing) -- we can specify kernel if desired)
        
    end
    toc
    try
    t = readStamps(stamps);
    catch
        t = readStamps(flip(stamps,2));
    end
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

