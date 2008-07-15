function fullscreen(h) 
%FULLSCREEN Set the figure to the size of the screen. 
% FULLSCREEN Sets the current figure to the full size. 
% FULLSCREEN(H) Sets the handle H of a figure to the full size. 
 
% Copyright 2001 The MathWorks, Inc. 
 
if nargin == 0 
  h = gcf; 
end 
 
if ~ishandle(h) | ~strcmp(get(h,'Type'),'figure') 
  error('Must supply handle to a current figure') 
end 
 
ss = get(0,'ScreenSize'); 
ss_4 = ss(4); 
mb = get(h,'MenuBar'); 
if strcmp(mb,'none') 
  if ss_4 == 1024 
    ss(4) = 1005; 
  end 
  if ss_4 == 768 
    ss(4) = 749; 
  end 
  if ss_4 == 600 
    ss(4) = 581; 
  end 
  if ss_4 == 480 
    ss(4) = 461; 
  end 
elseif strcmp(mb,'figure') 
  if ss_4 == 1024 
    ss(4) = 956; 
  end 
  if ss_4 == 768 
    ss(4) = 700; 
  end 
  if ss_4 == 600 
    ss(4) = 532; 
  end 
  if ss_4 == 480 
    ss(4) = 412; 
  end 
else 
  return 
end 
set(h,'Position',ss)