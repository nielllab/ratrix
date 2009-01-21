cd('C:\Documents and Settings\rlab.RLAB_RIG1B\Desktop\fanDev\bootstrap');
setupEnvironment;
ListenChar(1)
cd('..');
pnet('closeall');
data = datanet('data','localhost')

quit = waitForCommandsAndSendAck(data)
