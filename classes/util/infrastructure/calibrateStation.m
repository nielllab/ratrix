function calibrateStation
mins = 5;
gap = .25;
num = ceil(mins*60/(2*4*gap));

base = .04;
fact = 2;

precision = .1;

[pathstr, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(fileparts(fileparts(pathstr))),'bootstrap'));
setupEnvironment;

input('hit enter to prime the ports')
portTest;
clc

[ratio, start]=checkBoth(num,base,fact,gap,precision);

fprintf('\nnow checking calibration fix factor %g\n',1/ratio);

checkBoth(num,base,fact,gap,precision,start,ratio);
end

function [ratio left rate]=checkBoth(num,base,fact,gap,precision,start,fix)
if ~exist('start','var') || isempty(start)
    start=[];
    while isempty(start)
        start = input('\nenter the water level\n');
    end
end

if ~all(cellfun(@(f)f(start),{@isscalar @isnumeric @isreal @(x)x>0}))
    error('has to be a real positive scalar')
end

if ~exist('fix','var') || isempty(fix)
    fix = 1;
end

calibrateLocal(num,base*[1 0 fact/fix],gap,precision);
right = input('\nenter the water level\n');

if ~all(cellfun(@(f)f(right),{@isscalar @isnumeric @isreal @(x)x>0 @(x)x<start}))
    error('has to be a real scalar smaller than previous')
end

calibrateLocal(num,base*[fact*fix 0 1],gap,precision);
left = input('\nenter the water level\n');

if ~all(cellfun(@(f)f(left),{@isscalar @isnumeric @isreal @(x)x>0 @(x)x<right}))
    error('has to be a real scalar smaller than previous')
end

% base = .04
% fact = 2
% num = 100
% start = 37 % 40
% right = 36.9 % 38
% left = 36.4 % 37

R = (left - right - fact*right + fact*start)/(fact^2 - 1);
L = (right - start - fact*left + fact*right)/(fact^2 - 1);

if any([R L]<=0)
    R
    L
    ratio
    error('R and L should both be strictly positive -- one of the valves seems very clogged')
end

ratio = R/L;
[n d] = rat(ratio);
fprintf('\nfound R:L is %d:%d (%g%% off)\n',n,d, round(10000*(ratio-1))/100);

rate = 10*L/(base*num); % ul/10ms
fprintf('\nif measurements were in ml, then volume per 10ms on left side was %gul (that means 2ml in 150 rewards needs %dms each)\n',rate,round((2*10^4)/(150*rate)));
end

% algebra for the curious:
%
% syms L R fact start right left
% a = L + fact*R - start + right
% b = fact*L + R - right + left
% [L,R] = solve(a,b,L,R)
% ------------------------------
% L =
% (right - start - fact*left + fact*right)/(fact^2 - 1)
% R =
% (left - right - fact*right + fact*start)/(fact^2 - 1)
%
% factor(R/L)
% ans =
% (right - left + fact*right - fact*start)/(start - right + fact*left - fact*right)
%
% (right*(fact + 1) - fact*start - left)/(start + fact*left - right*(fact + 1))

% and by hand:
% 
% L + fact*R = start - right
% fact*L + R = right - left
% --------------------------
% L = (right - left - R)/fact
% (right - left - R)/fact + fact*R = start - right
% fact*R - R/fact = start - right - (right - left)/fact
% R*(fact - 1/fact) = start - right - right/fact + left/fact
% R*(fact^2 - 1) = fact*(start - right) - right + left
% R = (fact*start - fact*right - right + left)/(fact^2 - 1)
% (*) R = (fact*start + left - right*(fact + 1))/((fact + 1)*(fact - 1))
% L = (right - left - (fact*start + left - right*(fact + 1))/((fact + 1)*(fact - 1)))/fact
%   = right/fact - left/fact - (start + left/fact - right - right/fact)/((fact + 1)*(fact - 1))
%   = (()*()*right/fact - ()*()*left/fact - start - left/fact + right + right/fact)/(()*())
%   = (right/fact * (()*() + 1) - left/fact * (()*() + 1) - start + right)/(()*())
%   = ((right - left) * (1 + ()*())/fact - start + right)/(()*())
% (*) L = ((right - left) * fact - start + right)/(()*())
