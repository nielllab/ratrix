function writeSVNUpdateCommand(targetURL,targetRevNum)
checkTargetRevision({targetURL,targetRevNum});

save([getRatrixPath 'update.mat'],'targetURL','targetRevNum');

'updating to version:'
targetURL
targetRevNum