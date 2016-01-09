%This analysis takes in a .mat file with eyetracking data in the form of a
%3-dimensional array "data(xpixel,ypixel,frame)" output from imaqtool. It
%binarizes the images and fits a circle to the pupil. Depending on the
%image levels and the pupil size in pixels you'll want to adjust the
%threshold and pupil range. Upon running the code, you'll be prompted to
%select points on an image to improve the analysis: 1) pupil center, 2) top
%edge of pupil, 3) top edge of eyeball, 4) right edge of eyeball, 5)
%darkest part of the eyeball. The analysis outputs the centroid (X/Y) of
%the pupil center and the radius of the pupil. Any frame where a circle
%could not be fit will contain NAN values. The code currently commented out
%is intended for closed loop analysis - it uses recent sizes and locations
%to guess the next ones to improve tracking under conditions with more eye
%movement and pupil size changes. It's still a bit buggy.

%This code builds off Scanbox code by Dario
%Ringach and was developed by P.R.L. Parker and A.M. Michaiel under C.M.
%Niell in 2015.

close all
clear all
%% Set file info and analysis parameters
dir = '\\niell-V2-W7\Angie_tanks\eyetracking data\12_14_15\'; %file location
name = '12_14_15_darkpre.mat'; %data file
thresh = 0.85; %pupil threshold for binarization
puprange = [15 40]; %set

%%closed loop parameters
% pupercent = 0.15; %set range pupil radius window
% pupchange = 0.25; %acceptable percent change in radius per framerange
% framerange = 1; %number of frames to smooth over
%% 
load(name);
data = squeeze(data);
warning off;

%user input to select center and right points
sprintf('Please select pupil center and top, eyeball top and right points, darkest part of eyeball')
h1 = figure('units','normalized','outerposition',[0 0 1 1])
imshow(data(:,:,1))
[cent] = ginput(5);
close(h1);
yc = cent(1,2); %pupil center y val
xc = cent(1,1); %pupil center x val
horiz = (cent(4,1) - xc); %1/2 x search range
vert = (yc - cent(3,2)); %1/2 y search range
puprad = yc - cent(2,2); %initial pupil radius
% puprange = [round(puprad - puprad*pupercent) round(puprad + puprad*pupercent)]; %range of pupil sizes to search over

%convert from uint8 into doubles and threshold, then binarize
ddata = double(data); 
binmaxx = cent(5,1);
binmaxy = cent(5,2);
for i = 1:size(data,3)
    binmax(i) = mean(mean(mean(ddata(binmaxy-3:binmaxy+3,binmaxx-3:binmaxx+3,i))));
end
for i = 1:size(ddata,3)
    bindata(:,:,i) = (ddata(yc-vert:yc+vert,xc-horiz:xc+horiz,i)/binmax(i) > thresh);
end
figure
imshow(bindata(:,:,100))

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
    %%closed loop execution
%     if n>framerange && (isnan(rad(n-1)) | isnan(rad(n))) %if it's a nan or preceeded by all nans don't change puprange
%         puprange = puprange;
%     elseif n>framerange && (abs(1 - rad(n)/nanmean(rad(n-framerange:n-1))) > pupchange) %if % change is bigger than specified don't change puprange
%         puprange = puprange;
%     elseif n>framerange && (rad(n)>nanmean(rad(n-framerange:n-1))) %if radius goes up, shift range up
%         puprange = puprange + round(rad(n) - nanmean(rad(n-1)));
%     elseif n>framerange && (rad(n)<nanmean(rad(n-framerange:n-1))) %if radius goes down, shift range down
%         puprange = puprange - round(nanmean(rad(n-1)) - rad(n));
%     else
%         puprange = puprange;
%     end
end

%plot x and y position and radius across experiment
h2 = figure
hold on
plot(0.1:0.1:size(data,3)/10,rad,'b-')
plot(0.1:0.1:size(data,3)/10,centroid(:,1),'.g')
plot(0.1:0.1:size(data,3)/10,centroid(:,2),'.r')
hold off
legend('radius','x pos','ypos')

%plot the measured circles over the video
figure
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
    
end

save(fullfile(dir,name),'centroid','rad','h2','-append');


