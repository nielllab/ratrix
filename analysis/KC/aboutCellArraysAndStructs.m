% CREATING & INDEXING CELL ARRAYS

% To add values to a cell array over time or in a loop, 
% create an empty N-dimensional array using the cell function.

emptyCell = cell(3,4,2)

% There are two ways to refer to the elements of a cell array. 
% Enclose indices in smooth parentheses, (), to refer to sets of cells--for example, 
% to define a subset of the array. 
% Enclose indices in curly braces, {}, to refer to the text, numbers, 
% or other data within individual cells.

testCellArray = {[1 2 3], 'one', {1}, rand(0,1,3)}
subsetFirstTwoCells = testCellArray(1,1:2); % access subsections of cell array (not content)
% Access the contents of cells
contentFirstCell = testCellArray{1,2};
% You can access the contents of multiple cells by indexing with curly
% braces if assigning to variable you need one variable per cell 
[contentFirstCell contentSecondCell] = testCellArray{1,1:2};

%% CREATING & INDEXING STRUCT ARRAYS

% When you have data that you want to organize by name, you can use structures to store it. 
% Structures store data in containers called fields, which you can then access by the names 
% you specify. 

% use dot notation to create, assign, and access data in structure fields. 
% If the value stored in a field is an array, then you can use array indexing to access 
% elements of the array. When you store multiple structures as a structure array, 
% you can use array indexing and dot notation to access individual structures and their fields.

structure.name = 'test struct';
structure.billing = 666;
structure.test = [1 1 1; 2 2 2; 3 3 3;];

% After you create a field, 
% you can keep using dot notation to access and change the value it stores.
structure.billing = 669;

% With dot notation, you also can access the value of any field.
% make a bar graph with test score values in test field
bar(structure.test)
title(structure.name)

% To access part of an array stored in a field, 
% add indices that are appropriate for the size and type of the array.
% For example, create a bar chart of the data in one column of structure.test
bar(patient.test(:,1))

% indexing into nonscalar struct array
% Structure arrays can be nonscalar. 

% You can create a structure array having any size, 
% as long as each structure in the array has the same fields

% for example, add a second test structure to the main structure (confusing
% with the struct name I chose..)

structure(2).name = 'second test struct';
structure(2).billing = 999;
structure(2).test = [4 4 4; 5 5 5; 6 6 6;];

% now structure is a 1x2 array (number of structs 
% is rows & fields is columns

% A structure array has the following properties:
% All structures in the array have the same number of fields.
% All structures have the same field names.
% Fields of the same name in different structures can contain different types or sizes of data.

% index into each structure like this:
structure(2)

% To access a field, use array indexing and dot notation:
structure(2).test

% You also can index into an array stored by a field
structure(2).test(:,[1 2]) % this should display only the first 2 columns of the array...
% (all rows, colums 1 & 2)

% NOTE You can index into part of a field only when you refer to a single 
% element of a structure array. 
% MATLAB® does not support statements such as patient(1:2).test(1:2,2:3), 
% which attempt to index into a field for multiple elements of the structure array. 
% Instead, use the arrayfun function.

% so in stimDetails, each element/structure w/in the struct array is a
% trial. that's rows. Clumns are fields. No 3rd dimansion I don't think...

%% making test cell array w/structs to figure out how to index into group stim details 
% to get contrasts for each trial...

% for each fake session, we'll make a fake struct array and put it into a cell, 
% just like my real groupStimDetails variable 

clear n
fakeNumSess = 1; % number of sessions/cells in group cell array
for n = 1:fakeNumSess 
 
% for each fake session,
% make fake struct array w/ 4 structs, 2 fields, diff name & number for each struct's 
% field cell values
    clear fakeStimDetailsStruct
    clear s % i = stimulus condition
    for s = 1:4
        fakeStimDetailsStruct(s).fakeName = sprintf('fake name %0.00f',s);
        fakeStimDetailsStruct(s).fakeTargContrast = rand(1,1);
    end

fakeStimDetailsStruct;

% once the fake struct array is made for the nth fake session, 
% collect it in the fake group cell array

fakeGroupStimDetails{n} = fakeStimDetailsStruct;

fakeGroupStimDetails;

end 


% clear n
% fakeNumSess = 1; % number of sessions/cells in group cell array
% for n = 1:fakeNumSess
%     
%     fakeStimDetailsStructSess = fakeGroupStimDetails{1};
%     fakeStimDetailsStructSess
%     n
% 
%     
% end 
% 
% fakeStimDetailsStructSess(1)
% fakeStimDetailsStructSess(2)
% 
% fakeStimDetailsStructSess(1).fakeName

%% 

fakeStimDetailsStructSess1 = fakeGroupStimDetails{1} = fakeGroupStimDetails{1}

% now, what do i want? I guess I want whatever I would normally store as
% 'con' in the individual analysis. I hyst need to be able to index it fron the 
% group cell array. 

% normally I index all of the contrasts for every trial all at once, first
% having indexed the stim conditions in order of presentation 

% for each structure (row/stim condition) in the struct array,
% extract the contrast value and collect them all in a new vector, 'con'.
% note that I didn't index the whole field column at once, apparently
% that's impossible so I had to use a for loop

clear i
for i=1:length(stimDetails); % 1 x num stim conditions struct
    % each row is a stim condition , w/colums fields like sf, correctResp, contrasts, etc
    con(i) = stimDetails(i).targContrast; % making vector with list of targ contrast for each condition - some of these will be repeating, since there are only 3 contrasts but 96 stimulus conditions (phase, etc)
end

% then I want to order con according to trial presentation:

conOrderedByTrial = con(trialCond); 

% and that's it, other than excluding a few trials & storing the contrast values for
% this session
conOrderedByTrialMeetCriteria = conOrderedByTrial(:,idxOnsetsMeetBothCriteria);
uniqueContrasts = unique(con); % for looping over contrast values later

% so the real main challenge is getting that 'stimDetails' struct pulled
% out of the cell array, so that it can be indexed with the for loop as shown above
