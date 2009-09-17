function out=getNumLines(file)
out=0;
try
    [fid msg]=fopen(file,'rt');
    if ~isempty(msg)
        msg
    end
    
    if fid>2
        if true
            %not fast, other options are not portable (depend on particular line ending format)
            
            %note perl option here refers to '\n' -- ignores '\r' difficulties -- but is fast at expense of obfuscating:
            %http://www.mathworks.com/matlabcentral/newsreader/view_thread/235126
            
            while ~feof(fid)
                %line=fgetl(fid);
                fgetl(fid); %faster?
                out=out+1;
            end
        else
            %these are fast but miss blanklines - argh!
            %C=textscan(fid,'%s','Delimiter','');
            %C=textscan(fid,'%0s %*s','Delimiter','');
            
            if ~feof(fid)
                error('textscan didn''t get to end of file')
            end
        end
    else
        error('no file')
    end
    
    error('finally')
    
catch ex
    if exist('fid','var')
        s=fclose(fid);
        if s
            error('fclose error')
        end
    end
    
    if ~strcmp(ex.message,'finally')
        rethrow(ex)
    end
end
end