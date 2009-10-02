function out=getRangeFromChunks(file,range)

file='C:\eflister\phys analysis\164\02.27.09\8d315fc3a807c5b249e5ebf3e99a8cbd19e0ffd4\phys.8d315fc3a807c5b249e5ebf3e99a8cbd19e0ffd4.mat';

recs=whos('-file',file);
s=load(file,'step','start');


arrayfun(@process,recs);%,'UniformOutput',false);
    function out=process(x)
        C=textscan(x.name,'out%u8');
        if isscalar(C)
            if ~isscalar(C{1})
                error('not scalar')
            else
                out=C{1};
            end
        else
            error('not scalar')
        end
    end

% chunkNames={recs.name};
% 
% for i=1:length(chunkNames)
% end
% 
% chunks=


end