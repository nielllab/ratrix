function out = doCalibration()
% gives a user prompt to decide what "default" calibration to do
% calls calibrateMonitor
out=[];

inp = input(['What calibration do you want to do?\n', ...
    '1 = default stimInBoxOnBackground (all 256 RGB triplets, gray background, write to oracle)\n', ...
    'Q = quit\n',...
    '>>'], 's');

type=[];
while isempty(type)
    if ischar(inp)
        if ismember(inp,{'1'})
            type=str2double(inp);
        elseif strcmpi(inp,'Q')
            return
        end
    else
        disp('invalid input. please try again! (or Q to quit)');
    end
end

switch type
    case 1
        rawValues=uint8(zeros(1,1,3,1));
        rawValues(:,:,:,2)=uint8(15*ones(1,1,3));
        rawValues(:,:,:,3)=uint8(172*ones(1,1,3));
        rawValues(:,:,:,4)=uint8(255*ones(1,1,3));
        background=0.2;
        interValueRGB=uint8([255 255 255]);
        numFramesPerValue=uint32(300);
        numInterValueFrames=uint32(150);
        patchRect=[0.2 0.2 0.8 0.8];
        method={'stimInBoxOnBackground',rawValues,background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames};
        screenType='LCD';
        fitMethod='linear';

        writeToOracle=true;
        
    otherwise
        error('unsupported type - how did this get past the error check?');
end

[out.measuredValues out.currentCLUT out.linearizedCLUT out.validationValues] = ...
    calibrateMonitor(method,screenType,fitMethod,writeToOracle);

end % end function

