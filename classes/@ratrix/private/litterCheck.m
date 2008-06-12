function out=litterCheck(r,s)
out=0;
if isa(s,'subject')
    lID=getLitterID(s);
    if strcmp(lID,'unknown')
        out=1;
    else
        for i=1:length(r.subjects)
            if strcmp(getLitterID(r.subjects{i}),lID)
                if strcmp(getAcquisitionDate(r.subjects{i}),'unknown')
                    ds='unknown';
                else
                    ds=datestr(getAcquisitionDate(r.subjects{i}),'mm/dd/yyyy');
                end
                
                if all(getAcquisitionDate(r.subjects{i})==getAcquisitionDate(s))
                    disp(sprintf('found acquisition date match with known litter %s: %s (%s)',...
                        lID,getID(r.subjects{i}), ds));
                else
                    out=-1;
                    disp(sprintf('found acquisition date mismatch with known litter %s: %s (%s)',...
                        lID,getID(r.subjects{i}), ds));
                end

                if all(getBirthDate(r.subjects{i})==getBirthDate(s))
                    disp(sprintf('found birth date match with known litter %s: %s (%s)',...
                        lID,getID(r.subjects{i}), datestr(getBirthDate(r.subjects{i}),'mm/dd/yyyy')));
                else
                    out=-1;
                    disp(sprintf('found birth date mismatch with known litter %s: %s (%s)',...
                        lID,getID(r.subjects{i}), datestr(getBirthDate(r.subjects{i}),'mm/dd/yyyy')));
                end

            end
        end
        if out==-1
            out=0;
        else
            out=1;
        end
    end
else
    error('argument is not a subject object')
end