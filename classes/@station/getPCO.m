function p = getPCO(s)
p = [];

if strcmp(s.MACaddress,'C8600060B768') %widefield stim
    p.msTolerance=5;
    p.rate=11;
    p.n = round(60*p.rate);
    p.addr = dec2hex(s.decPPortAddr);
    
    p = pco(p);
end
end