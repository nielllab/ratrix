function [str numerrs]=erikSend(s1,code,volume,numerrs,verbose,units)
out = {};
in = {};
times={};
errs={};
str={};

try
    for i=1:length(code)
        out{i}=code{i};
        start=GetSecs();
        fprintf(s1,code{i});
        in{i}=fscanf(s1);
        times{i}=sprintf('%g',GetSecs()-start);
        x=in{i};
        errs{i}=0;
        if int8(x(1))==2 && int8(x(end))==3
            in{i}=x(2:end-1);
            switch out{i}
                case 'DIS'
                    x=in{i};
                    if strcmp(x(1:3),'00S') && ...
                            (strcmp(x(4:15),sprintf('I%4.3fW%4.3f',volume,volume)) || strcmp(x(4:15),'I0.000W0.000')) ...
                            && strcmp(x(16:17),units)
                        in{i}=sprintf('%s i:%s w:%s %s',x(1:3),x(5:9),x(11:15),x(16:17));
                    else
                        in{i}=[in{i} ' BAD RESPONSE'];
                        errs{i}=1;
                    end
                case 'VOL'
                    x=in{i};
                    if strcmp(x(1:3),'00S') && strcmp(x(9:10),units) && strcmp(x(4:8),sprintf('%4.3f',volume))
                        in{i}=sprintf('%s %s %s',x(1:3),x(4:8),x(9:10));
                    else
                        in{i}=[in{i} ' BAD RESPONSE'];
                        errs{i}=1;
                    end
                case 'RUN 1'
                    if ~strcmp(in{i},'00I') && ~strcmp(in{i},'00W')
                        in{i}=[in{i} ' RESPONSE SHOULD BE 00I'];
                        errs{i}=1;
                    end
                case 'RUN 3'
                    if ~strcmp(in{i},'00W')
                        in{i}=[in{i} ' RESPONSE SHOULD BE 00W'];
                        errs{i}=1;
                    end
                case {'ROM' 'AL' 'DIR'}

                otherwise
                    if ~strcmp(in{i},'00S')
                        in{i}=[in{i} ' RESPONSE SHOULD BE 00S'];
                        errs{i}=1;
                    end
            end
        else
            in{i}=[in{i} ' PACKET FAILS TO FIT PROTOCOL'];
            errs{i}=1;
        end
    end
catch ex
    ex.stack.line
    ex.stack.file
    ex.message
    fclose(s1);
end
for i=1:length(code)
    if errs{i}
        errstr='****************************************';
        numerrs=numerrs+1;
    else
        errstr='';
    end
    if errs{i} || verbose
        str{i}=sprintf('%s\t\t\t%s\t\t\t%s\t\t\t%s\n',out{i},in{i},times{i},errstr);
    end
end
