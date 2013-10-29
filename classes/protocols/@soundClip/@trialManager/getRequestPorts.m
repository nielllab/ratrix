function out=getRequestPorts(tm,numPorts)
% based on the requestPorts field on the base class

switch tm.requestPorts
    case 'none'
        out=[];
    case 'all'
        out=1:numPorts;
    case 'center'
        out=floor((numPorts+1)/2);
    otherwise
        error('unsupported requestPorts type');
end

end % end function