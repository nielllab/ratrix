function [gaze sample names]=getSample(et)
%%
[sample, raw] = Eyelink('NewestFloatSampleRaw');
sample.timeCPU=GetSecs; %do this fast next to the sample
sample.date=now;
sample.timeEyelink=sample.time; %rename
sample=rmfield(sample,'time');  %not clear enough what it is

gaze=getGazeEstimate(et,raw.raw_cr,raw.raw_pupil);
%confirm: !!
%cr=[crx,cry];
%raw_pupil=[pupx,pupy];

%% save as struct array: this methods loads to slow
%saving is 40x slower (.4 sec vs. 0.012 sec)
%loading is    slower (.7 sec vs.   sec)
if 0
    %add raws to sample
    f=fields(raw);
    for i=1:length(f)
        sample.(f{i})=raw.(f{i});
    end
end


%% save as vector
if 1

    %turn all the samples to single numbers
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

    f=fields(sample);
    for i=1:length(f)
        switch size(sample.(f{i}),2)
            case 1
                % do nothing, its just  single number
            case 2 % choose the correct eye
                sample.(f{i})=sample.(f{i})(index);
            case 8 %hdata
                %vectorize the data
                sample.hdata1=sample.hdata(1);
                sample.hdata2=sample.hdata(2);
                sample.hdata3=sample.hdata(3);
                sample.hdata4=sample.hdata(4);
                sample.hdata5=sample.hdata(5);
                sample.hdata6=sample.hdata(6);
                sample.hdata7=sample.hdata(7);
                sample.hdata8=sample.hdata(8);
                sample=rmfield(sample,'hdata');
            otherwise
                error('unexpected content')
        end
    end

    %turn all the raws to single numbers and add to sample
    f=fields(raw);
    for i=1:length(f)
        switch size(raw.(f{i}),2)
            case 1 %xfer to the sample structure
                sample.(f{i})=raw.(f{i})(index);
            case 2 % set the x and y values
                sample.([f{i} '_x'])=raw.(f{i})(1);
                sample.([f{i} '_y'])=raw.(f{i})(2);
            otherwise
                error('unexpected content')
        end
    end



    %save the names
    names=fields(sample);

    %turn to a vector
    sample=cell2mat(struct2cell(sample));

end



%alternate organization strategy
if 0
    ELtime=sample.time;
    type= sample.type;
    flags= sample.flags;
    px= sample.px(index);
    py= sample.py(index);
    hx= sample.hx(index);
    hy= sample.hy(index);
    pa= sample.pa(index);
    gx= sample.gx(index);
    gy= sample.gy(index);
    rx= sample.rx(index);
    ry= sample.ry(index);
    status= sample.status;
    input= sample.input;
    buttons= sample.buttons;
    htype= sample.htype;
    hdata1=sample.hdata(1);
    hdata2=sample.hdata(2);
    hdata3=sample.hdata(3);
    hdata4=sample.hdata(4);
    hdata5=sample.hdata(5);
    hdata6=sample.hdata(6);
    hdata7=sample.hdata(7);
    hdata8=sample.hdata(8);
end

%        time: 366547731
%        type: 200
%       flags: 49105
%          px: [-1458 -32768]
%          py: [-8391 -32768]
%          hx: [1799 -32768]
%          hy: [587 -32768]
%          pa: [7640 32768]
%          gx: [1113.09997558594 -32768]
%          gy: [627.599975585938 -32768]
%          rx: 46.2999992370605
%          ry: 45.5
%      status: 0
%       input: 38032
%     buttons: 0
%       htype: 248
%       hdata: [965 -436 939 70 7315 161 27503 24848]
%
%           raw_pupil: [0 667.859985351563]
%              raw_cr: [685.255981445313 667.755981445313]
%          pupil_area: 1143722476
%             cr_area: 7315
%     pupil_dimension: [161 111]
%        cr_dimension: [107 16]
%     window_position: [97 664]
%            pupil_cr: [9.62692044991149e-043 -13.2554979324341]