close all
clear all
dbstop if error

[cfname, cpname] = uigetfile('*.mat','eyetracking data');
cfile = fullfile(cpname,cfname);
load(cfile);
[pname fname] = fileparts(cfile)

% psfilename = 'C:\tempPS.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end

data = squeeze(data);   
warning off;

thresh = 0.9; %pupil threshold for binarization
puprange = [10 120]; %set

%user input to select center and right points
sprintf('Please select pupil center and top, eyeball top and right points, darkest part of eyeball')
h1 = figure('units','normalized','outerposition',[0 0 1 1])
imshow(data(:,:,10))
[cent] = ginput(5);
close(h1);
yc = cent(1,2); %pupil center y val
xc = cent(1,1); %pupil center x val
horiz = (cent(4,1) - xc); %1/2 x search range
vert = (yc - cent(3,2)); %1/2 y search range
puprad = yc - cent(2,2); %initial pupil radius
% puprange = [round(puprad - puprad*pupercent) round(puprad + puprad*pupercent)]; %range of pupil sizes to search over
ddata = double(data); 
binmaxx = cent(5,1);
binmaxy = cent(5,2);

for i = 1:size(data,3)
    binmax(i) = mean(mean(mean(ddata(binmaxy-3:binmaxy+3,binmaxx-3:binmaxx+3,i))));
end
for i = 1:size(ddata,3)
    bindata(:,:,i) = (ddata(yc-vert:yc+vert,xc-horiz:xc+horiz,i)/binmax(i) > thresh);
end

%convert from uint8 into doubles and threshold, then binarize

tic
centroid = nan(size(data,3),2);
rad = nan(size(data,3),1);
centroid(1,:) = [horiz vert];
rad(1,1) = puprad;
for n = 2:size(data,3)
    [center,radii,metric] = imfindcircles(bindata(:,:,n),puprange,'Sensitivity',0.995,'ObjectPolarity','dark');
    if(isempty(center))
        centroid(n,:) = [NaN NaN]; % could not find anything...
        rad(n) = NaN;
    else
        [~,idx] = max(metric); % pick the circle with best score
        centroid(n,:) = center(idx,:);
        rad(n,:) = radii(idx);
    end
end
toc

h4 = figure
for i = 1:size(data,3)
 
    subplot(1,2,1)
    imshow(data(yc-vert:yc+vert,xc-horiz:xc+horiz,i));
    colormap gray
    hold on
    circle(centroid(i,1),centroid(i,2),rad(i))
    drawnow
    hold off
    
    subplot(1,2,2)
    imshow(bindata(:,:,i));
    colormap gray
    hold on
    circle(centroid(i,1),centroid(i,2),rad(i))
    drawnow
    hold off 
%     mov(i) = getframe(gcf)
%     vid = VideoWriter('predoi_tracking.avi')
%     open(vid); writeVideo(vid,mov); close(vid)
end

% save(cfile,'centroid','rad','-append'); %save data back to .mat file

% set(gcf, 'PaperPositionMode', 'auto');
% print('-dpsc',psfilename,'-append');
%     
% [f p] = uiputfile('*.pdf','pdf name');
% ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,f));
% delete(psfilename);