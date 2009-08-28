function index=getIndexedResponses(responses,wordLengths)
'indexing for '
wordLengths

for n=wordLengths
    n
    counts = zeros(1,2^n);
    pos=repmat(1:n,size(responses,2)-n+1,1)+repmat([0:size(responses,2)-n]',1,n);

    for i=1:2^n
        places{i}=[];
    end

    for r=1:size(responses,1)
        r
        theseResponses=responses(r,:);
        [cnts plcs wrds] = getCounts(theseResponses(pos),1:size(pos,1),[]);
        counts=counts + cnts;
        for i=1:length(plcs)
            if isempty(places{i})
                places{i}=plcs{i};
            elseif ~isempty(plcs{i})
                places{i}=[places{i} plcs{i}]; %Warning: Concatenation involves an empty array with an incorrect number of rows.
            end
        end
        if r==1
            words=wrds;
        else
            if any(any(words~=wrds))
                error('words out of order')
            end
        end
    end

    if length(wordLengths)==1
        index={places words counts};
    else
        index{n}={places words counts};
    end

end

'done indexing'