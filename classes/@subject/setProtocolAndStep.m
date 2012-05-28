function [s r]=setProtocolAndStep(s,p,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum,i,r,comment,auth)
% INPUTS
%   s                       subject object
%   p                       protocol (eg from setProtocol)
%   thisIsANewProtocol  	if FALSE, does not rewrite protocol descr to log
%   thisIsANewTrainingStep  if FALSE, does not rewrite trainingstep descr to log
%   thisIsANewStepNum       if FALSE, does not log setting of new step number
%   i                       index of training step
%   r                       ratrix object
%   comment                 string that will be saved to log file
%   auth                    string which must be an authorized user id
%                           (see ratrix.authorCheck)
% OUTPUTS
% s     subject object
% r     ratrix object
%
% example call
%     [subj r]=setProtocolAndStep(subj,p,1,0,1,1,r,'first try','edf');

if isa(p,'protocol') && isa(r,'ratrix') && ~isempty(getSubjectFromID(r,s.id)) && ~subjectIDRunning(r,s.id)
    %     i
    %     getNumTrainingSteps(p)
    
    if i<=getNumTrainingSteps(p) && i>=0 && isscalar(i) && mod(i,1)==0 %mod(i,1)==0 checks that i is an integer (even as a double type)
        if authorCheck(r,auth)
            s.protocol=p;
            s.trainingStepNum=uint8(i); % 1/9/09 - force to uint8 to pass isinteger tests down the line
            
            if strcmp(auth,'ratrix')
                s.protocolVersion.autoVersion=s.protocolVersion.autoVersion+1;
            else
                s.protocolVersion.autoVersion=1;
                s.protocolVersion.manualVersion=s.protocolVersion.manualVersion+1;
            end
            s.protocolVersion.date=datevec(now);
            s.protocolVersion.author=auth;
            %consider recording comment here so we don't have to parse the text log?
            
            r=updateSubjectProtocol(r,s,comment,auth,thisIsANewProtocol,thisIsANewTrainingStep,thisIsANewStepNum);
            
        else
            error('author failed authentication')
        end
    else
        error('need a valid integer step number')
    end
else
    isa(p,'protocol')
    isa(r,'ratrix')
    ~isempty(getSubjectFromID(r,s.id))
    ~subjectIDRunning(r,s.id)
    error('need a protocol object, a valid ratrix with that contains this subject, and this subject can''t be running')
end