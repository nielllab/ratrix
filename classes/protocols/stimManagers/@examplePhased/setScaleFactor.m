function s=setScaleFactor(s,sf)
% sets scaleFactor of the stimManager s

s.LUT =[];
s=class(s, 'phasedStim', stimManager(getMaxWidth(s),getMaxHeight(s),sf,getInterTrialLuminance(s)));

s=setSuper(s,s.stimManager);

s=fillLUT(s,'useThisMonitorsUncorrectedGamma',[0 1]);
