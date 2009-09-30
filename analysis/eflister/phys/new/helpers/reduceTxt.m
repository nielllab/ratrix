function reduceTxt(targetDir,analysisDir,base,prefix,binsPerSec,chan)

target=fullfile(targetDir  ,[prefix '.' base '.txt']);
src   =fullfile(analysisDir,[prefix '.' base '.mat']);
chunkTxtToMat(target,src,chan);


end


% this is for dealing with spike export .txt's (for phys and stim) that are
% really big.  note spike has no way to export uint16's, even though that
% would give us 4x the capacity and it only a2d's at 16 bit -- only exports floats.

% we want to stay with doubles anyway, cuz singles and ints have limited math

% biggest .txt i can read (using 'load') at 40kHz as doubles is 1 hour (for one channel),
% but we make (max) 3.5 hour spike recordings

% only upgrade that would make much difference is switching to 64 bit os
% w/64 bit matlab, then just RAM limited.  but for practical amounts of RAM
% we don't really make enough of a difference (newest spike version removes
% 3.5 hour limit, plust consider n-trodes, etc.).

% so instead, we break up the file into a .mat with variables out0-outN, which can be loaded individually and quickly.

% on windows, NTFS allows files to be as big as partition (FAT/FAT32 have limits)
% to check filesystem: all programs/accessories/system tools/system information/components/storage/drives/
%
% http://www.mathworks.com/support/tech-notes/1100/1106.html
% win32 (+ some unix 32): limits memory to 2+1 GB (subtract 0.8GB for available variable space)
% 1.2 GB @ 40kHz doubles is ~1 hour
%
% http://www.mathworks.com/support/tech-notes/1100/1107.html
% 2+1 GB switch: (boot.ini instructions work for XP sp2 and later)
% http://technet.microsoft.com/en-us/library/bb124810%28EXCHG.65%29.aspx
% not contiguous, so no bigger arrays
%
% http://www.mathworks.com/support/solutions/en/data/1-YVO5H/index.html?solution=1-YVO5H
% max 2^31 (15 hours @ 40kHz) (or sometimes 2^48-1, 2 million hours) elements per array
%
% http://www.mathworks.com/support/tech-notes/1100/1110.html
% win32: 1.2GB limit, not much help from 3GB switch or OSX32, but linux32 or win64+ml32 roughly 2x both
% os64/ml64: essentially RAM limited, so practical is 4GB = ~3.5 hours

function chunkTxtToMat(target,src,chan)
hrs=0;
cycs=0;
delete(target);

try
    [fid msg]=fopen(src,'rt');
    if ~isempty(msg)
        msg
    end
    
    if fid>2
        if false && IsWin %this method makes chunks too big and we run out of memory
            [x y]=memory;
            fprintf('%g GB biggest array\n',x.MaxPossibleArrayBytes/1000^3) %strict upper bound according to doc
            n=floor(x.MaxPossibleArrayBytes/8/8); %we're making doubles, we'll use an eigth of available -- usually means we write out around 30 MB chunks
            
            %this value can be quite small:  according to docs, the standard windows heap manager:
            % "behavior depends upon whether the requested allocation is less than or greater than the fixed number of 524,280 bytes.
            % For, example, if you create a sequence of MATLAB arrays, each less then 524,280 bytes, and then clear them all...
            % instead of globally freeing the extra memory, the memory becomes reserved. It can only be reused for arrays less than 524,280
            % bytes. You cannot reclaim this memory for a larger array except by restarting MATLAB."
        else
            n=10^7;
        end
        while ~feof(fid)
            
            C=doScan(src,'%% START %% %f %f',6,chan,1,2,false);
            
            start=C{1};
            step=C{2};
            
            if start<0 || abs(1- step * 40000)>.5
                error('bad start or step')
            end
            
            save(target,'step','start');
            
            keyboard
            
            %here's the heart of the matter -- we'd like to just use
            %"load" (we were careful to format the txt file to allow this), but
            %the txt file is frequently too large to load all in one go.
            C=textscan(fid,'%f',n,'CommentStyle','%'); %'CollectOutput',true,
            
            if isscalar(C)
                nitems=size(C{1},1);
                
                out=nan(nitems,2);
                out(:,1)=C{1};
                %out(:,1)=start+step*(0:nitems-1)';
                %start=out(end,1)+step;
                
                if any(isnan(out(:)))
                    error('got a nan')
                end
                
                var=sprintf('out%d',cycs);
                eval([var ' = out;']); %feval(@=,var,out) %= not a func :(
                save(target,var,'-append');
                clear(var);
                
                hrs=hrs+nitems*step/60/60;
                fprintf('%g hours\n',hrs)
                cycs=cycs+1;
            else
                size(C)
                size(C{1})
                error('C not scalar')
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