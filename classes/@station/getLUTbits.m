function out=getLUTbits(s)
[gammatable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', s.screenNum);
if dacbits==log2(reallutsize)
    out=dacbits;
else
    dacbits
    reallutsize
    error('dacbits and reallutsize don''t match')
end