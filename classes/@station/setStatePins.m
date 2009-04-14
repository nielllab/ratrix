function setStatePins(s,pinClass,state)

if strcmp(s.responseMethod,'parallelPort')
	if isscalar(state)
		state=logical(state);
	else
		error('state must be scalar')
	end

	done=false;
	possibles={ ... %edf worries this is slow
		'frame',s.framePins; ...
		'stim',s.stimPins; ...
		'phase',s.phasePins; ...
        'index',s.indexPins};

	for i=1:size(possibles,1)
		if ismember(pinClass,{'all',possibles{i,1}}) %edf worries this is slow
			done=true;
			pins=possibles{i,2}; %edf worries this is slow
			if ~isempty(pins)
				thisState=state(ones(1,length(pins.pinNums)));
				thisState(pins.invs)=~thisState(pins.invs);
				lptWriteBits(pins.decAddr,pins.bitLocs,thisState);
			else
				warning('station asked to set optional state pins it doesn''t have')
			end
		end
	end 
	if ~done
		error('unrecognized pinClass')
	end

else
	if ~ismac
		warning('can''t set state pins without parallel port')
	end
end