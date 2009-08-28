function out=lookup(a,inds)
%a is an n-d array
%inds is an m x n matrix
%out is an 1 x m vector containing the entries in a specified by the
%coordinates in each row of inds

if length(size(a))==2 && any(size(a)==1)
    out=a(inds);
else
    maxes=repmat(size(a),size(inds,1),1);
    if size(inds,2)~=length(size(a))
        error('wrong num cols in inds')
    end
    if any(inds(:)<=0)
        find(inds<=0)
        error('got inds <= 0')
    end
    if any(inds(:)>maxes(:))
        ers=find(inds>maxes)
        inds(ers)
        maxes(1,:)
        size(a)
        error('got inds > size(a)')
    end

    %based on http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_prog/f1-86846.html
    factors=ones(size(inds,1),1);
    offsets=zeros(size(inds,1),1);
    sz=size(a);
    for i=1:length(sz)-1
        factors(:,i+1)=prod(sz(1:i));
        offsets(:,i+1)=-1;
    end
    out=a(sum([(inds+offsets).*factors]'));
end