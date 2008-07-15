function s=examplePhased(varargin)
% examplePhased  class constructor.
% just build a default examplePhased (stimManager) object with sample parameters

s.LUT =[];
s = class(s, 'examplePhased', stimManager(100,100,0,0));

s=setSuper(s,s.stimManager);

s=fillLUT(s,'useThisMonitorsUncorrectedGamma',[0 1]);



