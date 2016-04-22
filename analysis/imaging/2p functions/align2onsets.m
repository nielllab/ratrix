function dFout = align2onsets(dF,onsets,dt,pts);
if ndims(dF)==2
    dFout = zeros(size(dF,1),length(pts),length(onsets));
    for i = 1:length(onsets);
        dFout(:,:,i) = interp1(1:size(dF,2),dF',(onsets(i)+pts)/dt)';
    end
else
    shiftdf = shiftdim(dF,2);
    dFout = zeros(size(dF,1),size(dF,2),length(pts),length(onsets));
    dFoutshift = zeros(length(pts),length(onsets),size(dF,1),size(dF,2));
    size(dFoutshift)
    for i = 1:length(onsets);
        if i/10 == round(i/10)
            sprintf('%d / %d trials done',i,length(onsets))
        end
        range  = floor((onsets(i)+pts(1))/dt) : ceil((onsets(i)+pts(end))/dt);
        dFoutshift(:,i,:,:) = interp1(range ,shiftdf(range ,:,:),(onsets(i)+pts)/dt,'nearest');
    end
    dFout = shiftdim(dFoutshift,2);
end
