function out=isDynamicRender(stimulus);

%faster (it might get called in the real time loop)
out = ~isempty(strfind(stimulus.renderMode,'dynamic'));

%slower
%out=ismember(stimulus.renderMode,{'dynamic-precachedInsertion','dynamic-maskTimesGrating','dynamic-onePatchPerPhase','dynamic-onePatch'});