function    [value]  = canForceStimDetails(stimManager,forceStimDetails)
% returns true if the stimulus manager has a optional arguument in calcStim
% that forces the stimulus details to apply. Only managers that impliment
% this feature should return true, and they should be able to error check
% the force detail requests to confrim that they are valid requests... for
% example, you can request a field to change that does not exist on that
% stimulus

  value = false;

