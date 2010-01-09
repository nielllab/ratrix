function [stimulus, updateSM]=postScreenResetCheckAndOrCache(stimulus,updateSM);
% if screens are not correct, then recache

%ideally, this should be the ONLY place that caching happens, and it should
%only happen once in the begining.  

%non-dynamic renders still get cached before PTB screen size is set
if isDynamicRender(stimulus) && ~stimIsCached(stimulus)
    stimulus=inflate(stimulus,{'stim'});
    updateSM=true;
else
    updateSM=updateSM; % leave as is
end


%maybe check if they are all good (both there and the right size)
%maybe check that the one after does not exist
%out=texsCorrespondToThisWindow(s,w)

expectedSize=size(stimulus.cache.mask);
texIDs=stimulus.cache.textures(:);
tic
fprintf('could save a little intertrial time by not checking texs every trial; confirming %d texs with ID: ',length(texIDs));
for i=1:length(texIDs)
    fprintf('%d.',texIDs(i));
    %txs{i}=Screen('GetImage', texIDs(i),[],[],2);
    tx=Screen('GetImage', texIDs(i),[],[],2);
    if size(tx,1)~=expectedSize(1) || size(tx,2)~=expectedSize(2)
        expectedSize
        size(tx)
        [type o p]=ind2sub(size(stimulus.cache.textures),i) %type,o,p
        i
        texIDs(i)
        %typeSz(i,:)=[type o p size(txs{i}) stimulus.cache.textures(i)];
        error('texs not the expected size... did someone change them?  check assumptions against stimulus.cache.typeSz')
    end
end
display(sprintf('took: %2.2f sec',toc))