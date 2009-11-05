function  eyeData=getEyeRecords(eyeRecordPath, trialNum,timestamp);
% is compatible with older eyeRecords in which multiple .mats got saved per
% trial at different times.

try
    %this handles current versions
    filename=sprintf('eyeRecords_%d_%s.mat',trialNum,timestamp);
    fullfilepath=fullfile(eyeRecordPath,filename);
    eyeData=load(fullfilepath);
catch ex
    % this handles old record types prior to march 17, 2009

    if strcmp(ex.identifier,'MATLAB:load:couldNotReadFile')
        d=dir(eyeRecordPath);
        goodFiles = [];

        % first sort the neuralRecords by trial number
        for i=1:length(d)
            %'eyeRecords_(\d+)-(.*)\.mat'
            %searchString=sprintf('eyeRecords_(%d)-(.*)\\.mat',trialNum)
            [matches tokens] = regexpi(d(i).name, 'eyeRecords_(\d+)_(.*)\.mat', 'match', 'tokens');
            if length(matches) ~= 1
                %d(i).name
                %warning('not a eyeRecord file name');
            else
                if str2double(tokens{1}{1})==trialNum
                    goodFiles(end+1).trialNum = str2double(tokens{1}{1});
                    goodFiles(end).timestamp = tokens{1}{2};
                    goodFiles(end).date = datenumFor30(tokens{1}{2});
                end
            end
        end
        if size(goodFiles,2)>0
            [sorted order]=sort([goodFiles.date]);
            goodFiles=goodFiles(order);

            %check that its within the hour of the start trial
            hrAfterStart=(datenumFor30(goodFiles(end).timestamp)-datenumFor30(timestamp))*24;
            if hrAfterStart>0 & hrAfterStart<1
                %LOAD THE MOST RECENT ONE, after checking sanity of time
                filename=sprintf('eyeRecords_%d_%s.mat',trialNum,goodFiles(end).timestamp);
                fullfilepath=fullfile(eyeRecordPath,filename);
                eyeData=load(fullfilepath);
            else
                error('weird time relation')
                hrAfterStart
                saved=goodFiles(end).timestamp
                started=datenumFor30(timestamp)
                keyboard

                filename=sprintf('eyeRecords_%d_%s.mat',trialNum,goodFiles(end).timestamp);
                fullfilepath=fullfile(eyeRecordPath,filename);
                eyeData=load(fullfilepath);
            end
        else
            eyeData=[]; % there were no records, eye tracker might have been off
        end
    else
        rethrow(ex);
    end

end


end % end function