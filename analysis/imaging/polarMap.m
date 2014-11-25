function out = polarMap(in, lim);
if ~exist('lim','var')
    lim = 98;
end
in(isnan(in))=0;
ph =angle(in);
ph(ph<0) = ph(ph<0)+2*pi;
%ph=mat2im(ph,hsv,[0 2*pi]);
ph=mat2im(ph,hsv,[2.2 4.75]); % was [2 5]
amp = abs(in);
amp = amp/prctile(amp(:),lim);
%amp = amp/0.03;
amp(amp>1)=1;
out = ph.* repmat(amp,[1 1 3]);
