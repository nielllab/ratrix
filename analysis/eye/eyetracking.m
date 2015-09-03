clear all
close all

name = 'trial5'; %data file
thresh = 0.85; %pupil threshold for binarization
pupercent = 0.15; %set range pupil radius window
pupchange = 0.35; %acceptable percent change in radius per framerange
framerange = 3; %number of frames to smooth over

load(name);
data = squeeze(data);
warning off;

%user input to select center and right points
printf('Please select pupil center and top, eyeball top and right points, outside pupil')
h = figure('units','normalized','outerposition',[0 0 1 1])
imshow(data(:,:,1))
[cent] = ginput(5);
close(h);
yc = cent(1,2); %pupil center y val
xc = cent(1,1); %pupil center x val
horiz = (cent(4,1) - xc); %1/2 x search range
vert = (yc - cent(3,2)); %1/2 y search range
puprad = yc - cent(2,2); %initial pupil radius
puprange = [round(puprad - puprad*pupercent) round(puprad + puprad*pupercent)]; %range of pupil sizes to search over

%convert from uint8 into doubles and threshold, then binarize
ddata = double(data); 
binmaxx = cent(5,1);
binmaxy = cent(5,2);
for i = 1:size(data,3)
    binmax(i) = mean(mean(mean(ddata(binmaxy-3:binmaxy+3,binmaxx-3:binmaxx+3,i))));
end
for i = 1:size(ddata,3)
    bindata(:,:,i) = (ddata(yc-vert:yc+vert,xc-horiz:xc+horiz,i)/binmax(i) < thresh);
end

tic
centroid = nan(size(data,3),2);
rad = nan(size(data,3),1);
centroid(1,:) = [horiz vert];
rad(1,1) = puprad;
for n = 2:size(data,3)
    [center,radii,metric] = imfindcircles(bindata(:,:,n),puprange,'Sensitivity',0.995,'ObjectPolarity','bright');
    if(isempty(center))
        centroid(n,:) = [NaN NaN]; % could not find anything...
        rad(n) = NaN;
    else
        [~,idx] = max(metric); % pick the circle with best score
        centroid(n,:) = center(idx,:);
        rad(n,:) = radii(idx);
    end
    if n>framerange && (isnan(rad(n-1)) | isnan(rad(n))) %if it's a nan or preceeded by all nans don't change puprange
        puprange = puprange;
    elseif n>framerange && (abs(1 - rad(n)/nanmean(rad(n-framerange:n-1))) > pupchange) %if % change is bigger than specified don't change puprange
        puprange = puprange;
    elseif n>framerange && (rad(n)>nanmean(rad(n-framerange:n-1))) %if radius goes up, shift range up
        puprange = puprange + round(rad(n) - nanmean(rad(n-1)));
    elseif n>framerange && (rad(n)<nanmean(rad(n-framerange:n-1))) %if radius goes down, shift range down
        puprange = puprange - round(nanmean(rad(n-1)) - rad(n));
    else
        puprange = puprange;
    end
end
toc

% figure
% imshow(data(yc-W:yc+W,xc-W:xc+W));
% hold on
% circle(eye(i).Centroid(2),eye(i).Centroid(1),eye(i).Area)
% hold off

% imshow(data(:,:,1))
% for i=i:size(data,3)
%    eye(i).Centroid(1) = yc - (yc - eye(i).Centroid(1));
%    eye(i).Centroid(2) = xc - (xc - eye(i).Centroid(2));
% end
save(name, 'centroid','area', '-append'); % append the motion estimate data...
% profile viewer

figure
hold on
plot(0.1:0.1:size(data,3)/10,sqrt(rad/pi),'b-')
plot(0.1:0.1:size(data,3)/10,centroid(:,1),'.g')
plot(0.1:0.1:size(data,3)/10,centroid(:,2),'.r')
hold off
legend('area','x pos','ypos')

% %
figure
for i = 1:size(data,3)
    subplot(1,2,1)
    imshow(data(yc-vert:yc+vert,xc-horiz:xc+horiz,i));
    colormap gray
    hold on
    circle(centroid(i,1),centroid(i,2),rad(i))
    %     viscircles([eye(i).Centroid(1) eye(i).Centroid(2)],sqrt(eye(i).Area)/pi);
    drawnow
    hold off
    
    subplot(1,2,2)
    imshow(bindata(:,:,i));
    colormap gray
    hold on
    circle(centroid(i,1),centroid(i,2),rad(i))
    %     viscircles([eye(i).Centroid(1) eye(i).Centroid(2)],sqrt(eye(i).Area)/pi);
    drawnow
    hold off
    
end




% figure
% % for i = 1:size(data,3)
%     imshow(data(:,:,3712))
%     colormap gray
%     drawnow
% end