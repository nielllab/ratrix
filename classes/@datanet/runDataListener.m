function runDataListener

pnet('closeall')
data = datanet('data', getIPAddress());
quit = waitForCommandsAndSendAck(data)


