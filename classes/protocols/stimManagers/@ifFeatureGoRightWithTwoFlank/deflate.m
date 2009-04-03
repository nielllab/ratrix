function s=deflate(s)
%method to deflate stim patches

s.cache.mask =[];
s.cache.goRightStim=[];
s.cache.goLeftStim=[];
s.cache.flankerStim=[];
s.cache.distractorStim = [];
s.cache.distractorFlankerStim= [];


% choose to keep sweep values in record
% if ~isempty(s.dynamicSweep) 
%     if strcmp('manual', s.dynamicSweep.sweepMode{1})
%         %don't do anything, 
%     else
%     dynamicSweep.sweptValues=[];
%     end
% end

%choose to keep
% s.cache.textures % just numbers, not always there
% s.cache.typeSz % just numbers for debugging, not always there
