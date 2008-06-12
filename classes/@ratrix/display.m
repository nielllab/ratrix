function d=display(r)
d=['ratrix\n\tdatabase:\t' strrep(r.dbpath,'\','\\') '\n\tserver path:\t' strrep(r.serverDataPath,'\','\\')];
d=[d '\n\tboxes:\n\t'];
for i=1:length(r.boxes)
    d=[d '\t' strrep(display(r.boxes{i}),'\','\\') '\n\t'];
    stns=getStationsForBoxID(r,getID(r.boxes{i}));
    for stnNum=1:length(stns)
        d=[d '\t\t' strrep(display(stns(stnNum)),'\','\\') '\n\t'];
    end
end
d=[d 'subjects:\n\t\t'];
for i=1:length(r.subjects)
    d=[d getID(r.subjects{i}) ' '];
end
d=[d '\n\tassignments:\n'];
boxIDs=getBoxIDs(r);
subjectIDs=getSubjectIDs(r);
for i=1:length(r.assignments)
    if isempty(r.assignments{i}) && ~ismember(i,boxIDs)
        d=[d '\t\tbox ' num2str(i) ':\tno box with this id\n'];
    elseif ismember(i,boxIDs)
        d=[d '\t\tbox ' num2str(i) ':\trunning: ' num2str(boxIDRunning(r,i)) '\tnumSubjects: ' num2str(length(r.assignments{i}{2})) '\tnumStations: ' num2str(size(r.assignments{i}{1},1)) '\n'];
        for subN=1:length(r.assignments{i}{2})
            if ismember(r.assignments{i}{2}{subN},subjectIDs)
                [p k]=getProtocolAndStep(getSubjectFromID(r,r.assignments{i}{2}{subN}));
                d=[d '\t\t\tsubject ' r.assignments{i}{2}{subN} ':\tprotocol: ' ...
                    getName(p) '\tstep: ' num2str(k) ' of ' num2str(getNumTrainingSteps(p)) '\n'];
                %probably want to add info about how long subject has been in box, progress, trial rate etc.
            else
                error('box found to have subject not in ratrix')
            end
        end
        for staN=1:size(r.assignments{i}{1},1)
            %d=[d '\t\t\tstation: ' display(r.assignments{i}{1}{staN,1}) '\trunning: ' num2str(r.assignments{i}{1}{staN,2})];
            d=[d '\t\t\tstation ' num2str(getID(r.assignments{i}{1}{staN,1})) ':\trunning: ' num2str(r.assignments{i}{1}{staN,2})];
        end
    else
        error('something is wrong with this ratrix''s assignments')
    end
end
d=sprintf(d);