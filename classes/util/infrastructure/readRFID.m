function readRFID
clc
closeAllSerials

fileName='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\rfid\ratTags.mat';

k=which('CharAvail','-all');
if all(cellfun(@isempty,(strfind(k,'CharAvail'))))
    error('needs psychtoolbox')
end

C = onCleanup(@cleanup);
    function cleanup
        ListenChar(0);
        if exist('s','var')
            fclose(s)
            delete(s)
            clear s
        end
        fprintf('\ndatabase dump:\n')
        [garbage order]=sort({recs{:,2}});
        for i=order
            fprintf('%s\t%s\n',recs{i,1},recs{i,2})
        end
    end

recs=load(fileName);
recs=recs.recs;

ListenChar(2);
FlushEvents('keyDown');

s = serial('COM1','BaudRate',2400,'Timeout',.5); %had to hunt to figure out our avid reader only works with 2400 baud
fopen(s);
done=false;
clearBuffer(s);
fprintf('scan a tag, or hit a key to quit\n')
while ~done
    warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
    t=strtrim(fscanf(s));
    warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
    
    [nums len]=textscan(t,'AVID%*1[*]%3u8%*1[*]%3u8%*1[*]%3u8'); %matches format AVID*013*604*432
    
    if ~isempty(findstr('READY',t))
        fprintf('\t%s\n',t);
        fprintf('\nscan a tag, or hit a key to quit\n')
    elseif length(t)==16 && len==16 && all(size(nums)==[1 3]) && all(~cellfun(@isempty,nums)) %strmatch('AVID',t)
        fprintf('\tgot tag %s\t',t);

        match={recs{find(strcmp(t,{recs{:,1}})),2}};

        switch length(match)
            case 0
                ListenChar(0)
                new=input('new tag, enter rat name: ','s');
                ListenChar(2)
                recs(end+1,:)={t new};
                save(fileName,'recs');
                fprintf('\trecorded tag %s as rat %s\n',t, new)
            case 1
                fprintf('tag matches rat: %s\n',match{1})
            otherwise
                fprintf('corrupt database - found multiple values for that tag:\n')
                match
                error('corrupt database')
        end
        clearBuffer(s);
        fprintf('\nscan a tag, or hit a key to quit\n')
    elseif isempty(t)
        done=CharAvail;
    else
        switch t
            case 'No ID Found'
                fprintf('\t%s\n',t);
            case 'LOOKING'
            otherwise
                fprintf('\tgot unexpected output: %s\n',t);
        end
    end
end
end

function closeAllSerials
alreadies=instrfind;
if ~isempty(alreadies)
    fclose(alreadies)
    delete(alreadies)
end
end

function clearBuffer(s)
t='hi';
while ~isempty(t)
    warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
    t=strtrim(fscanf(s));
    warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
end
end