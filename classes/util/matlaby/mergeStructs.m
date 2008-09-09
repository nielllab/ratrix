function a=mergeStructs(a,b)
s=[];
fn=fieldnames(a);
for i=1:length(fn)
    s=[s size(a.(fn{i}),2)];
end
fn=fieldnames(b);
for i=1:length(fn)
    s=[s size(b.(fn{i}),2)];
end
if length(unique(s))==1
    for i=1:length(fn)
        a.(fn{i})=b.(fn{i});
    end
else
    error('not all fields have same length')
end
end