function out=display(bs)
out='';
for i=1:length(bs)
    b=bs(i);

    d=['station id: ' num2str(b.id) '\tports: ' num2str(b.numPorts) '\twidth: ' num2str(b.width) '\theight: ' num2str(b.height) '\tresponseMethod: ' b.responseMethod '\tpath: ' strrep(b.path,'\','\\')];
    if ~isempty(out)
        out=sprintf('%s\n%s',out,sprintf(d));
    else
        out=sprintf(d);
    end
end