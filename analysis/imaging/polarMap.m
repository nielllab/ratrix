function out = polarMap(in, lim);
if ~exist('lim','var')
    lim = 98;
end
in(isnan(in))=0;
ph =angle(in);
ph(ph<0) = ph(ph<0)+2*pi;
ph=mat2im(ph,hsv,[0 2*pi]);
amp = abs(in);
amp = amp/prctile(amp(:),lim);
amp(amp>1)=1;
out = ph.* repmat(amp,[1 1 3]);
