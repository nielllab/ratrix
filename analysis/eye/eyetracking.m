clear all
profile on

name = '08_26_15_prelis_eye.mat' %epxeriment name
% name = '08_26_15_postlis_eye.mat'
load(name); % should be a '*_eye.mat' file

% figure
% imshow(data(:,:,1)
% [x y] = ginput(3)
% xoff = x(1)
% yoff = y(1)

rad_range = [5 15]; % range of radii to search for
xoff = 0; %to center ROI
yoff = -5; %to center ROI
W=25; % pixel range ROI for imfindcircles
thresh = 0.17 %pupil threshold

data = squeeze(data); % the raw images...
xc = size(data,2)/2 + xoff; % image center
yc = size(data,1)/2 + yoff;
warning off;

bindata = double(data); %convert from uint8 into doubles and threshold
for i = 1:size(data,3);
    bindata(:,:,i) = bindata(:,:,i)/max(max(bindata(:,:,i)))<thresh;
end

tic
parfor n = 1:size(data,3)
    %       [center,radii,metric] = imfindcircles(squeeze(data(yc-W:yc+W,xc-W:xc+W,n)),rad_range,'Sensitivity',1);
    [center,radii,metric] = imfindcircles(bindata(yc-W:yc+W,xc-W:xc+W,n),rad_range,'Sensitivity',1);
    if(isempty(center))
        centroid(n,:) = [NaN NaN]; % could not find anything...
        area(n) = NaN;
    else
        [~,idx] = max(metric); % pick the circle with best score
        centroid(n,:) = center(idx,:);
        area(n) = pi*radii(idx)^2;
    end
end
toc

% figure
% imshow(data(yc-W:yc+W,xc-W:xc+W));
% hold on
% circle(eye(i).Centroid(2),eye(i).Centroid(1),eye(i).Area)
% hold off

% imshow(data(:,:,1))
% for i=i:size(data,3)/100
%    eye(i).Centroid(1) = yc - (yc - eye(i).Centroid(1));
%    eye(i).Centroid(2) = xc - (xc - eye(i).Centroid(2));
% end
save(name, 'centroid','area', '-append'); % append the motion estimate data...
profile viewer

figure
hold on
plot(0.1:0.1:size(data,3)/10,sqrt(area/pi),'b-')
plot(0.1:0.1:size(data,3)/10,centroid(:,1),'.g')
plot(0.1:0.1:size(data,3)/10,centroid(:,2),'.r')
hold off
legend('area','x pos','ypos')

% %
figure
for i = size(data,3)
    imshow(bindata(yc-W:yc+W,xc-W:xc+W,i));
    colormap gray
    hold on
    circle(centroid(i,1),centroid(i,2),area(i))
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