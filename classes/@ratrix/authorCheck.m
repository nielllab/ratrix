function out=authorCheck(r,author) %stupid that all functions in an object directory have to be methods (we don't need ratrix for this)
    approved={'edf','pmm','pr','ratrix','bs','unspecified','aw','dd','sm','spreadsheet'};
    if ismember(author,approved)
        out=1;
    else
        out=0;
        approved
        warning('author must be one of above')
    end