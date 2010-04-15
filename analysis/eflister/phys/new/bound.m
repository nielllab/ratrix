function in=bound(in,lims)
if ~isvector(lims) || length(lims)~=2 || diff(lims)<0 || ~isreal(lims)
    error('lims must be real ascending 2-vector')
end
in=in(in<=lims(2) & in>=lims(1));
end