function out=display(bs)
out='';
for i=1:length(bs)
    b=bs(i);

    d=['station id: ' b.id '\tports: ' num2str(b.numPorts) '\tresponseMethod: ' b.responseMethod '\tpath: ' strrep(b.path,'\','\\')];
    if ~isempty(out)
        out=sprintf('%s\n%s',out,sprintf(d));
    else
        out=sprintf(d);
    end
end