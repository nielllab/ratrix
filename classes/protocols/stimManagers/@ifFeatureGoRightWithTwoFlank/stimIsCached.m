function isCached=stimIsCached(s)
%method to determine if it is cached

if size(s.cache.mask,1)>0
    isCached=1;
        
%     %confirm all there
%     if size(s.goRightStim,1)>0 & size(s.goLeftStim,1)>0 & size(s.flankerStim,1)>0
%         %okay
%     else
%         error('partially inflated stim')
%     end
    
else
    isCached=0;
end

