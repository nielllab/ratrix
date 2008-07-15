function out=getStimPatch(s,patchType,showIm)
%out=getStimPatch(s,patchType,showIm)
%im=getStimPatch(s,'right',1) where patchType is: 'right','left' or 'flanker'


switch patchType
    case 'right'
        out=s.goRightStim;
    case 'left'
        out=s.goLeftStim;
    case 'flanker'
        out=s.flankerStim;
    otherwise
        error('patch type must be right, left or flanker ')
end

if ~exist('showIm','var')
    showIm=0
end

if showIm
    imshow(out(:,:,1))
end