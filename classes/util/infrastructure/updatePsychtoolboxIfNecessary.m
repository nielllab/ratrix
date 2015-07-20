function updatePsychtoolboxIfNecessary

svnPath = GetSubversionPath;

ptbr=PsychtoolboxRoot;
if ptbr(end)==filesep
    ptbr=ptbr(1:end-1); %windows svn requires no trailing slash
end
[status result]=system([svnPath 'svn cleanup ' '"' ptbr '"']);
if status~=0
    result
    'bad svn cleanup of psychtoolbox code'
end

[wcrev reprev repurl]=getSVNRevisionFromXML(ptbr);
if wcrev ~= reprev %limit unnecessary use of updatepsychtoolbox due to the PsychtoolboxRegistration data
    %Christopher Broussard chrg@sas.upenn.edu) maintains platypus.psych.upenn.edu and complained that we were
    %making his server logs gigantic

    %first remove our stuff from the path, cuz updatepsychtoolbox has the
    %side effect of making path change permanent
    p=path;
    r=getRatrixPath;
    while ~isempty(p)
        [item p]=strtok(p,pathsep);
        if ~isempty(findstr(r,item))
            rmpath(item);
        end
    end

    UpdatePsychtoolbox
else
    'psychtoolbox appears to be up to date, not updating'
end