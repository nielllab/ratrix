function datanet = setup(datanet,data)
% this function takes in a datanet with a sockcon (socket) and sets up a connection to the data listener
% and starts recording from NIDAQ

gotAck = 0;

% try to connect to data listener
data_hostname = datanet.data_hostname;
if isempty(data_hostname)
    error('no data hostname found in this datanet object')
end
datanet.sockcon = pnet('tcpsocket', datanet.port); % open socket connection
datanet.con = connectToDataListener(datanet,data_hostname);
% set store path
path = fullfile(datanet.storepath,data.subjectID);
[datanet gotAck] = setStorePath(datanet, datanet.con, path);
if ~gotAck
    error('error in setting up datanet - setStorePath failed to receive ack');
end

constants = getConstants(datanet);

% set ai_parameters
if ~isempty(datanet.ai_parameters)
    commands=[];
    commands.cmd = constants.stimToDataCommands.S_SET_AI_PARAMETERS_CMD;
    commands.arg = datanet.ai_parameters; 
    [trialData,gotAck] = sendCommandAndWaitForAck(datanet, datanet.con, commands);
    if ~gotAck
        error('error in sending ai_parameters - set ai params failed to receive ack');
    end
end

% set local parameters (refreshRate, resolution)
if ~isempty(data)
    commands=[];
    commands.cmd=constants.stimToDataCommands.S_SET_LOCAL_PARAMETERS_CMD;
    commands.arg = data;
    [trialData,gotAck] = sendCommandAndWaitForAck(datanet, datanet.con, commands);
    if ~gotAck
        error('error in setting local parameters - failed to receive ack');
    end
end

% start recording
commands=[];
commands.cmd=constants.stimToDataCommands.S_START_RECORDING_CMD;
[trialData, gotAck] = sendCommandAndWaitForAck(datanet, datanet.con, commands);
if ~gotAck
    error('error in setting up datanet - start recording failed to receive ack');
end


end % end function