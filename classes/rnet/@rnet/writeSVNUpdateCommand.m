function writeSVNUpdateCommand(r,targetURL,targetRevNum)
checkTargetRevision({targetURL,targetRevNum});

switch r.type
    case r.constants.nodeTypes.SERVER_TYPE
        save([getRatrixPath 'updateServer.mat'],'targetURL','targetRevNum');
    case r.constants.nodeTypes.CLIENT_TYPE
        save([getRatrixPath 'updateClient.mat'],'targetURL','targetRevNum');
    otherwise
        error('writeSVNUpdateCommand(): Unkown rnet object type')
end

'updating to version:'
targetURL
targetRevNum