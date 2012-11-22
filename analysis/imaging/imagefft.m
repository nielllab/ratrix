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

multiTif=1;

if multiTif
  
    in(1:end-5)
    [out frameT]=readMultiTif(in(1:end-5));
end

out = double(out);
meanImage = mean(out,3)- mean(out(:))+10^-10;
imagesc(meanImage)
fftImage = fft2(meanImage);
imagesc(log(fftshift(abs(fftImage))))
