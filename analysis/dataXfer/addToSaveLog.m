function saveLog=addToSaveLog(saveLog,subject,path,sessionID,varNames,varValues,verbose)
%updates the saveLog located at path so that the fields with varNames take
%on varValues. Return the updated saveLog as well as saving a .mat
%
%saveLog=addToSaveLog(saveLog,subject,path,sessionID,varNames,varValues)
%saveLog=addToSaveLog(saveLog,subjects(i),dataStoragePath,sessionIDs(k),{'subjectID','stationID','saveDate','largeExists'},{subjects(i),stations(j),now,1})

if size(varNames,2)~=size(varValues,2)
    error ('must have same number of values as variable names')
end

%if the session exists then add to its values, otherwise create a new entry
%in the saveLog
saveLogInd= find(sessionID==saveLog.sessionID); %these should be detecting pre-existing entry in the saveLog, but don't
if isempty(saveLogInd)
    saveLogInd=size(saveLog.sessionID,2)+1;
    saveLog=initializeSaveLogIndToEmpty(saveLog,saveLogInd,sessionID);
end
noSmallYet=saveLog.smallExists(saveLogInd);



%assign all of the values to the appropiate fields specified in varValues
for i=1:size(varNames,2)
    switch varNames{i}
        case 'subjectID'
            %this is special because it's a string in a structure
            command=sprintf('saveLog.%s{%s}=''%s'';', varNames{i}, num2str(saveLogInd), varValues{i});
            %alternately we could save subjectIDs as only the last three
            %numbers, but there are some assupmtions involved, and why not
            %stick with strings, because it's a standard
        otherwise
            %this command wil set the field at the index equal to the
            %numerical value of float with enough precision for
            %datestr(now)
            command=sprintf('saveLog.%s(%s)=%s;', varNames{i}, num2str(saveLogInd), num2str(varValues{i},'%0.12f'));
            varValues{i};
    end
    try
        eval(command);
    catch
        disp(command);
        error ('bad command in saveLog')
    end
end

save(fullfile(path, char(subject),'saveLog.mat'), 'saveLog');

if verbose
    disp(sprintf('%d saved sessions', size(saveLog,1)))
end


