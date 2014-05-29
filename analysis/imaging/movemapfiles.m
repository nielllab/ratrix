for t = 1:6
for f = 1:length(files);
f

if t==1
    type = 'topox';
typedata = 'topoxdata';
elseif t==2
type = 'topoy';
typedata = 'topoydata';
elseif t==3
type = 'darkness';
typedata = 'darknessdata';
elseif t==4
type = 'whisker';
typedata = 'whiskerdata';
elseif t==5
type = 'step_binary';
typedata = 'step_binarydata';
elseif t==6
type = 'topoxreverse';
typedata = 'topoxreversedata';
end
exist([pathname getfield(files(f),type)],'file');
type

if exist([datapathname getfield(files(f),typedata) 'maps.mat'],'file')
        display('found map file')
        if ~isempty(getfield(files(f),type))
            movefile([datapathname getfield(files(f),typedata) 'maps.mat'],[pathname getfield(files(f),type)]);
           % dos(sprintf('move /Y ''%s'' ''%s''',[datapathname getfield(files(f),typedata) 'maps.mat'],[pathname getfield(files(f),type)]))
        end
    end
end
end