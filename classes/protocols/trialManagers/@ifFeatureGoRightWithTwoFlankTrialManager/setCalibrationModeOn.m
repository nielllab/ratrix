function t=setCalibrationModeOn(t, state)

if (state == 0)|(state == 1)
    t.calib.calibrationModeOn=state;
else
    warning('failed to change state, must be 0 or 1');
end