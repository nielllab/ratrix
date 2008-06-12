function r=stopPrime(r)
if isempty(r.primeClient)
    error('not priming anyone -- cannot call stopPrime')
else
	r.primeClient={};
end