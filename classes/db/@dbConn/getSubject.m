function s=getSubject(conn,id)
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


selectSubjectQuery = sprintf(selectSubjectQueryFormat,id);
results=query(conn,selectSubjectQuery);
if ~isempty(results) && size(results,1) == 1
    numRecords=size(results,1);
    numCols = size(results,2);
    if numRecords ~= 1
        error('Only one record expected when asking for a subject given an id')
    end
    if numCols ~= 11
        error('For subject query 11 columns expected to be returned')
    end
    s.id = lower(id);
    s.species = results{1,1};
    s.strain = results{1,2};
    s.gender = results{1,3};
    s.supplier = results{1,4};
    s.litter = results{1,5};
    s.dob = results{1,6};
    s.date_entered = results{1,7};
    s.date_exited = results{1,8};
    s.exit_status = results{1,9};
    s.owner = results{1,10};
    s.test = boolean(results{1,11});
else
    warning(['Queried for nonexistent subject ' id])
end






