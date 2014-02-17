function removeLibusb
if ~IsWin
    error('can only remove libusb from win')
end
[a,b]=dos('pnputil -e'); 
if a~=0
    a
    b

    if 2~=exist('C:\Windows\System32\PnPutil.exe')
        warning('matlab can''t see C:\Windows\System32\PnPutil.exe -- this happens sometimes even when that file exists and you can run pnputil at the dos prompt -- why?')
    end
    
    error('pnputil fail')
end
x={};
while ~isempty(b)
    [x{end+1},b]=strtok(b,uint8(sprintf('\n')));
end
x={x{find(~cellfun(@isempty,strfind(x,'libusb')))-1}};
x=cellfun(@getinf,x,'UniformOutput',false);
    function out = getinf(in)
        out={};
        while ~isempty(in)
            [test,in]=strtok(in);
            if ~isempty(strfind(test,'.inf'))
                out{end+1}=test;
            end
        end
    end
x=[x{:}];
if ~isempty(x)
    cellfun(@doit,x);
end
    function doit(in)
        [a,b]=dos(['pnputil -f -d ' in]);
        b
        if a~=0
            a
            error('pnputil fail')
        end
    end

f=fullfile(getenv('windir'),'system32');
d=dir(fullfile(f,'*libusb*'));
arrayfun(@removeFile,d);
f=fullfile(f,'drivers');
d=dir(fullfile(f,'*libusb*'));
arrayfun(@removeFile,d);
    function removeFile(in)
        in.name
        delete(fullfile(f,in.name))
    end
end