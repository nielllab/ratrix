function makeAllSubjectServerDirectories(r)
                    subIDs=getSubjectIDs(r);
                    for subInd=1:length(subIDs)
                        makeSubjectServerDirectory(r,subIDs{subInd});
                    end