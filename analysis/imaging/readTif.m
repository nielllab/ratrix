function out = readTif(in)
[pathstr, name, ext] = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(fileparts(pathstr),'bootstrap'))
setupEnvironment;

dbstop if error
colordef white
close all

if ~exist('in','var') || isempty(in)
    %[f,p] = uigetfile({'*.tif'; '*.tiff'; '*.mat'},'choose pco data');
    [f,p] = uigetfile('C:\Users\nlab\Desktop\data\','choose pco data');
    [a b] = fileparts(fullfile(p,f));
    in = fullfile(a,b);
end

intf = [in '.tif'];
info = imfinfo(intf);
n = length(info);

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

readStamps(out);

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
    
    if ~all(ismember(i,[17    19    20    21    22   453   454   455]))
        i
        warning('unexpected byte variability')
    end
end

if true
    doDetailed = false;
    if doDetailed
        frames = detailedTif(intf);
    else
        figure
        colormap gray
        imagesc(mean(double(out),3));
        axis equal
        title('select ROI by dragging mouse, double click on it when done')
        h = imrect('PositionConstraintFcn',makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'))); %also consdier rbbox, dragrect, getrect, others?
        rect = round(wait(h)); %left top width height
    end
end

%out = doNormalize(out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),:));

out = out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),:);
%keyboard
m = repmat(mean(double(out),3),[1 1 size(out,3)]);
dfof = (double(out)-m)./m;

figure
sig = mean(mean(dfof,1),2);
subplot(2,1,1)
plot(squeeze(sig))
subplot(2,1,2)
plot(linspace(0,10,length(squeeze(sig))),log(abs(fft(squeeze(sig)))))

keyboard

minD = min(dfof(:));
dfof = dfof-minD;
dfof = dfof/max(dfof(:));



dfof = doNormalize(dfof);

if true
    chooseParams(dfof);
end

makeAVI = true;
if makeAVI
    writeAVI(in,out);
end
end

function in = doNormalize(in)
disp('normalizing')
tic
if false
    in = normalizePerFrame(in);
else
    p = .5;%.00001;
    p = [40 .5];
    p = [.1 .1];
    in = prctileNormalize(in,p.*[1 -1]+[0 1]*100);
end

if min(in(:)) ~= 0 || max(in(:)) ~= intmax('uint8') || ~isa(in,'uint8')
    warning('normalizing error')
end
toc

extrema = cellfun(@(f)in==f(in(:)),{@min @max},'UniformOutput',false);

in = expand(in);
cellfun(@color,extrema,{[0 0 1] [1 1 0]});

    function color(pts,c)
        if true % $1 if you can vectorize this
            [x y fr]=ind2sub(size(pts),find(pts));
            c = intmax('uint8')*uint8(c);
            for i = 1:length(x)
                in(x(i),y(i),:,fr(i)) = c;
            end
        else %this is close, but wrong (doesn't keep the c's in the right channels)
            in(expand(pts)) = intmax('uint8')*repmat(reshape(uint8(c),[1 1 3 1]),[1 1 1 length(find(pts))]);
        end
    end
end

function chooseParams(in)
i = 1;
playing = false;

border = 10;
dims = [size(in,1) size(in,2)];

maxDim = 800;

fact = dims/maxDim;
if any(fact>1)
    dims = ceil(dims/max(fact));
end

aWidth = dims(2);
aHeight = dims(1);

szs.border=14;
% szs.stWidth=50;
szs.stHeight=10;
szs.sHeight=10;
% szs.sWidth=aWidth-3*border-szs.stWidth;

bHeight = 20;
bWidth = 50;

spHeight=5*szs.border+szs.sHeight+szs.stHeight;

fWidth=2*border+aWidth;
fHeight= 4*border+spHeight+aHeight+bHeight;

f = figure('MenuBar','none','Toolbar','figure','Name','image analysis','NumberTitle','off','Resize','off','CloseRequestFcn',@cleanup,'Units','pixels','Position',[50 50 fWidth fHeight]);
    function cleanup(src,evt)
        playing = false;
        closereq;
    end

sph = uipanel(f,'title','controls','Units','pixels','Position',[border 2*border+bHeight aWidth spHeight]);

ah = axes('Parent',f,'XTick',[],'YTick',[],'Units','pixels','Position',[border 3*border+spHeight+bHeight aWidth aHeight]);
bh = uicontrol(f,'Style','togglebutton','String','play','callback',@buttonC,'Units','pixels','Position',[fWidth-border-bWidth border bWidth bHeight]);

%sliderstep doesn't seem to be working
frameS=sliderPanelHoriz(sph,{'title','frame'},{'min',1,'max',size(in,4),'SliderStep',ones(1,2),'value',i,'callback',@frameC},[],[],'%0.0f');
    function frameC(src,evt)
        i = get(frameS,'Value');
        if mod(i,1)~=0
            i=round(i);
            set(frameS,'Value',i); %doesn't trigger callback :(
        end
        %disp(['showing ' num2str(i)])
        image(in(:,:,:,i),'Parent',ah);
        set(ah,'XTick',[],'YTick',[]);
    end

    function buttonC(src,evt)
        playing = get(bh,'Value');
        doPlay;
    end

    function doPlay
        if playing
            i = 1+mod(i+1,size(in,4));
            set(frameS,'Value',i); %doesn't update text box :(
            frameC
            pause(.05);
            
            s = warning('off','MATLAB:class:DestructorError');
            try
                doPlay
            catch
                playing = false;
                set(bh,'Value',0);
                warning('stopping cuz recurssion limit reached -- you can restart now')
            end
            warning(s.state,'MATLAB:class:DestructorError');
        end
    end

frameC
end

function x = expand(x)
x = permute(repmat(x,[1 1 1 3]),[1 2 4 3]);
end

function writeAVI(f,in)
if numel(in)>2000*2000*100 %writes in ~20sec
    %we could write frame-by-frame in this case...
    error('sending too much to writeVideo freezes computer')
end

disp('writing avi')
tic
avi = VideoWriter([f '.avi'],'Uncompressed AVI');
open(avi);
writeVideo(avi,in);
close(avi);
toc
end

function in = prctileNormalize(in,p)
doDiff = false; %to see blood flow
if doDiff
    in = in(:,:,51:end);
end

in = double(in);

if doDiff
    in = diff(in,[],3);
    %in = in - repmat(mean(in,3),[1 1 size(in,3)]);
    p = cellfun(@(f)f(in(:)),{@min @max});
else
    p = prctile(in(:),p); %this has to sort all pixels -- could subsample if too slow
end

in = uint8(double(intmax('uint8'))*(in-p(1))/diff(p));
end

function in = normalizePerFrame(in)
%probably don't actually want different normalization each frame
%and probably don't want to use brightest/darkest pixels either -- sensitive to noise
lims = cell2mat(cellfun(@(x)cell2mat(cellfun(@(f)f(x(:)),{@min @max},'UniformOutput',false)),mat2cell(in,size(in,1),size(in,2),ones(1,size(in,3))),'UniformOutput',false));

in = double(in-repmat(lims(:,1,:),size(in,1),size(in,2)));
in = uint8(double(intmax('uint8'))*in./repmat(double(diff(lims)),size(in,1),size(in,2)));
end

function frames = detailedTif(file)
frames = [];

t = Tiff(file,'r');
subRead;
t.close();

    function subRead
        fprintf('current directory: ')
        disp(t.currentDirectory);
        
        x = t.read();
        size(x)
        imagesc(x);
        
        cellfun(@readTag,t.getTagNames,'UniformOutput',false);
        
        try
            t.getTag('SubIFD') %errors!?
            
            for offset = t.getTag('SubIFD')
                t.setSubDirectory(offset);
                fprintf('\n***subdirectory***\n');
                subRead;
            end
        catch ex
            getReport(ex)
        end
    end

    function readTag(tag)
        try
            v = t.getTag(tag);
            
            fprintf('\ntag: ');
            disp(tag);
            if numel(v)>100
                disp([class(v) ': ' num2str(size(v))]);
            else
                disp(v);
            end
        catch e
            if ismember(e.identifier,{...
                    'MATLAB:imagesci:Tiff:tagRetrievalFailed',...
                    'MATLAB:imagesci:Tiff:colorMapRetrievalFailed',...
                    'MATLAB:imagesci:Tiff:NoTileinStripImage',...
                    'MATLAB:imagesci:Tiff:transferFunctionRetrievalFailed',...
                    'MATLAB:imagesci:Tiff:floatppTagRetrievalFailed',...
                    'MATLAB:imagesci:Tiff:inkNamesRetrievalFailed',...
                    'MATLAB:imagesci:Tiff:countpVoidppTagRetrievalFailed',...
                    'MATLAB:imagesci:Tiff:countpDoubleppTagRetrievalFailed'})...
                    && isempty(e.cause)
                disp(e.message)
            else
                disp(e)
                e.getReport()
            end
        end
    end
end