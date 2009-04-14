function out=getIndexPulse(s,i)
 out=s.indexPulses(i);
 if i==1 && ~out
     i
     s.indexPulses
     warning('it happened')
 end