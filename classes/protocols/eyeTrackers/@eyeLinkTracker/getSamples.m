function [gazes samples names]=getSamples(et)

names={};
gazes=[];
samples=[];
sampleInd=1;
[sample, raw] = Eyelink('NewestFloatSampleRaw');

while isstruct(sample) && sample~=-1
    sample.timeCPU=GetSecs; %do this fast next to the sample
    sample.date=now;
    sample.timeEyelink=sample.time; %rename
    sample=rmfield(sample,'time');  %not clear enough what it is

    gaze=getGazeEstimate(et,raw.raw_cr,raw.raw_pupil);
    %confirm: !!
    %cr=[crx,cry];
    %raw_pupil=[pupx,pupy];

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
    names{end+1}=fields(sample);

    %turn to a vector
    sample=cell2mat(struct2cell(sample));
    
    samples(sampleInd,:)=sample;
    gazes(sampleind,:)=gaze;
    sampleInd=sampleInd+1;
    [sample, raw] = Eyelink('NewestFloatSampleRaw');
    
end

end % end function
