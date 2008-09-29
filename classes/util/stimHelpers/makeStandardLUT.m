function LUT=makeStandardLUT(bits)

%note dacbits was probably the wrong thing to send in here, which according
%to the docs for screen(loadnormalizedgammatable) is just the precision for
%the LUT entries -- reallutsize would have been the desired quantity, but
%see warning below
if bits~=8
    warning('LUT must be 256 rows, even if reallutsize>256 -- docs for screen(loadnormalizedgammatable) specify this, and trying to load a 1024 row LUT does not change LUT on osx (altho it also doesn''t error), even though it returns dacbits=10 and reallutsize=1024')
    bits=8;
end

ramp=linspace(0,1,2^bits);
LUT= repmat(ramp',1,3);
end