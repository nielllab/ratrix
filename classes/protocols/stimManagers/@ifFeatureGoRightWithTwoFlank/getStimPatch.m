function out=getStimPatch(s,patchType,showIm)
%out=getStimPatch(s,patchType,showIm)
%im=getStimPatch(s,'right',1) where patchType is: 'right','left' or 'flanker'
%imagesc(reshape(patch(:,:,1,1),size(patch,1),size(patch,2)))

switch patchType
    case 'right'
        out=s.cache.goRightStim;
    case 'left'
        out=s.cache.goLeftStim;
    case 'flanker'
        out=s.cache.flankerStim;
    otherwise
        error('patch type must be right, left or flanker ')
end

if ~exist('showIm','var')
    showIm=0;
end

if showIm
    imshow(out(:,:,1,1));
end