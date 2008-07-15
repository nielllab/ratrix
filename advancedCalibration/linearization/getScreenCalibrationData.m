function [luminanceData, details] = getScreenCalibrationData(trialManager,sensorMode, calibrationPhase,screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame, interValueRGB,background,parallelPortAddress,framePulseCode, skipSyncTest, batch)
% getSynchronizedScreenCalibrationData(t,'string','daq',[],[0 0 .3 .3],int8(10),int8(10),repmat(linspace(0,1,2^8)',1,3),uint8(8),uint8(round(2^8/2)*ones(1,1,3)),uint8(rand(1000)*(2^8-1)),'B888',int8(1));
% see the arguments of generateScreenCalibrationData minus the last five
% except for 'skipSyncTest', which is the last

if isempty(parallelPortAddress)
    parallelPortAddress='B888';
end
hex2dec(parallelPortAddress);

if isempty(framePulseCode)
    framePulseCode=int8(1);
elseif framePulseCode<1 || framePulseCode>8 || ~isinteger(framePulseCode)
    error('framePulseCode must be integer 1 <= framePulseCode <= 8')
end

totalFrames = size(stim,4);
details = [];
repeatsPreAllocated = 10;
switch sensorMode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'spyder'
        useSpyder = 1;
        doDaq = 0;

        spyderData = nan(totalFrames, 3, repeatsPreAllocated);
        %for i = 1:repeatsPreAllocated
        i = 0;
        goodEnough = 0;
        while ~goodEnough
            i = i+1;
            if i > 1
                positionFrame = [];
            end
            spyderData(:, :, i) =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, skipSyncTest);
            % luminance is the Y value, which is the second entry in spyderData; %[xyY] = XYZToxyY(spyderData')'
            luminanceData = reshape(spyderData( :, 2, : ), totalFrames, max(repeatsPreAllocated,i));
            goodEnough = qualityCheck(trialManager, luminanceData, calibrationPhase, batch);
        end
        %end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'daq'
        % TODO: start recordScreenCalibrationData.m on Data Acquisition Computer
%         inputdlg('please start recordScreenCalibrationData.m', 'ok');

        useSpyder = 0;
        doDaq = 0; % this is set to = 0, because data is recorded remotely
        daqPath = '\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\daqXfer\Calibration'; % need to pass the daqPath
        daqPlot = 0;


        luminanceData = nan(totalFrames, repeatsPreAllocated);


        %%[junk, daqData] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, skipSyncTest);
        %[junk, daqData] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, skipSyncTest);

        %%% Tell Daq to start %%%%%%%
        go=1;
        calibrationDone = 0;
        thisStimRunning = 0;
        doingQualityCheck = 0;
        qualityCheckDone = 0;
        save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck', 'qualityCheckDone','thisStimRunning', 'calibrationDone', 'go');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        commandReturn = load(fullfile(daqPath,'commandReturn.mat'));

        %for i = 1:repeatsPreAllocated
        i = 0;
        goodEnough = 0;
        while ~goodEnough
            i = i+1;
            disp(sprintf('########### Calibration Round %d ##########', i));
            %%%%%%%% sets command.thisStimRunning ==1 %%%%%
            thisStimRunning = 1;
            qualityCheckDone = 0;
            save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck', 'qualityCheckDone','thisStimRunning', 'calibrationDone', 'go');
            pause(1);
            %%%%%%% waits for commandReturn.isRecording ==1
            waitingForRecording=1;
            while waitingForRecording
                display('waiting for commandReturn.isRecording == 1');
                commandReturn = load(fullfile(daqPath,'commandReturn.mat'));

                if commandReturn.isRecording==1
                    waitingForRecording=0;
                else
                    pause(1);
                end
            end

            %%%%%%% now generate calibration data %%%%%%%%%%

            if i > 1
                positionFrame = [];
            end

            [junk, daqDataJunk, ifi] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, daqPlot, skipSyncTest);
            details.ifi = ifi;
            %%  [junk, daqData] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,[],[],interValueRGB,[],parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath);
            %%%%%%% resets command.thisStimRunning == 0 %%%%%%
            thisStimRunning = 0;
            save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck', 'qualityCheckDone','thisStimRunning', 'calibrationDone', 'go');
            pause(1);

            %%%%%%% waits for commandReturn.isRecording == 0 %%%%%
            waitingForRecordingToEnd=1;
            while waitingForRecordingToEnd == 1
                commandReturn = load(fullfile(daqPath,'commandReturn.mat'))
                display('waiting for isRecording == 0');
                if commandReturn.isRecording==0
                    waitingForRecordingToEnd=0;
                else
                    pause(1);
                end
            end


            %%%%%% say if quality check is done

            recordingFile = fullfile(daqPath, sprintf('calibrationData-%d.daq', i));
            [fullDaqData,time,abstime,events,daqinfo] = daqread(recordingFile);

            [luminanceData(:,i), rawFirstFrame] = calculateIntensityPerFrame(fullDaqData, 'integral', daqinfo.ObjInfo.SampleRate, ifi, numFramesPerValue);
            details.sampleFrame = rawFirstFrame;
            fullDaqData = [];
         
            goodEnough = qualityCheck(trialManager, luminanceData, calibrationPhase, batch);
            %%%%%% sets command.calibrationDone == 1 if last stim round %%%%%%%%%%
            if goodEnough                
                qualityCheckDone = 1;
                calibrationDone = 1;
                go = 0;
                save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck', 'qualityCheckDone','thisStimRunning', 'calibrationDone', 'go');
                pause(1);
            else
                calibrationDone = 0;
%                 go = 0;
                pause(1);
            end
            qualityCheckDone = 1;
            save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck', 'qualityCheckDone','thisStimRunning', 'calibrationDone', 'go');
            pause(1);
        end
        
    otherwise
        display('no sensormode found');
        luminanceData = [];
end

%only return actual measurements (not unused preallocated stuff)
haveDate=find(~isnan(sum(luminanceData)));
luminanceData=luminanceData(:,haveDate);
