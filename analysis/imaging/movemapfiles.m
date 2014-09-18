t=1:7
for t = 1:length(t)
for f = 1:length(files);
f

if t==1
    type = 'grating';
typedata = 'gratingdata';
elseif t==2
type = 'topoy';
typedata = 'topoydata';
elseif t==3
type = 'loom';
typedata = 'loomdata';
elseif t==4
type = 'topox';
typedata = 'topoxdata';
elseif t==5
type = 'stepbinary';
typedata = 'stepbinarydata';
elseif t==6
type = 'auditory';
typedata = 'auditorydata';
elseif t==7
type = 'darkness';
typedata = 'darknessdata';
elseif t==8
type = 'topoxreverse';
typedata = 'topoxreversedata';

end
exist([pathname getfield(files(f),type)],'file');
% type

if exist([datapathname getfield(files(f),typedata) 'maps.mat'],'file')
        display('found map file')
        if ~isempty(getfield(files(f),type))
            movefile([datapathname getfield(files(f),typedata) 'maps.mat'],[pathname getfield(files(f),type)]);
           % dos(sprintf('move /Y ''%s'' ''%s''',[datapathname getfield(files(f),typedata) 'maps.mat'],[pathname getfield(files(f),type)]))
        end
    end
end
end