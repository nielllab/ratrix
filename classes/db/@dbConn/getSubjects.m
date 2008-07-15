function s=getSubjects(conn,ids)
s = [];
selectSubjectQueryFormat = ...
    ['SELECT SUBJECTTYPES.NAME,STRAINS.NAME,GENDER,SUPPLIERS.NAME,' ...
    '(CASE WHEN LITTER_ID IS NULL THEN ''UNKNOWN'' ELSE LITTER_ID END),' ...
    'DOB,ENTERED_LAB,EXITED_LAB,EXITSTATUS,USERNAME, TEST_SUBJECT ' ...
    'FROM SUBJECTS LEFT JOIN RESEARCHERS ON SUBJECTS.OWNER_UIN=RESEARCHERS.UIN,' ...
    'STRAINS, SUBJECTTYPES, SUPPLIERS ' ...
    'WHERE SUBJECTS.STRAIN_UIN=STRAINS.UIN AND SUBJECTS.SUPPLIER_UIN=SUPPLIERS.UIN AND ' ...
    'STRAINS.SUBJECTTYPE_UIN=SUBJECTTYPES.UIN AND ' ...
    'LOWER(SUBJECTS.DISPLAY_UIN) = LOWER(''%s'')'];

for i=1:length(ids)
    selectSubjectQuery = sprintf(selectSubjectQueryFormat,ids{i});
    results=query(conn,selectSubjectQuery);
    if ~isempty(results)
        numRecords=size(results,1);
        numCols = size(results,2);
        if numRecords ~= 1
            error('Only one record expected when asking for a subject given an id')
        end
        if numCols ~= 11
            error('For subject query 11 columns expected to be returned')
        end
        s(i).id = lower(ids{i});
        s(i).species = results{1,1};
        s(i).strain = results{1,2};
        s(i).gender = results{1,3};
        s(i).supplier = results{1,4};
        s(i).litter = results{1,5};
        s(i).dob = results{1,6};
        s(i).date_entered = results{1,7};
        s(i).date_exited = results{1,8};
        s(i).exit_status = results{1,9};
        s(i).owner = results{1,10};
        s(i).test = boolean(results{1,11});
    else
        warning(['Queried for nonexistent subject ' ids{i}])
    end
end
        




