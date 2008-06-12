function out = getProtocolForSubjectID(r,s)

        [member index]=ismember(s,getSubjectIDs(r));

        if index>0

            [out i]=getProtocolAndStep(getSubjectFromID(r,s));
            
         
        else
            error('no such subject id')
        end