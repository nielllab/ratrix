function trialManager=setUpOrStopDatanet(trialManager,flag,data)

if isempty(trialManager.datanet)
    %empty datanet?  don't do anything!
elseif strmatch(flag, 'setup')
    trialManager.datanet=setup(trialManager.datanet,data);
elseif strmatch(flag, 'stop')
    trialManager.datanet=stop(trialManager.datanet);
else
    error('flag must be setup or stop');
end


