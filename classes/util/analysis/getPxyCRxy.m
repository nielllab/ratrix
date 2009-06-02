function  [px py crx cry time]=getPxyCRxy(e,downSampleBy);
% helper util for eyeData

%e.eyeDataVarNames
%use raw
%why are these bad values, all? do I need to send a setup command?
px=e.eyeData(:,strcmp(e.eyeDataVarNames,'raw_pupil_x'));
py=e.eyeData(:,strcmp(e.eyeDataVarNames,'raw_pupil_y'));
crx=e.eyeData(:,strcmp(e.eyeDataVarNames,'raw_cr_x'));
cry=e.eyeData(:,strcmp(e.eyeDataVarNames,'raw_cr_y'));
time=e.eyeData(:,strcmp(e.eyeDataVarNames,'timeCPU')); % timeCPU, timeEyelink date
time=time-time(1);

%x=e.eyeData(:,strcmp(e.eyeDataVarNames,'pupil_cr_x'));
%y=e.eyeData(:,strcmp(e.eyeDataVarNames,'pupil_cr_y'));

badVal=intmin('int16');
bads=py==badVal | cry==badVal;
px(bads)=nan;
py(bads)=nan;
crx(bads)=nan;
cry(bads)=nan;

if exist('downSampleBy','var')
    px=downsample(px,downSampleBy);
    py=downsample(py,downSampleBy);
    crx=downsample(crx,downSampleBy);
    cry=downsample(cry,downSampleBy);
    time=downsample(time,downSampleBy);
end