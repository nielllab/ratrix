function subs=getSubjects(conn,ids)

if isempty(ids)
    subQuery = 'SELECT display_uin FROM subjects';
    ids=query(conn,subQuery);
end

subs=struct([]);
for i=1:length(ids)
    subQuery = sprintf('SELECT subjects.uin FROM subjects WHERE display_uin=''%s'' ',ids{i});
    s=query(conn,subQuery);
    if ~isempty(s)
        subs(end+1).uin=s{1};
        %subs(end).type=s{2};
    else
        ids{i}
        warning('no subject with id')
    end
end