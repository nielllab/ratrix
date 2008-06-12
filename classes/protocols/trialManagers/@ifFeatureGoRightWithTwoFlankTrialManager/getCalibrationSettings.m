function t=getCalibrationSettings(t, method)


        %determine orientations used
        orientations = unique([t.goRightOrientations t.goLeftOrientations t.flankerOrientations t.distractorOrientations t.distractorFlankerOrientations]);
        t.calib.orientations=orientations;
        
switch method
     case 'uncalibrated'
        t.calib.contrastScale=ones(size(orientations));
    case 'default'
        t.calib.contrastScale=[1 0.95]
        error('confirm defaults');
    case 'mostRecent'
         error('loads from the appropriate location-- unwritten code');
    case 'calibrateNow'
         error('should be doing calibration here-- unwritten code');
    otherwise
        method
        error('unknown method');
end
        
