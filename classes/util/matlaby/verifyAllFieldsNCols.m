function verifyAllFieldsNCols(in,n);
fn=fieldnames(in);
for i=1:length(fn)
    if ~all(size(in.(fn{i}),2)==n)
        fn{i}
        size(in.(fn{i}))
        error('bad return size')
    end
end