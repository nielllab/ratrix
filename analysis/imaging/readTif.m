function out = readTif(in)
clc
close all
dbstop if error
colormap gray

intf = [in '.tif'];
info = imfinfo(intf);
n = length(info);

disp('loading tiff')
tic
out = arrayfun(@(x)imread(intf,x,'Info',info),1:n,'UniformOutput',false); %can't read "subimages" (see detailedTif())
% for multi-image TIFF, providing 'Info' speeds up read
toc

out = cell2mat(reshape(out,[ones(1,2) n]));

doDetailed = false;
if doDetailed
    frames = detailedTif(intf);
else
    imagesc(mean(double(out),3));
end

makeAVI = true;
if makeAVI
    n = size(out,3);
    
    %rect = [950 600 500 650]; %left top width height
    rect = [950 450 800 900];
    
    hold on
    plot(rect(1)+rect(3)*[0 0 1 1 0],rect(2)+rect(4)*[0 1 1 0 0],'r-')
    writeAVI(in,out(rect(2)+(0:rect(4)-1),rect(1)+(0:rect(3)-1),1:n));
end
end

function writeAVI(f,in)
if numel(in)>2000*2000*100 %writes in ~20sec
    %we could write frame-by-frame in this case...
    error('sending too much to writeVideo freezes computer')
end

disp('normalizing')
tic
if false
    in = normalizePerFrame(in);
else
    in = prctileNormalize(in,.25*[1 -1]+[0 1]*100);
end

if min(in(:)) ~= 0 || max(in(:)) ~= intmax('uint8') || ~isa(in,'uint8')
    error('normalizing error')
end
toc

disp('writing avi')
tic
avi = VideoWriter([f '.avi'],'Uncompressed AVI');
open(avi);
writeVideo(avi,permute(in,[1 2 4 3]));
close(avi);
toc
end

function in = prctileNormalize(in,p)
in = double(in);
p = prctile(in(:),p); %this has to sort all pixels -- could subsample if too slow
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