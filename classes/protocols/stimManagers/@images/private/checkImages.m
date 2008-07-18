function [s updateSM out]=checkImages(s,ind,backgroundcolor, pctScreenFill, normalizeHistograms,width,height)

if ~exist('pctScreenFill','var')
    pctScreenFill=0.9;
end

if ~exist('normalizeHistograms','var')
    normalizeHistograms=true;
end

if isscalar(ind) && isinteger(ind) && ind>0 && ind<=length(s.trialDistribution)
    fileNames=s.trialDistribution{ind}{1};
else
    error('bad ind')
end

if false %had to disable cache checking on every trial, cuz of trac issue 98
    %load image data
    [ims alphas names ext n]=validateImages(s);

    if ~isempty(s.cache)
        if all(ismember({'ims' 'alphas' 'names' 'ext'},fields(s.cache)))
            if length(ims)~=length(s.cache.ims)
                s.cache=[];
            else
                for i=1:length(ims)
                    if ~all(ims{i}(:)==s.cache.ims{i}(:)) || ~all(alphas{i}(:)==s.cache.alphas{i}(:)) || ~all(strcmp(s.cache.names{i},names{i})) || ~strcmp(ext,s.cache.ext)
                        s.cache=[];
                    end
                end
            end
        else
            s.cache=[];
        end
    end
end

updateSM=false;
if isempty(s.cache) %without the above, we won't see changes to the files once we are created, must regenerate stimManager to refresh cache
    [ims alphas names ext n]=validateImages(s);

    s.cache.names = names;
    s.cache.alphas = alphas;
    s.cache.ims = ims;
    s.cache.ext = ext;

    %scale images, set in background, normalize areas and histograms
    width=min(width,getMaxWidth(s));
    height=min(height,getMaxHeight(s));
    [allIms s.cache.deltas]=prepareImages(ims,alphas,[height floor(length(s.cache.names)*width/n)],.95,pctScreenFill, backgroundcolor, normalizeHistograms);

    imWidth=size(allIms,2)/length(ims);
    for i=1:length(ims)
        colRange=(1:imWidth)+(i-1)*imWidth;
        s.cache.preparedIms{i}=allIms(:,colRange);
    end

    updateSM=true;
end

clear('ims','alphas','names','ext')

%find indices for the file names for this trial
[checks inds]=ismember(fileNames,s.cache.names);

if ~all(checks)
    error('request for file name not in distribution')
end

for i=1:length(inds)
    out{i,1}=s.cache.preparedIms{inds(i)};

    rec.directory=s.directory;
    rec.name=s.cache.names{inds(i)};
    rec.ext=s.cache.ext;
    rec.delta=s.cache.deltas{inds(i)};
    out{i,2}=rec;
end