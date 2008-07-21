function out=getDisplaySize(s)
[a b]=Screen('DisplaySize',s.screenNum);
out=[a b];