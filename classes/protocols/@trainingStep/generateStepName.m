function tsName = generateStepName(ts,ratrixSVN,ptbSVN)
% assembles a name by calling a getNameFragment() method on its trialMgr, stimMgr, rewadrMgr, and scheduler,
% together with the actual svnRev and ptbRev for that trial 
% (which should be added to the trialRecord in trialManager.doTrial() anyway --
%   return ptbVersion and ratrixVersion from stimOGL). 
% the base class inherited implementation for each getNameFragment() could just return 
% an abbreviated class name, but could be overridden by subclasses to include important parameter values.

tsName = [getNameFragment(ts.trialManager) '_' getNameFragment(ts.stimManager) '_' getNameFragment(ts.criterion) '_' getNameFragment(ts.scheduler)];

% append ratrix and ptb svn info
tsName = [tsName '_' ratrixSVN '_' ptbSVN];

end % end function