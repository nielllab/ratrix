function out=getRangeFromChunks(file,startsMS,durMS)

file='C:\eflister\phys analysis\164\02.27.09\8d315fc3a807c5b249e5ebf3e99a8cbd19e0ffd4\phys.8d315fc3a807c5b249e5ebf3e99a8cbd19e0ffd4.mat';

recs=whos('-file',file);
s=load(file,'step','start');

out=arrayfun(@process,recs,'UniformOutput',false);
    function y=process(x)
        C=textscan(x.name,'out%u8');
        if isscalar(C)
            if ~isscalar(C{1})
                if ismember(x.name,{'step','start'})
                    y=uint8([]);
                else
                    error('not scalar')
                end
            else
                if x.size(2)~=1 || ~isvector(x.size)
                    error('bad out size')
                else
                    y.name=C{1};
                    y.len=x.size(1);
                end
            end
        else
            error('not scalar')
        end
    end
out=cell2mat(out(~cellfun(@isempty,out)));
[junk ord]=sort([out.name]);
out=out(ord);
names=[out.name];
if ~all(names==0:max(names'))
    error('not contig')
end

binds=cumsum([0 out.len]);
boundaries=(s.start+binds*s.step)*1000;

if ~exist('startsMS','var') || isempty(startsMS)
    out=cellfun(@(x) x(boundaries),{@min @max});
elseif ~isvector(startsMS)
    error('not a vec')
else
    [sortedStarts ord]=sort(startsMS);
    if size(sortedStarts,1)==1
        sortedStarts=sortedStarts';
    end
    
    inds =1+cumsum([floor((sortedStarts-boundaries(1))/(s.step*1000)) ones(length(sortedStarts),ceil(durMS/(s.step*1000))-1)],2);
    binds=1+binds;
    if inds(1,1)<binds(1) || inds(end,end)>=binds(end)
        error('not in range')
    end
end
out=nan([size(inds) 2]);
for i=1:length(names)
    matches=binds(i)<=inds & binds(i+1)>inds;
    if any(matches(:))
        name=['out' num2str(names(i))];
        fprintf('loading %s...',name)
        raw=load(file,name);
        fprintf('indexing...')
        times=cumsum([boundaries(i) 1000*s.step*ones(1,length(raw.(name))-1)]);
        tinds=binds(i):binds(i+1)-1;
        fprintf('done\n')
        for j=1:size(matches,1)
            %take=tinds>=min(inds(j,:)) & tinds<=max(inds(j,:)); %why is this line slow?  tinds is large, but come on, takes as long as the load!
            take=find(tinds>=min(inds(j,:)),1,'first') : find(tinds<=max(inds(j,:)),1,'last'); %twice as fast as above line
            
            if false %why aren't take2 and take3 always equivalent to take?  they aren't any faster, so no matter.
                take2=find(tinds>=min(inds(j,:)),1,'first') : find(tinds>=max(inds(j,:)),1,'first');
                take3=find(tinds<=min(inds(j,:)),1,'last') : find(tinds<=max(inds(j,:)),1,'last');
                q={take,take2,take3};
                for qn=1:length(q)
                    qn
                    if ~isempty(q{qn})
                        [q{qn}(1) q{qn}(end)]
                    end
                end
            end
            
            out(j,matches(j,:),1)=times(take);
            out(j,matches(j,:),2)=raw.(name)(take);
        end
    end
end
out(ord,:,:)=out;
if any(isnan(out(:)))
    error('got a nan')
end
plot(diff(out(:,:,1)')) %reveals a 1% error at chunk transitions -- why?  i can't find the cause...
end