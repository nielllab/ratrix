function out=getDirForPinNum(pinNum,dir)
spec=getBitSpecForPinNum(pinNum);

switch dir
    case 'read'
        out=true;
    case 'write'
        out=ismember(spec(2),[0 2]);
    otherwise
        error('dir must be ''read'' or ''write''')
end

% old implementation:
% spec=getBitSpecForPinNum(pinNum);
% switch spec(2)
%     case 0
%         out='both';
%     case 1
%         out='read';
%     case 2
%         out='both';
%     otherwise
%         error('bad bit spec')
% end