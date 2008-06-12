function [rx ids] = emptyAllBoxes(rx,comment,author)
ids={};
bs=getBoxIDs(rx);
for i=1:length(bs)
    s=getSubjectIDsForBoxID(rx,bs(i));
    for j=1:length(s)
        ids{end+1}=s{j};
        rx=removeSubjectFromBox(rx,s{j},bs(i),comment,author)
    end
end