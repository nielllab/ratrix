function exportVariables(variableList)
%for dragon editing - makes variable pronunciation list
% speak dragon word "add variables to dragon"
% if need be "switch to DragonBar"
% and "add variables"

string='';
for i=1:length(variableList)
    name=char(variableList{i});
    low=lower(name);
    capSpots=find(low~=name);
    wordEnd=capSpots-1;
    wordEnd(end+1)=length(name);
    wordStart=[1 capSpots];
    spoken='';
    for j=1:length(wordEnd)
        spoken=[spoken ' ' low(wordStart(j):wordEnd(j))];
    end

    string=sprintf('%s%s\\%s\n',string,name,spoken);
end

display(string)

%%
desktop='C:\Documents and Settings\rlab\Desktop';
filename='currentVariables.txt';
fid = fopen(fullfile(desktop,filename),'wt');
fprintf(fid,'%s',string);
fclose(fid);
