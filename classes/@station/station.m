function s=station(varargin)
    % STATION  class constructor.
	% s = station(stationSpec)
	%
	% stationSpec.id
	% stationSpec.path
	% stationSpec.screenNum
	% stationSpec.soundOn
	% stationSpec.rewardMethod        (one of 'localPump','serverPump', or 'localTimed')
	% stationSpec.MACaddress
	% stationSpec.physicalLocation    ([rackID shelf position] -- upperleft is 1,1)
	% stationSpec.portSpec
	%   if not using parallel port, a scalar integer number of ports
	%   if using parallel port for responses/rewards, portSpec should be:
	%       portSpec.parallelPortAddress
	%       portSpec.valveSpec
	%           if stationSpec.rewardMethod in {'serverPump' 'localTimed'} an integer vector of valvePins,
	%           if stationSpec.rewardMethod=='localPump', valveSpec should be:
	%               valveSpec.valvePins
	%               valveSpec.pumpObject
	%       portSpec.sensorPins
	%       portSpec.framePins
	%       portSpec.phasePins
	%       portSpec.stimPins
	%       portSpec.indexPins
	%       portSpec.eyePuffPins
    %       portSpec.laserPins
	% stationSpec.datanet
	% stationSpec.eyeTracker

    s.ptbVersion    = [];
    s.screenVersion = [];
    s.skipSyncTests = [];
    s.matlabVersion = [];
    s.matlab64      = [];
    s.win64         = [];
    s.computer      = [];
    s.diary         = []; 
    
	s.id=0;
	s.path='';
	s.screenNum=0;
	s.soundOn=0;
	s.rewardMethod='';
	s.MACaddress='';
	s.physicalLocation=[];
	s.numPorts=0;

	s.responseMethod='';
	s.decPPortAddr=hex2dec('E030');
    %s.decPPortAddr='';
	s.valvePins=[];
	s.sensorPins=[];
	s.framePins=[];
	s.phasePins=[];
	s.stimPins=[];
	s.indexPins=[];
	s.eyePuffPins=[];
    s.laserPins=[];

	s.localPump=[];
	s.localPumpInited=false;

	s.datanet=[];
	s.eyeTracker=[];

	needToInit=false;
	usingPport=false;

	s.ifi=[];
	s.window=[];
    s.imagingTasks=[];

	switch nargin
		case 0
			% if no input arguments, create a default object
			s = class(s,'station');
		case 1
			% if single argument of this class type, return it
			if isa(varargin{1},'station')
				s = varargin{1};
			elseif isstruct(varargin{1}) && all(ismember({'id','path','screenNum','soundOn','rewardMethod','MACaddress','physicalLocation','portSpec','datanet','eyeTracker'},fields(varargin{1})))
				in=varargin{1};
				if isscalar(in.portSpec) && isinteger(in.portSpec)&& in.portSpec>0 %no parallel port
					s.responseMethod='keyboard';
					s.numPorts=in.portSpec;
					needToInit=true;
				elseif isstruct(in.portSpec) && all(ismember({'parallelPortAddress','valveSpec','sensorPins','indexPins','framePins','stimPins','phasePins','eyePuffPins','laserPins'},fields(in.portSpec))) %with parallel port
					s.responseMethod='parallelPort';
					s.decPPortAddr=hex2dec(in.portSpec.parallelPortAddress);

					if isstruct(in.portSpec.valveSpec) && all(ismember({'valvePins','pumpObject'},fields(in.portSpec.valveSpec))) && ((isvector(in.portSpec.valveSpec.valvePins) && isinteger(in.portSpec.valveSpec.valvePins)) || isempty(in.portSpec.valveSpec.valvePins)) && isa(in.portSpec.valveSpec.pumpObject,'localPump')
						s.valvePins=in.portSpec.valveSpec.valvePins;
						s.localPump=in.portSpec.valveSpec.pumpObject;
						warning('currently no one checks that the pump''s pins don''t conflict with the other assigned pins -- needs to be fixed!  (do this when change pump to use our porttalk method rather than the dataacq toolbox...)')
					elseif (isvector(in.portSpec.valveSpec) && isinteger(in.portSpec.valveSpec)) || isempty(in.portSpec.valveSpec)
						s.valvePins=in.portSpec.valveSpec;
					else
						error('valveSpec must be vector of integers or struct with fields valvePins (vector of integers) and pumpObject (a localPump object)')
					end

					if isvector(in.portSpec.sensorPins) && isinteger(in.portSpec.sensorPins)
						s.sensorPins=in.portSpec.sensorPins;
					else
						error('sensorPins must be vector of integers')
					end

					optionalPins={'indexPins','framePins','phasePins','stimPins','eyePuffPins','laserPins'};

					for eNum=1:length(optionalPins)
						eVal=in.portSpec.(optionalPins{eNum});
						if isempty(eVal) || (isvector(eVal) && isinteger(eVal) && all(eVal>0))
							s.(optionalPins{eNum})=eVal;
						else
							error('%s must be empty or vector of positive integers',optionalPins{eNum})
						end
					end

					usingPport=true;
					needToInit=true;

				else
					in.portSpec
					class(in.portSpec)
					if isstruct(in.portSpec)
						fields(in.portSpec)
                    end
					error('portSpec must be scalar integer >0 or a parallel port struct')
				end
			else
				error('Input argument is not a station object or struct')
			end
		otherwise
			error('Wrong number of input arguments')
	end

	if usingPport
		if ismember(s.decPPortAddr,hex2dec({'B888','0378','FFF8','C800'}))
			%pass
		else
			error('need a parallel port base address (should be ''0378'' (built-in) ''B888'' (pci) or ''FFF8'' (pcmcia)) -- under LPT ports in device manager, resources tab, I/O Range (first number is base address).');
			%base address is DATA register -- output -- pins 2-9
			%add 1 for STATUS register -- input -- pins 10,11(inverted),12,13,15
			%add 2 for CONTROL register -- bidirectional -- pins 1(inverted),14(inverted),16,17(inverted)
		end

		if ~strcmp(s.responseMethod,'parallelPort') && isinteger(s.sensorPins) && isscalar(s.sensorPins) && s.sensorPins>0
			s.numPorts=s.sensorPins;
			if length(s.valvePins)==s.numPorts || isempty(s.valvePins)
				%pass
			else
				error('if response method is not parallel port, sensorPins should be integer >0 that is number of ports, and valvePins should either be empty or have that number of elements')
			end
		elseif strcmp(s.responseMethod,'parallelPort') && (length(s.valvePins)==length(s.sensorPins) || isempty(s.valvePins) || isscalar(s.valvePins)) && length(s.sensorPins)>0
			s.numPorts=length(s.sensorPins);
			
			[s.sensorPins assignedSoFar]=assignPins(s.sensorPins,'read',s.decPPortAddr,[],'sensorPins');
		else
			error('if responseMethod is parallelPort, sensorPins and valvePins must be same length and have at least one element (or valvePins can be empty or have one element).  if responseMethod is not parallelPort, sensorPins must be scalar integer >0 that is number of ports.')
		end

		[s.valvePins assignedSoFar]=assignPins(s.valvePins,'write',s.decPPortAddr,assignedSoFar,'valvePins');

		for eNum=1:length(optionalPins)
			[s.(optionalPins{eNum}) assignedSoFar]=assignPins(s.(optionalPins{eNum}),'write',s.decPPortAddr,assignedSoFar,optionalPins{eNum});
		end
	end

	if needToInit
		s.id=in.id;
		s.path=in.path;
		s.screenNum=in.screenNum;
		s.soundOn=in.soundOn;
		s.rewardMethod=in.rewardMethod;
		s.MACaddress=in.MACaddress;
		s.physicalLocation=in.physicalLocation;
		s.datanet=in.datanet;
		s.eyeTracker=in.eyeTracker;

		if strcmp(class(s.id),'char')
			parse = textscan(s.id, '%d%s','expChars','');
			if iscell(parse) && all(size(parse)==[1 2]) && ~isempty(parse{1}) && ~isempty(parse{2})
				%pass
			else
				s.id
				class(s.id)
				error('textscan failed on id')
			end
		else
			class(s.id)
			s.id
			error('id must be a string of format <rack num><rack letter>, example ''2C''')
		end

		if checkPath(s.path)
			%pass
		else
			error('path check failed.  must provide fully resolved path to the station.')
		end

		if s.screenNum>=0 && isinteger(s.screenNum)
			s.screenNum=double(s.screenNum);
			%pass
		else
			error('screen num should be integer >=0')
		end

		if islogical(s.soundOn)
			%pass
		else
			error('sound on should be logical')
		end

		if ~isempty(s.localPump)
			if isa(s.localPump,'localPump') && strcmp(s.rewardMethod,'localPump')
				%pass
			else
				error('bad local pump or rewardMethod not ''localPump''')
			end
		else
			if ~strcmp(s.rewardMethod,'localPump')
				%pass
			else
				error('need a local pump for rewardMethod ''localPump''')
			end
		end

		if (ismember(s.rewardMethod,{'serverPump','localPump'}) && usingPport && ~isempty(s.valvePins)) || strcmp(s.rewardMethod,'localTimed')
			%pass
		else
			error('rewardMethod must be localTimed, localPump, or serverPump (pumps currently only work with pport rewards, so valvePins must not be empty)')
		end

		if isMACaddress(s.MACaddress)
			%pass
		else
			error('mac address must be a 12 character hex string')
		end

		if isvector(s.physicalLocation) && isinteger(s.physicalLocation) && length(s.physicalLocation)==3 && all(s.physicalLocation>0)
			%pass
		else
			s.physicalLocation
			error('location must be vector of 3 integers [rackID shelf position], upper left is 1,1')
		end

		if isempty(s.datanet) || isa(s.datanet,'datanet')
			%pass
		else
			s.datanet
			error('datanet must be empty or a datanet object');
		end

		if isempty(s.eyeTracker) || isa(s.eyeTracker,'eyeTracker')
			%pass
		else
			s.eyeTracker
			error('eyeTracker must be empty or a datanet object');
		end

		s = class(s,'station');
    end

end

function [out assignedSoFar]=assignPins(pins,dir,baseAddr,dontMatch,pinGroupName)
	out=[];
	checks={};
	for cNum=1:length(pins)
		checks{end+1}={dec2hex(baseAddr),pins(cNum)};
	end

	if all(goodPins(checks)) && length(unique(pins))==length(pins)

		for cNum=1:length(pins)
			if getDirForPinNum(pins(cNum),dir)
				spec=getBitSpecForPinNum(pins(cNum));

				out(cNum).pin=pins(cNum);
				out(cNum).decAddr=baseAddr+double(spec(2));
				out(cNum).bitLoc=spec(1);
				out(cNum).inv=logical(spec(3));
                
                %move this somewhere sensible!
                [a b]=getMACaddress;
                if ismember(b,{'F46D04EFE0FF','F46D04EFE0E5','5404A6EF66C9','5404A6EF6726'}) && strcmp(pinGroupName,'sensorPins')
                    out(cNum).inv = ~out(cNum).inv;
                end
			else
				error('pin not available for that dir')
			end
		end

	else
		error('pins must be unique integers that represent parallel port pins')
	end

	for cNum=1:length(out)
		if ismember(out(cNum).pin,dontMatch)
			error('pin matches an already assigned pin')
		end
	end

	emptyPinRec=struct('decAddr',{},'pinNums',{},'invs',{},'bitLocs',{});

	if isempty(pins)
		thisRec=emptyPinRec;
	elseif all(out(1).decAddr==[out.decAddr])
		thisRec.decAddr=out(1).decAddr;
		thisRec.pinNums=[out.pin];
		thisRec.invs=[out.inv];
		thisRec.bitLocs=[out.bitLoc];
	else
		error('%s pins must be all on the same parallel port register',pinGroupName)
	end
	out=thisRec;

	assignedSoFar=[dontMatch pins];
end