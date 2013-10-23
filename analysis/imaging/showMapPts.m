function pts =showMapPts(imhandle,pts )
%plot map points on a figure
if ~exist('imhandle','var') | isempty(imhandle)
   [f,p] = uigetfile('*.fig','reference map');
open(fullfile(p,f))
else
    figure(imhandle)
end
hold on

if ~exist('pts','var') | isempty(pts)
    
  [f,p] = uigetfile('*.mat','map points');
load(fullfile(p,f))
end

plot(pts(:,2),pts(:,1),'g*');
plot(pts(:,2),pts(:,1),'bo');

