function out=getPhaseLabelPerLick(phaseRecord)

out={};
for i=1:length(phaseRecord)
    %length(phaseRecord(i).responseDetails.times)
    for j=1:length(phaseRecord(i).responseDetails.times) % loop per lick
        out=[out phaseRecord(i).phaseLabel];
    end
end

if isempty(out)
    out={NaN};
end
end