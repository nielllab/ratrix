function C=doScan(file,format,headerlines,chanVerify,instancesVerify,fieldsVerify,rep)

try
    [fid msg]=fopen(file,'rt');
    if ~isempty(msg)
        msg
    end
    
    if fid>2
        
        chanForm='%% CHANNEL %% %% %u8 %%';        
        C = textscan(fid,chanForm,1);
        
        if isscalar(C)
            if C{1}==chanVerify
                %pass
            else
                error('got wrong chan')
            end
        else
            error('couldn''t read channel')
        end
        
        frewind(fid);
        
        if ~rep
            
            C = textscan(fid,format, 1, 'headerlines',headerlines);
            
            if ~ismember(instancesVerify,[0 1]) %temp hack -- allow 0
                error('specify instancesVerify=1 when rep=false')
            end
            
        else
            
            [C, pos] = textscan(fid,format, 'headerlines',headerlines);
            
            %         status = fseek(fid, 0, 'eof');
            %
            %         if status~=0
            %             status
            %             [message,errnum] = ferror(fid)
            %             error('seek error')
            %         end
            %
            %         posVerify = ftell(fid);
            %
            %         if posVerify <=0
            %             [message,errnum] = ferror(fid)
            %             error('ftell error')
            %         end
            %
            %         if pos ~= posVerify
            %             error('textscan didn''t get to end of file')
            %         end
            
            if ~feof(fid)
                error('textscan didn''t get to end of file')
            end
            
        end
        
        if ~all(size(C)==[1 fieldsVerify])
            error('numfields fail')
        end
        
        szCheck=cellfun(@(x) all(size(x)==[instancesVerify 1]),C);
        if ~all(szCheck(:))
            error('instances fail')
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