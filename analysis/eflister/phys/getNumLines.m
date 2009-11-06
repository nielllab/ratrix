function out=getNumLines(file,okToMissBlankLines)
out=0;

if ~exist('okToMissBlankLines','var')
    okToMissBlankLines=false;
end

try
    [fid msg]=fopen(file,'rt');
    if ~isempty(msg)
        msg
    end
    
    if fid>2
        if ~okToMissBlankLines
            %not fast, other options are not portable (depend on particular line ending format)
            
            %note perl option here refers to '\n' -- ignores '\r' difficulties -- but is fast at expense of obfuscating:
            %http://www.mathworks.com/matlabcentral/newsreader/view_thread/235126
            
            while ~feof(fid)
                %line=fgetl(fid);
                fgets(fid);%fgetl(fid); %faster?
                out=out+1;
            end
        else
            cycs=0;
            if IsWin
                [x y]=memory;
                fprintf('%g GB biggest array\n',x.MaxPossibleArrayBytes/1000^3)
                n=floor(x.MaxPossibleArrayBytes/8/10); %we're making doubles, we'll use a tenth of available
            else
                n=10^7;
            end
            while ~feof(fid)
                %these are fast but miss blanklines
                C=textscan(fid,'%s',n,'CollectOutput',true,'Delimiter','');
                %C=textscan(fid,'%0s %*s','Delimiter',''); %also works
                if isscalar(C)
                    cycs=cycs+1
                    size(C{1})
                    out=out+size(C{1},1);
                else
                    size(C)
                    error('C not scalar')
                end
            end
            
            %             if ~feof(fid)
            %                 error('textscan didn''t get to end of file')
            %             end
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