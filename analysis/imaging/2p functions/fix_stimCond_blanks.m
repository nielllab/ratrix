for i = 1:length(stimRec.cond)
   cond =  stimRec.cond(i);
   if cond == 0
       stimRec.cond(i) = cond_past;
   else
       cond_past = cond;
   end
end