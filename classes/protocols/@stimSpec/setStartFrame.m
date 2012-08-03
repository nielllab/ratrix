function s=setStartFrame(s,startFrame)
%this should be rearchitected to be called by the stimSpec constructor
%error validation should occur here
%until then, we play loose

s.startFrame=startFrame;
end