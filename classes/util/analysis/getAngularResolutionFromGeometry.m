function [vRes hRes]=getAngularResolutionFromGeometry(xbins,ybins,eyeToMonitorMm, stimRectFraction, eyeAboveMonitorCenterMm, monitorImSizeMm)
%given the geometry of the monitor setup, return the resolution of the stixels in degrees
%[vRes hRes]=getAngularResolutionFromGeometry(xbins,ybins,eyeToMonitorMm,[stimRectFraction=full screen], [eyeAboveMonitorCenterMm=-25], [monitorImSizeMm=trinitron])
%example:  
%[vRes hRes]=getAngularResolutionFromGeometry(16,12,330);
%
% xbins=10;                          % the number of bins across the the width of the screen, or normalized edges default [1]
% ybins=10;                          % the number of bins across the the hieght of the screen, or normalized edges default[1]
% eyeToMonitorMm=330;                % can't trust this to be right, linear track
% stimRectFraction=[0 0 1 1];        % position of grid on screen in normizled units, def whole screen
% monitorImSizeMm=[400,290];         % measured to 10mm acc on 061122
% eyeAboveMonitorCenterMm=-25;       % roughly measured on Oct 16, 2006;  to be adjusted based on input from JackHeight
% eyeRightOfMonitorCenterMm=0;       % should always be zero in our setup

if ~exist('stimRectFraction','var') || isempty(stimRectFraction)
    stimRectFraction=[0 0 1 1]; 
end

if ~exist('monitorImSizeMm','var') || isempty(monitorImSizeMm)
    monitorImSizeMm=[400,290]; 
end

if ~exist('eyeAboveMonitorCenterMm','var') || isempty(eyeAboveMonitorCenterMm)
    eyeAboveMonitorCenterMm=-25; 
end

if ~exist('eyeRightOfMonitorCenterMm','var') || isempty(eyeRightOfMonitorCenterMm)
    eyeRightOfMonitorCenterMm=0; 
end

if iswholenumber(xbins) && all(size(xbins)==1)
    edgesXfraction=linspace(0,1,xbins+1);  % fraction of stim patch
elseif all(xbins>=0) && (xbins<=1) 
    edgesXfraction=xbins;
else
    error('xbins must be a single whole number of bins, or a vector of edges between zero and 1')
end

if iswholenumber(ybins) && all(size(ybins)==1)
    edgesYfraction=linspace(0,1,ybins+1);  % fraction of stim patch
elseif all(ybins>=0) && (ybins<=1) 
    edgesYfraction=ybins;
else
    error('ybins must be a single whole number of bins, or a vector of edges between zero and 1')
end


numX=length(edgesXfraction);
numY=length(edgesYfraction);
%convention increasing goes down and to the right
stimWidthMm=diff(stimRectFraction([1 3]))*monitorImSizeMm(1);
stimHeightMm=diff(stimRectFraction([2 4]))*monitorImSizeMm(2);
stimLeftPadMm=stimRectFraction(1)*monitorImSizeMm(1);
stimUpperPadMm=stimRectFraction(2)*monitorImSizeMm(2);

edgesXmm=stimWidthMm*(edgesXfraction-.5)-eyeRightOfMonitorCenterMm+stimLeftPadMm;   % center and adjust
edgesYmm=stimHeightMm*(edgesYfraction-.5)+eyeAboveMonitorCenterMm+stimUpperPadMm;   % center and adjust
[imx imy]=meshgrid(edgesXmm,edgesYmm);


%GET ANGLES OF EACH PIXEL CORNER
% note: just for this calculation:
% spacex=distance to monitor
% spacey=image x (width)
% spacez=image y (height)
[junkAngle,phi,R1]=cart2sph(eyeToMonitorMm,imx(:),imy(:));  

% note: just for this calculation:
% spacex=distance to monitor
% spacey=image y (height)
% spacez=image x (width)
[junkAngle,theta,R2]=cart2sph(eyeToMonitorMm,imy(:),imx(:));  

theta=reshape(180*theta,numY,numX); % counterclockwise angle in the depthX plane
phi=reshape(180*phi,numY,numX); % the elevation angle from the xy plane.
R=reshape(R1,numY,numX); % true distance

hRes=diff(theta,1,2);
vRes=diff(phi,1,1);
%R=R(1:numY-1,1:numX-1)+diff(R(:,1:numX-1),1,1)/2 + diff(R(1:numY-1,:),1,2)/2;  % adjust the gradient

viewOn=0;  % just for debugging
if viewOn
subplot(1,3,1); imagesc(hRes); colormap(gray); colorbar;  title('h res')
subplot(1,3,2); imagesc(vRes); colormap(gray); colorbar;  title('v res')
subplot(1,3,3); imagesc(R); colormap(gray); colorbar;  title('distance')
end