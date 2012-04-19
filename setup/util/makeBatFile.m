function makeBatFile(subjectID,dataPath)
filename = sprintf('C:\\Users\\nlab\\Desktop\\%s.bat',upper(subjectID));

[fid, message] = fopen(filename,'wt');
if fid <3 || ~isempty(message)
    error('open fail')
end

fprintf(fid,'set subj="''%s''"\n',subjectID);
fprintf(fid,'"C:\\Program Files\\MATLAB\\R2011b\\bin\\matlab.exe" -nodesktop -nosplash -nojvm -r "cd ''C:\\Users\\nlab\\Desktop\\ratrix\\bootstrap'';standAloneRun(''%s'',[],%%subj%%);"',dataPath);

if fclose(fid)~=0
    error('close fail')
end
end