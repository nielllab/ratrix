function out=normRows(in)
    for i=1:size(in,1)
        in(i,:)=in(i,:)/norm(in(i,:));
    end
    out=in;