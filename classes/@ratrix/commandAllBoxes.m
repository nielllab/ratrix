function r=commandAllBoxes(r,cmd,comment,auth,secsAcknowledgeWait)
    for i=1:length(r.boxes)
        r=commandAllBoxIDStations(r,cmd,getID(r.boxes{i}),comment,auth,secsAcknowledgeWait)
    end