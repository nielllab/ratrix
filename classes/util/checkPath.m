function out=checkPath(p)
    if ischar(p)
            warning('off','MATLAB:MKDIR:DirectoryExists')
            [success,message,msgid] = mkdir(p);
            warning('on','MATLAB:MKDIR:DirectoryExists')
            
            if success
                out=1;
            else
                error(sprintf('could not make path -- specify absolute path (see mkdir help): %s, %s',message,msgid))
            end        
    else
        error('bad path format')
    end