function out=testBoxSubjectAndStationDirs(r,b,sIDs)
out=1;

if isa(b,'box')
    stationInds=getStationInds(r,sIDs,getID(b));
    if all(stationInds>0)
        if testBoxSubjectDirs(r,b)
            for i=1:length(stationInds)
%                 if ~checkPath(getPath(r.assignments{getID(b)}{1}{i,1}))
%                     out=0;
%                     error('coudln''t get to station dir')
%                 end
                if ~checkPath(r.assignments{getID(b)}{1}{i,1})
                     out=0;
                     error('coudln''t get to station dir')                    
                end
            end
        else
            out=0;
            error('couldn''t get to all subject dirs for box')
        end
    else
        error('box doesn''t contain all those stations')
    end
else
    error('need a box object')
end