function out = testBoxSubjectDir(box,sub)
    out=0;
    if isa(sub,'subject')
%         testDir = getPath(box);
%         
%         currDir=pwd;
%         
%         cd(testDir);

%         if strcmp([pwd filesep],testDir)
            
%             boxDir=pwd;
            testDir = fullfile(getSujbectDataDir(box),getID(sub)); %['subjectData' filesep getID(sub) filesep];
            
            warning('off','MATLAB:MKDIR:DirectoryExists')
            [success,message,msgid] = mkdir(testDir);
            warning('on','MATLAB:MKDIR:DirectoryExists')
            
            if success
                out=1;
            else
                %error(sprintf('got to box directory, but could not make subject directory there: %s, %s, %s',testDir,message,msgid))
                error('could not make or find box''s directory for this subject: %s, %s, %s',testDir,message,msgid)
            end
            
%         else
%             error(sprintf('could not cd to box directory %s -- must be fully resolved',testDir))
%         end
%         cd(currDir);

    else
        error('didn''t get subject argument')
    end
    