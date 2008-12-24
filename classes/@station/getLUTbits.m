function out=getLUTbits(s)
[gammatable, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', s.screenNum);
if dacbits==log2(reallutsize)
    out=dacbits;
elseif log2(reallutsize)==8
    out=8; %what we really care about is log2(reallutsize), see comment in makeStandardLUT()
    warning('dacbits and reallutsize don''t match')
else
    dacbits
    reallutsize
    error('dacbits and reallutsize don''t match')
end