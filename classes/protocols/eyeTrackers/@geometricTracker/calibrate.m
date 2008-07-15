function et=calibrate(et)
%gets the calibration values from the user

method='prompt';
switch method
    case 'none'
        %do nothing
    case 'mfile'
        previousValues=getCurrentCalibrationValues(et);
        edit ('eyeLinkTracker/getCurrentCalibrationValues')
        pause
        
        values=getCurrentCalibrationValues(et);

        if previousValues.counter+1~=values.counter
            previousValues.counter
            values.counter
            error ('user failed to update counter and save currentCalibrationValues.');
        end

        %         et.eyeToMonitorTangentMm=[];      %measured 24 cm on 061122;   to be adjusted based on input from HorizTrack
        %         et.eyeAboveMonitorCenterMm=[];    %roughly measured on Oct 16, 2006;  to be adjusted based on input from JackHeight
        %         et.eyeRightOfMonitorCenterMm=[];    %always zero (less than 1mm) in our rig;  user must center eye before recording
        %         et.degreesCameraIsClockwiseOfMonitorCenter=[];  %roughly if camera is at right of monitor; to be entered by user
        %         et.degreesCameraIsAboveEye=[];      %always zero (less than 3deg) in our rig;  user must center eye before recording
    case 'prompt'
        prompt={'enter based ruler measurement in mm:', 'degreesCameraIsClockwiseOfMonitorCenter:', 'eyeAboveMonitorCenterMm:', 'eyeRightOfMonitorCenterMm:(please center eye and confirm it is 0 mm)', 'degreesCameraIsAboveEye:(please move camera until eye is centered, enter 0)', 'human confirmation that values are good:'};
        name='Geometric Calibration User Specified Parameters';
        numlines=1;
        defaultanswer={'110','45','-55','0','0','0'};

        confirmedCorrect=0;
        while ~confirmedCorrect

            answer=inputdlg(prompt,name,numlines,defaultanswer);
            correctSoFar=1;

            input=str2num(answer{1});
            if all(size(input)==[1 1]) && input>0 && input<380 %true for rig on -pmm 080711
                screenToRulerZeroMm=490;
                backRightCornerToPivotCenterMm=65;
                et.eyeToMonitorTangentMm=screenToRulerZeroMm-backRightCornerToPivotCenterMm-input;
                %et=setEyeToMonitorTangentMm(et, eyeToMonitorTangentMm);
            else
                warning('based ruler measurement must be between 0 and 380 mm');
                correctSoFar=0;
            end

            input=str2num(answer{2});
            if input>0 && input<180
                et.degreesCameraIsClockwiseOfMonitorCenter=input;
                %et=setDegreesCameraIsClockwiseOfMonitorCenter(et, degreesCameraIsClockwiseOfMonitorCenter);
            else
                warning('degreesCameraIsClockwiseOfMonitorCenter must be a sensible measure (0 - 180) in clockwise degrees of angle between camera axis and monitor');
                correctSoFar=0;
            end
            
            input=str2num(answer{3});
            if all(size(input)==[1 1]) && all(abs(input)<300)
                et.eyeAboveMonitorCenterMm=input;
                %et=setEyeAboveMonitorCenterMm(et, eyeAboveMonitorCenterMm);
            else
                warning('eyeAboveMonitorCenterMm must a single number in mm and the absolute value must be less than 300');
                correctSoFar=0;
            end
            
            input=str2num(answer{4});
            if all(size(input)==[1 1]) && all(abs(input)<300)
                et.eyeRightOfMonitorCenterMm=input;
                %et=setEyeRightOfMonitorCenterMm(et, eyeRightOfMonitorCenterMm);
            else
                warning('eyeRightOfMonitorCenterMm must a single number in mm and must be <300');
                correctSoFar=0;
            end

            input=str2num(answer{5});
            if input==0 %varargin{14}>-3 && varargin{14}<3
                et.degreesCameraIsAboveEye=input;
                %et=setDegreesCameraIsAboveEye(et, degreesCameraIsAboveEye);
            else
                warnning('degreesCameraIsAboveEye should be zero');
                %error('degreesCameraIsAboveEye should be zero, but code tolerates (-3 - 3) in vertical degrees of angle between camera axis and the eye');
                correctSoFar=0;

            end
            
            et.humanConfirmation=str2num(answer{6});
            
            
            if ~correctSoFar
                beep
                defaultanswer=answer;
                warning('not all of the values were acceptable');

            else
                confirmedCorrect=1;
                struct(et)
                keyboard
            end
        end

        %         options.Resize='on';
        %         options.WindowStyle='normal';
        %         options.Interpreter='tex';
        %
        %         answer=inputdlg(prompt,name,numlines,defaultanswer,options)



    otherwise
        method
        error ('bad method');
end


et.eyeTracker=calibrate(et.eyeTracker);