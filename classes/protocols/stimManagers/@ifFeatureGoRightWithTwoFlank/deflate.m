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
