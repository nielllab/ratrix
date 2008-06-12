function p=protocol(varargin)
% PROTOCOL  class constructor. 
% p = protocol(name,{trainingStep array}) 

switch nargin
case 0 
% if no input arguments, create a default object
    p.id='';    %BAD BUG!!  WOW.  I HAD THESE DEFINED IN THE OPPOSITE ORDER BY CHANCE, AND THE LOAD COMMAND COULDN'T HANDLE IT == TURNED IT TO A STRUCT THAT THEN WOULDN"T DO PROTOCOL THINGS
    
    p.trainingSteps={};
    
    p = class(p,'protocol');      
case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'protocol'))
        p = varargin{1}; 
    else
        error('Input argument is not a protocol object')
    end
case 2
    p.id=varargin{1};
    
    if isVectorOfType(varargin{2},'trainingStep')
        p.trainingSteps=varargin{2};
        
    else
        error('need array of trainingSteps')
    end   
    p = class(p,'protocol');
otherwise
    error('Wrong number of input arguments')
end