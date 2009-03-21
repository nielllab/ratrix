function [gazes samples]=getSamples(et)
debug=false;
startTime=GetSecs;

% fields=...
%     {'type',                'sample.type';...
%     'flags',                'sample.flags';...
%     'px',                   'sample.px(index)';...
%     'py',                   'sample.py(index)';...
%     'hx',                   'sample.hx(index)';...
%     'hy',                   'sample.hy(index)';...
%     'pa',                   'sample.pa(index)';...
%     'gx',                   'sample.gx(index)';...
%     'gy',                   'sample.gy(index)';...
%     'rx',                   'sample.rx';...
%     'ry',                   'sample.ry';...
%     'status',               'sample.status';...
%     'input',                'sample.input';...
%     'buttons',              'sample.buttons';...
%     'htype',                'sample.htype';...
%     'timeCPU',              'GetSecs';...
%     'date',                 'now';...      %EDF IS SETTING THIS TO ZERO!!!
%     'timeEyelink',          'sample.time';...
%     'hdata1',               'sample.hdata(1)';...
%     'hdata2',               'sample.hdata(2)';...
%     'hdata3',               'sample.hdata(3)';...
%     'hdata4',               'sample.hdata(4)';...
%     'hdata5',               'sample.hdata(5)';...
%     'hdata6',               'sample.hdata(6)';...
%     'hdata7',               'sample.hdata(7)';...
%     'hdata8',               'sample.hdata(8)';...
%     'raw_pupil_x',          'raw.raw_pupil(1)';...
%     'raw_pupil_y',          'raw.raw_pupil(2)';...
%     'raw_cr_x',             'raw.raw_cr(1)';...
%     'raw_cr_y',             'raw.raw_cr(2)';...
%     'pupil_area',           'raw.pupil_area';...
%     'cr_area',              'raw.cr_area';...
%     'pupil_dimension_x',    'raw.pupil_dimension(1)';...
%     'pupil_dimension_y',    'raw.pupil_dimension(2)';...
%     'cr_dimension_x',       'raw.cr_dimension(1)';...
%     'cr_dimension_y',       'raw.cr_dimension(2)';...
%     'window_position_x',    'raw.window_position(1)';...
%     'window_position_y',    'raw.window_position(2)';...
%     'pupil_cr_x',           'raw.pupil_cr(1)';...
%     'pupil_cr_y',           'raw.pupil_cr(2)'};

el=getConstants(et);

index=et.eyeUsed+1;  %0 is left eye in the 1st index

if isempty(index)
    index
    error('bad index')
end
if ~(index==1 || index==2)
    index
    eyeused = Eyelink('EyeAvailable')
    error('bad index')
end

%preallocate
eyetrackerRate=1000; %should put as constant field on eyelinkTracker
refreshRate=100; %should pass this in
excessFactor=5;
nows=nan(1,ceil(excessFactor*eyetrackerRate/refreshRate));
timeCPUs=nows;
gazes=repmat(nows',1,2);

sampleInd=0;
done=false;
justGetLatestSample=false;

while ~done
    gotASample=false;
    if justGetLatestSample
        newOrOld = Eyelink('NewFloatSampleAvailable');
        switch newOrOld
            case -1
                error('NewFloatSampleAvailable returned -1')
            case 0
                error('NewFloatSampleAvailable returned 0')
            case 1
                [sample, raw] = Eyelink('NewestFloatSampleRaw');
                gotASample=true;
            otherwise
                newOrOld
                error('NewFloatSampleAvailable returned unexpected value')
        end
        done=true;
    else
        type = Eyelink('GetNextDataType');

        switch type
            case el.SAMPLE_TYPE
                [sample, raw] = Eyelink('GetFloatDataRaw', type);
                gotASample=true;
            case 63 %63=hex2dec('3F'), hex2dec is slow, replace with el.LOSTDATAEVENT when we get the new eyelink toolbox
                fprintf('got lost data flag after %d good samples\n',sampleInd)
            case 0 %queue drained - no more samples currently available
                done=true;
            otherwise
                type
                error('got unrecognized data type after %d good samples\n',sampleInd)
        end
    end

    if gotASample

        if isstruct(sample) && isstruct(raw)
            sampleInd=sampleInd+1;

            %nows(sampleInd)=now; %edf: why do we want this?
            timeCPUs(sampleInd)=GetSecs;

            gazes(sampleInd,:)=getGazeEstimate(et,raw.raw_cr,raw.raw_pupil); %this can have nans in it if some of the raw values are the MISSING_DATA code
            %confirm: !!
            %cr=[crx,cry];
            %raw_pupil=[pupx,pupy];

            %no way to preallocate structure arrays :(
            samps(sampleInd)=sample;
            raws(sampleInd)=raw;
        else
            sample
            raw
            error('got non struct sample or raw after %d good samples\n',sampleInd)
        end
    end
end

gazes=gazes(1:sampleInd,:); %this can have nans in it if some of the raw values are the MISSING_DATA code

%the following sucks, but more dynamic ways are too slow
%this method typically takes 1.5ms
%could probably be cut to .1ms by consoldiating all the cell2mats
%1:sampleInd on left hand side not strictly necessary but is nice check for size problems

samples(1:sampleInd,1) = [samps.type];
samples(1:sampleInd,2) = [samps.flags];

tmp=cell2mat({samps.px}');
samples(1:sampleInd,3) = tmp(:,index);

tmp=cell2mat({samps.py}');
samples(1:sampleInd,4) = tmp(:,index);

tmp=cell2mat({samps.hx}');
samples(1:sampleInd,5) = tmp(:,index);

tmp=cell2mat({samps.hy}');
samples(1:sampleInd,6) = tmp(:,index);

tmp=cell2mat({samps.pa}');
samples(1:sampleInd,7) = tmp(:,index);

tmp=cell2mat({samps.gx}');
samples(1:sampleInd,8) = tmp(:,index);

tmp=cell2mat({samps.gy}');
samples(1:sampleInd,9) = tmp(:,index);

tmp=cell2mat({samps.rx}');
samples(1:sampleInd,10) = tmp(:,index);

tmp=cell2mat({samps.ry}');
samples(1:sampleInd,11) = tmp(:,index);

samples(1:sampleInd,12) = [samps.status];
samples(1:sampleInd,13) = [samps.input];
samples(1:sampleInd,14) = [samps.buttons];
samples(1:sampleInd,15) = [samps.htype];
samples(1:sampleInd,16) = timeCPUs(1:sampleInd);
samples(1:sampleInd,17) = 0; %nows(1:sampleInd); %edf thinks this is waste of time
samples(1:sampleInd,18) = [samps.time];

tmp=cell2mat({samps.hdata}');
samples(1:sampleInd,19) = tmp(:,1);
samples(1:sampleInd,20) = tmp(:,2);
samples(1:sampleInd,21) = tmp(:,3);
samples(1:sampleInd,22) = tmp(:,4);
samples(1:sampleInd,23) = tmp(:,5);
samples(1:sampleInd,24) = tmp(:,6);
samples(1:sampleInd,25) = tmp(:,7);
samples(1:sampleInd,26) = tmp(:,8);

tmp=cell2mat({raws.raw_pupil}');
samples(1:sampleInd,27) = tmp(:,1);
samples(1:sampleInd,28) = tmp(:,2);

tmp=cell2mat({raws.raw_cr}');
samples(1:sampleInd,29) = tmp(:,1);
samples(1:sampleInd,30) = tmp(:,2);

samples(1:sampleInd,31) = [raws.pupil_area];
samples(1:sampleInd,32) = [raws.cr_area];

tmp=cell2mat({raws.pupil_dimension}');
samples(1:sampleInd,33) = tmp(:,1);
samples(1:sampleInd,34) = tmp(:,2);

tmp=cell2mat({raws.cr_dimension}');
samples(1:sampleInd,35) = tmp(:,1);
samples(1:sampleInd,36) = tmp(:,2);

tmp=cell2mat({raws.window_position}');
samples(1:sampleInd,37) = tmp(:,1);
samples(1:sampleInd,38) = tmp(:,2);

tmp=cell2mat({raws.pupil_cr}');
samples(1:sampleInd,39) = tmp(:,1);
samples(1:sampleInd,40) = tmp(:,2);

if debug && sampleInd>1.1*eyetrackerRate/refreshRate
    fprintf('got %d eyetracker samples in %g ms\n',sampleInd,1000*(GetSecs-startTime))
end

end