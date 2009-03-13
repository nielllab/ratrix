function [p durs]=sendCommands(p,cmds)
showWarnings=true;

if p.pumpOpen
    durs=zeros(1,length(cmds));
    for i=1:length(cmds)
        start=GetSecs();

        successfulSend=false;
        while ~successfulSend
            try
                sprintf('sending %s',cmds{i});
                fprintf(p.serialPort,cmds{i});
                try
                    in=fscanf(p.serialPort);
                    if strcmp(in(2:4),'00A')
                        warning('got pump alarm ''%s'' -- trying resend (not cycling pump)',in)
                    else
                        successfulSend=true;
                    end
                catch ex
                   disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                    in
                    warning('pump failure on read!  cycling pump!')
                    p=closePump(p);
                    p=openPump(p);
                end
            catch ex
                disp(['CAUGHT ERROR: ' getReport(ex,'extended')])
                warning('pump failure on write!  cycling pump!')
                p=closePump(p);
                p=openPump(p);
                %rethrow(ex)
            end
        end
        durs(i)=GetSecs()-start;
        %in %once this was empty!  figure out why?
        if int8(in(1))==2 && int8(in(end))==3
            in=in(2:end-1);
            switch cmds{i}
                case 'DIS'
                    if strcmp(in(1:3),'00S') && ...
                            ... %(strcmp(in(4:15),sprintf('I%4.3fW%4.3f',volume,volume)) || strcmp(in(4:15),'I0.000W0.000')) && ...
                            strcmp(in(16:17),p.units)
                        if showWarnings
                            warning('unchecked pump response to [%s]: [%s i:%s w:%s %s]',cmds{i},in(1:3),in(5:9),in(11:15),in(16:17))
                        end
                    else
                        error(sprintf('unexpected pump response to [%s]: [%s]',cmds{i},in))
                    end
                case 'VOL'
                    if strcmp(in(1:3),'00S') && strcmp(in(9:10),p.units) %&& strcmp(in(4:8),sprintf('%4.3f',volume))
                        if showWarnings
                            warning('unchecked pump response to [%s]: [%s %s %s]',cmds{i},in(1:3),in(4:8),in(9:10))
                        end
                    else
                        error(sprintf('unexpected pump response to [%s]: [%s]',cmds{i},in))
                    end
                case 'RUN 1'
                    checkStr(in,'00I',cmds{i});
                case 'RUN 3'
                    checkStr(in,'00W',cmds{i});
                case {'ROM' 'AL' 'DIR'}
                    if showWarnings
                        warning(sprintf('unchecked pump response to [%s]: [%s]',cmds{i},in))
                    end
                    %need to fill these in
                case 'VER'
                    if strcmp(in(1:6),'00SNE5')
                        fprintf('pump firmware version: %s\n',in(4:end))
                    else
                        error(sprintf('unexpected response to [%s]: [%s]',cmds{i},in))
                    end
                otherwise
                    checkStr(in,'00S',cmds{i});
            end
        else
            error('response from pump doesn''t have correct initiator/terminator')
        end
    end
else
    error('pump not open')
end

function checkStr(resp,pred,cause)
if ~strcmp(resp,pred)
    error(sprintf('pump responded to [%s] with [%s], should have responded [%s]',cause,resp,pred))
end
