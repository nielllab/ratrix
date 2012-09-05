function [frameT out] = readTifStandalone(in)
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

if ~exist('in','var') || isempty(in)
    [f,p] = uigetfile({'*.tif'; '*.tiff'; '*.mat'},'choose pco data');
    %'C:\Users\nlab\Desktop\macro\real\'
    %[f,p] = uigetfile('C:\Users\nlab\Desktop\data\','choose pco data');
    
    if f==0
        out = [];
        return
    end
    
    [a b] = fileparts(fullfile(p,f));
    in = fullfile(a,b);
end

try
    intf = [in '.tif'];
    info = imfinfo(intf);
    n = length(info);
end

mf = [in '.mat'];
if exist(mf,'file')
    disp('loading .mat')
    tic
    out = load(mf);
    toc
    out = out.out;
else
    disp('loading tiff')
    tic
    out = arrayfun(@(x)imread(intf,x,'Info',info),1:n,'UniformOutput',false); %can't read "subimages" (see detailedTif())
    % for multi-image TIFF, providing 'Info' speeds up read
    toc
    
    disp('reformatting')
    tic
    out = cell2mat(reshape(out,[ones(1,2) n]));
    toc
    
    disp('saving .mat')
    tic
    save(mf,'out','-v7.3'); %compresses to half the size, far faster to load, may need to set -v7.3 so can exceed 2GB
    toc
end

b = whos('out');
disp(['movie is ' num2str(b.bytes/1000/1000/1000) ' GB'])

frameT=[];
try
    frameT=readStamps(out);
end

%rect = [950 600 500 650]; %left top width height
%rect = [950 450 800 900];
%rect = [1 1 500 100];

plotTags = true;
if plotTags
    u = [info.UnknownTags];
    if ~all([u.ID]==50495)
        error('unexpected unknown tag id')
    end
    v = [u.Value]';
    i = find(any(diff(v)));
    k = length(i);
    h = [];
    
    figure
    for j=1:k
        h(end+1) = subplot(k,1,j);
        plot(v(:,i(j)))
        title(['byte ' num2str(i(j))])
    end
    xlabel('frame')
    linkaxes(h,'x');
    
    if ~all(ismember(i,[15 17    19    20    21    22  23 453   454   455]))
        i
        warning('unexpected byte variability')
    end
end

if false
    doDetailed = false;
    if doDetailed
        frames = detailedTif(intf);
    else
        figure
        colormap gray
        stampHeight = 10;
        imagesc(mean(double(out(stampHeight:end,:,:)),3));
        axis equal
        title('select ROI by dragging mouse, double click on it when done')
        h = imrect('PositionConstraintFcn',makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'))); %also consdier rbbox, dragrect, getrect, others?
        rect = round(wait(h)) + [0 stampHeight 0 0]; %left top width height %top, not bottom, cuz imagesc
    end
    out = out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),:);
end

sizestruct = whos('out');
shrinkfactor = 1.5*10^9 / sizestruct.bytes
if shrinkfactor<1
    out = out(:,:,1:floor(shrinkfactor*size(out,3)));
end
size(out)
