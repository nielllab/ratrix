function colorMap=blueToRed(mean, range, desaturationPoint)
% a usefull colormap for STAs
%   mean- the value that will take on black
%   range- [low high]; what will define the whole color space to the extrema
%   desaturationPoint - [] where desaturation begins...where the most
%   saturated point is. how far from mean to extrema.  1 is at extrema, 0 is at mean
%
% desaturationPoint must be normalized.  range is used to normalize mean.
% thus the range may be in either normalized units 0-->1 or 0-->255, as
% long as range and mean use the same units
%
% this function also contains useful subfunctions for generating custum color maps

if ~exist('mean','var') || isempty(mean)
    mean=0.5;
end
if ~exist('range','var') || isempty(range)
    range=[0 1];
end
if ~exist('desaturationPoint','var') || isempty(desaturationPoint)
    desaturationPoint=0.5;
end

centerLoc=(mean-range(1))/diff(range);
lowSaturation=centerLoc*desaturationPoint;
hiSaturation=centerLoc+((1-centerLoc)*desaturationPoint);

numPts=64; % good enough
locations=[0,lowSaturation, centerLoc, hiSaturation, 1];
colors=[.8 .8 1;% baby blue
    0 0 1;% blue
    0 0 0;% black
    1 0 0;% red
    1 .8 .8];% pink

colorMap=customColorMap(locations, colors,numPts);



function map=customColorMap(locations, colors,numPts)
%normalized locations in color map 0 is dark and 1 is white if greyscale

%error check
numColors=size(colors,1);
numLocations=length(locations);
if numLocations~=numColors
    numColors
    numLocations
    error('numColors must be the same as the numLocations')
end
if ~all(diff(locations)>0)
    locations
    error('locations must be increasing in order')
    % could sort to solve
end

%set ends to the most extreme value
if locations(1)~=0
    locations=[0 locations];
    colors=[colors(1,:); colors];
end
if locations(end)~=1
    locations=[locations 1];
    colors=[colors; colors(end,:)];
end
    
map=[];
locationInds=round(1+(locations*(numPts)));
numColors=size(colors,1);
for i=1:numColors-1
    n=diff(locationInds(i:i+1));
    thisSection=linearColorFade(colors(i,:),colors(i+1,:),n);
    map=[map; thisSection]
    if 0 %view construction process
        colormap(map)
        drawnow
        keyboard
    end
end

function fade=linearColorFade(colorA,colorB,numPts)

r=linspace(colorA(1),colorB(1),numPts);
g=linspace(colorA(2),colorB(2),numPts);
b=linspace(colorA(3),colorB(3),numPts);
fade=[r; g; b]';