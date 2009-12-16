function out=removeSomeSmalls(d,which)

f=fields(d);
if any(strcmp(f,'info'))
    keepInfo=1;
    f(find(strcmp(f,'info')))=[];
else
    keepInfo=0;
end

for i=1:length(f)
    command=sprintf('out.%s=d.%s(:,~which);',f{i},f{i});
    try
        %eval(command)
        out.(f{i})=d.(f{i})(:,~which);
    catch ex
        disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
        disp(command);
        error('problem with this command')
    end
end

if keepInfo
    out.info=d.info;
end

