function out = doCalibration()
% gives a user prompt to decide what "default" calibration to do
% calls calibrateMonitor
out=[];

inp = input(['What calibration do you want to do?\n', ...
    '1 = default stimInBoxOnBackground (all 256 RGB triplets, gray background, write to oracle)\n', ...
    '2 = default stimInBoxOnBackground (all 256 values, RGB independently, mean voltage background, write to oracle)\n', ...
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
        background=0.5;
        interValueRGB=uint8([255 255 255]);
        numFramesPerValue=uint32(300);
        numInterValueFrames=uint32(150);
        patchRect=[0.2 0.2 0.8 0.8];
        method={'stimInBoxOnBackground',background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames};
        screenType='CRT';
        fitMethod='linear';
        mode='256gray';
        stim=[];
        writeToOracle=true;
        
    case 2
        background=0.5;
        interValueRGB=uint8([255 255 255]);
        numFramesPerValue=uint32(300);
        numInterValueFrames=uint32(150);
        patchRect=[0.2 0.2 0.8 0.8];
        method={'stimInBoxOnBackground',background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames};
        screenType='CRT';
        fitMethod='linear';
        mode='256RGB';
        stim=[];
        writeToOracle=true;
        
    otherwise
        error('unsupported type - how did this get past the error check?');
end

[out.measuredR out.measuredG out.measuredB out.currentCLUT out.linearizedCLUT out.validationValues details] = ...
    calibrateMonitor(stim,method,mode,screenType,fitMethod,writeToOracle,comment);

end % end function

