function immutable=getImmutable(rm)
%if the rm is immutable then trialManager can't overwrite it with
%setReinforcementManager.  Default is changeable. i.e. mutable
error('method defunct') %pmm 090112, can be deleted
immutable=false;