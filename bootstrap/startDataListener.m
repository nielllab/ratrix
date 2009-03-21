function startDataListener()
%this opens up the datanet listener so that a ratrix datanet can connect to it;

setupEnvironment;
try
    pnet('closeall');
    data = datanet('data','localhost')
    quit = waitForCommandsAndSendAck(data)
    stop(data)
catch ex
    disp(['CAUGHT ER: ' getReport(ex)])
    stop(data)
end