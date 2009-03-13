function smallData=sortSmallData(smallData,inds);
%sort in order if inds; default is chronological order, apply to all fields but 'info'


if ~isempty(smallData)
    if any(strcmp(fields(smallData),'date'))
        if any(diff(smallData.date)<0)  | exist('inds','var')  % only sort if its needed

            if ~exist('inds','var')
                disp('putting in chronological order')
                [junk inds] = sort(smallData.date,2,'ascend');
            end


            %determine which fields to process
            f=fields(smallData);

            %remove the info field from the sort list
            if any(strcmp(f,'info'))
                f(find(strcmp(f,'info')))=[];
            end

            %evaluate the resort for every field
            for i=1:length(f)
                command=sprintf('smallData.%s=smallData.%s(inds);',f{i},f{i});
                try
                    eval(command);
                catch ex
                    disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                    disp(command);
                    error('problem with this command')
                end
            end


            if any(diff(smallData.date)<0)
                error('sort failed')
            end

        else
            %do nothing b/c the data is sorted
        end
    else
        smallData.info
        datestr(smallData.info.sessionIDs)
        warning('an empty session!, thats weird')
    end
else
    %do nothing b/c there is no data
end



