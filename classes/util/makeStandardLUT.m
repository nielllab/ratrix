function LUT=makeStandardLUT(bits)

ramp=linspace(0,1,2^bits);
LUT= repmat(ramp',1,3);
end