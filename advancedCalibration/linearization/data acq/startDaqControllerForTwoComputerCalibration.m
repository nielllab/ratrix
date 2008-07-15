% This function communicates with the calibration main program through the command.mat and commandReturn.mat files
% The calibration program updates command.mat, which will be read by this function. In response, this function writes into the commandReturn.mat file. They are set up to synchronize the timing between Daq input and Stim display
function startDaqControllerForTwoComputerCalibration()
global initialize
initialize = [];
recordScreenCalibrationData;

function recordScreenCalibrationData()
global initialize
daqPath = '\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\daqXfer\Calibration';
%clear all
close all
%clc
format long g

numChans=2;
sampRate=50000;
doPlot = 1;
% recordingFile = fullfile(daqPath, 'calibrationData.daq');

%%%%%%%%%%%%%%%%%%%%% INITIALIZATION %%%%%%

if isempty(initialize)
    [doingQualityCheck, qualityCheckDone, thisStimRunning, calibrationDone, go, isRecording]  = initialization(daqPath);
else

    go = 0;
    calibrationDone = 0;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
doWaitForGoFile(daqPath, go);  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

numberOfCalibrationRun = 1;

while calibrationDone == 0 %&& goodEnough == 0 % calibration not finished and not good enough
    disp(sprintf('\n########### Calibration Round %d ############\n', numberOfCalibrationRun));

    %%%%%%%%% waits for command.thisStimRunning == 1 %%%%%%%
    waitingForStimToFinish = 1; % local variable
    while waitingForStimToFinish == 1 
        command = load(fullfile(daqPath, 'command.mat'));
        display('waiting for the previous stim to finish ...');
        if command.thisStimRunning == 1 
            thisStimRunning = command.thisStimRunning;
            waitingForStimToFinish = 0;
        else
            pause(1);
        end
    end

    %%%%%%%%%% starts daq %%%%%%%%%%%%%%%%%%%%%%%%%
    recordingFile = fullfile(daqPath, sprintf('calibrationData-%d.daq', numberOfCalibrationRun));
    [ai chans recordFile]=openNidaqForAnalogRecording(numChans,sampRate,[-1 1;-1 6],recordingFile);

    ai;
    set(ai);
    get(ai);
    get(ai,'Channel');
    daqhwinfo(ai);

    chans;
    set(chans(1));
    get(chans(1));

    start(ai);
    doPlot=1;
    runSecs=2;
    waitBtw=.5;

    %%%%%%%%% sets commandReturn.isRecording == 1 %%%%%%%%%%
    isRecording = 1;
    save(fullfile(daqPath, 'commandReturn.mat'), 'isRecording'); % tells the controller that the Daq has started on this particular stim
    display('isRecording set to == 1');

    while thisStimRunning == 1 %while the stim file is running
        pause(1);
        WaitSecs(waitBtw);

        if doPlot
            data=peekdata(ai,get(ai,'SamplesAvailable'));
            plot(data(floor(linspace(1,size(data,1),1000)),:))
            drawnow
        end
        command = load(fullfile(daqPath, 'command.mat'));
        thisStimRunning = command.thisStimRunning; % while loop ends when thisStimRunning gets set to == 0 by calibration file

        % Check to see if either the calibration is done, otherwise wait until next go command
        % calibrationRunning = checkIfCalibrationDone(daqPath); % this will end the while loop, if needed

    end

    %%%%%%%% sets commandReturn.isRecording == 0 %%%%%%%%%%%%%
    stop(ai);
    delete(ai);
    clear ai;

    isRecording = 0;
    save(fullfile(daqPath, 'commandReturn.mat'), 'isRecording'); % tells the controller that Daq has stopped on this stim
    pause(1);
    display('isRecording set to == 0');

    %%%%%%%% checks for command.CalibraionDone == 1 %%%%%%%%%%
    qualityCheckDone = 0; % local variable
    while qualityCheckDone ==0

        disp('waiting for qualityCheckDone signal == 1')
        command = load(fullfile(daqPath, 'command.mat'));

        if command.qualityCheckDone == 1
            qualityCheckDone = command.qualityCheckDone;
        else
            pause(1);
        end
    end

    %%%%%%%% check for calibrationDone %%%%%%%%%
    disp('checking for calibrationDone signal');
    if command.calibrationDone == 1
        calibrationDone = command.calibrationDone;
        disp('calibration done !');
    else
        numberOfCalibrationRun = numberOfCalibrationRun + 1;
    end
end
%doWaitForGoFile(daqPath); % this will wait until the next go command

%%%%%%%% This Section will be a different function %%%%%%%%%%
if doPlot
    [data,time,abstime,events,daqinfo] = daqread(recordFile);
    figure
    plot(data)

    abstime
    events
    events.Type
    events.Data

    daqinfo
    daqinfo.ObjInfo
    daqinfo.HwInfo

    chaninfo = daqinfo.ObjInfo.Channel
    events = daqinfo.ObjInfo.EventLog
    event_type = {events.Type}
    event_data = {events.Data}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
checkProcessComplete(daqPath); %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [doingQualityCheck, qualityCheckDone, thisStimRunning, calibrationDone, go, isRecording] = initialization(daqPath)
global initialize
doingQualityCheck = 0;
qualityCheckDone = 0;
thisStimRunning = 0;
calibrationDone = 0;
go = 0;
save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck','qualityCheckDone', 'thisStimRunning', 'calibrationDone', 'go');

isRecording = 0;
save(fullfile(daqPath, 'commandReturn.mat'), 'isRecording'); % initialize the two variables to false

initialize = 100

function checkProcessComplete(daqPath)
pause(1);
disp(sprintf('checking if need to restart recordScreenCalibrationData \n'));
processComplete = load(fullfile(daqPath, 'processComplete.mat'));
if processComplete.complete ==0
    display(sprintf('calibration not finished, restart recordScreenDalibrationData \n'));
    recordScreenCalibrationData;
else
    display(sprintf('calibration complete \n'));
    
end

function doWaitForGoFile(daqPath, go)
disp(sprintf('waiting for goFile\n'));
startTime = now;
while ~go
    display(sprintf('have waited for %d', now - startTime));
    command = load(fullfile(daqPath, 'command.mat'));
    go =  command.go;
    pause(1);
end
