function out=display(s)
if strcmp(s.receivedDate,'unknown')
    rd=s.receivedDate;
else
    rd=datestr(s.receivedDate,'mm/dd/yyyy');
end
    out=sprintf('id:\t\t%s\nspecies:\t%s\nstrain:\t\t%s\ngender:\t\t%s\nbirth:\t\t%s\nacquired:\t%s\nlitterID:\t%s\nsupplier:\t%s',...
                 s.id,s.species,s.strain,s.gender,datestr(s.birthDate,'mm/dd/yyyy'),rd,s.litterID,s.supplier);