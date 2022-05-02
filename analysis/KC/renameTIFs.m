
%%% COPY TIF FILES INTO NEW FOLDER %%%

clear all

% *** NAVIGATE TO CORRECT FOLDER *** 

cd 'F:\Kristen\Widefield2\081621_G6H305RT_RIG2_TOPOX'

d = 'F:\Kristen\Widefield2\081621_G6H305RT_RIG2_TOPOX';

oldTifNamesStruct = dir(d); % num frames x 1 struct array
 
oldTifNamesStruct = oldTifNamesStruct(3:end); % deleted avi & stim obj files, now don't selelct the 1st two '.' & '..'
% files

% extract each name out of struct and becomes char
for f = 1:length(oldTifNamesStruct)
    
    threeThousandOldNamesChar(f,:) = oldTifNamesStruct(f).name; 
    
end

% remove last 4 didgits in each name
allOldNamesMinusLastDidgits = threeThousandOldNamesChar(:,1:27); 

% re-name each name with new end didgits
clear f
number = 0;
fileExtension = '.tif';
for f = 1:length(allOldNamesMinusLastDidgits) % for every name
    
    eachNewName = allOldNamesMinusLastDidgits(f,:); % index into one name at a time
    
    number = number + 1; % add one to number
    
    % make new names matrix (store)
    % strcat allows me to concatenate strings & numbers:
    allNewNames(f,:) = strcat(eachNewName, sprintf('%04d',f),fileExtension); % use sprintf to attach new ending
    % didgits to each name, w/sig figs to the left
     
end

% for each old name, rename as new name

clear f
for f = 1:length(threeThousandOldNamesChar)

    % rename each old name as the new name
    movefile(threeThousandOldNamesChar(f,:), allNewNames(f,:))

end 
