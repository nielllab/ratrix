function dFout = align2onsets(dF,onsets,dt,pts);
if ndims(dF)==2
    dFout = zeros(size(dF,1),length(pts),length(onsets));
    for i = 1:length(onsets);
        dFout(:,:,i) = interp1(1:length(dF),dF',(onsets(i)+pts)/dt)';
    end
else
   shiftdf = shiftdim(dF,2);
   dFout = zeros(size(dF,1),size(dF,2),length(pts),length(onsets));
    for i = 1:length(onsets);
   i
   dFoutshift(:,i,:,:) = interp1(1:length(dF),shiftdf,(onsets(i)+pts)/dt);
    end
    dFout = shiftdim(dFoutshift,2);
end
