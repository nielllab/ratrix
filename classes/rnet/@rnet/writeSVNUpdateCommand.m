function writeSVNUpdateCommand(r,targetRevision)
% svnPath = GetSubversionPath;
% % Don't specify revision if not given
% if ~exist('targetRevision')
%     targetRevision = '';
% end
% 
% rPath=getRatrixPath;
% rPath=rPath(1:end-1); %windows svn requires no trailing slash 
% update=[svnPath 'svn update '  targetRevision '"' rPath '"'  ]; 

if ~exist('targetRevision')
    error('disallowing empty args to svn update command')
     targetRevision = '';
end

switch r.type
    case r.constants.nodeTypes.SERVER_TYPE
        save([getRatrixPath 'updateServer.mat'],'targetRevision');
    case r.constants.nodeTypes.CLIENT_TYPE
        save([getRatrixPath 'updateClient.mat'],'targetRevision');
    otherwise
        error('writeSVNUpdateCommand(): Unkown rnet object type')
end

'updating to version:'
targetRevision