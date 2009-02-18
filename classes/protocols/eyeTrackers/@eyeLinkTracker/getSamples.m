function [gazes samples names]=getSamples(et)
%%
% gazes should be [Nx2]
% samples should be [Nx2]
% names should be [Nx2]
% where N is the number of samples available from the eyetracker while we loop


% [samples(end), raw] = Eyelink('NewestFloatSampleRaw');

samples=[];
gazes=[];
names={};
items={};
ndTypes=[];
numItems=0;
drained=false;
while ~drained
    nextDataType = Eyelink('GetNextDataType'); %type of next queue item: SAMPLE_TYPE if sample, 0 if none, else event code
    if nextDataType==0
        drained=true;
    else
        numItems=numItems+1;
        if nextDataType==200 % SAMPLE_TYPE
            ndTypes(end+1)=nextDataType;
            items{end+1} = Eyelink('GetFloatData', nextDataType);
            samples(end+1)=items{end}; % item from eyelink('GetFloatData') is not the same as sample from eyelink('NewestFloatSampleRaw')
            % do something here to convert from 'item' to 'sample' and 'raw'
            samples(end).timeCPU=GetSecs; %do this fast next to the sample
            samples(end).date=now;
            samples(end).timeEyelink=samples(end).time; %rename
            samples(end)=rmfield(samples(end),'time');  %not clear enough what it is

            gazes(numItems,:)=getGazeEstimate(et,raw.raw_cr,raw.raw_pupil);

            %% save as vector

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

            f=fields(samples(end));
            for i=1:length(f)
                switch size(samples(end).(f{i}),2)
                    case 1
                        % do nothing, its just  single number
                    case 2 % choose the correct eye
                        samples(end).(f{i})=samples(end).(f{i})(index);
                    case 8 %hdata
                        %vectorize the data
                        samples(end).hdata1=samples(end).hdata(1);
                        samples(end).hdata2=samples(end).hdata(2);
                        samples(end).hdata3=samples(end).hdata(3);
                        samples(end).hdata4=samples(end).hdata(4);
                        samples(end).hdata5=samples(end).hdata(5);
                        samples(end).hdata6=samples(end).hdata(6);
                        samples(end).hdata7=samples(end).hdata(7);
                        samples(end).hdata8=samples(end).hdata(8);
                        samples(end)=rmfield(samples(end),'hdata');
                    otherwise
                        error('unexpected content')
                end
            end

            %turn all the raws to single numbers and add to samples(end)
            f=fields(raw);
            for i=1:length(f)
                switch size(raw.(f{i}),2)
                    case 1 %xfer to the samples(end) structure
                        samples(end).(f{i})=raw.(f{i})(index);
                    case 2 % set the x and y values
                        samples(end).([f{i} '_x'])=raw.(f{i})(1);
                        samples(end).([f{i} '_y'])=raw.(f{i})(2);
                    otherwise
                        error('unexpected content')
                end
            end



            %save the names
            names{end+1}=fields(samples(end));

            %turn to a vector
            samples(end)=cell2mat(struct2cell(samples(end)));

        else
            % not a SAMPLE_TYPE
            ndTypes(end+1)=nextDataType
            items{end+1} = Eyelink('GetFloatData', nextDataType);
            items{end}
            %pause
        end
    end
end


end % end function


%confirm: !!
%cr=[crx,cry];
%raw_pupil=[pupx,pupy];




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