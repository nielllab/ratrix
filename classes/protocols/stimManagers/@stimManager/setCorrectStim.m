function sm = setCorrectStim(sm,ss)
if isa(ss,'stimSpec')
    sm.correctStim=ss;
else
    error('must be a stimSpec')
end