function input = pp(pins,output,slowChecks,port,addr)

% [input] = pp(pins,[output],[slowChecks],[port],[address])
%
% read/write TTL levels on parallel port pins under linux
%
% Arguments:
% pins       integer vector of hardware pin nums
% output     logical vector same size as pins indicating TTL levels to
%               write -- omit or use [] to merely read
% slowChecks optional logical scalar (default true)
%               indicates whether to run extensive and slow input
%               validation, checking all relevant OS information
%               regarding the ports (that i could find)
%               if set to false when writing to incorrect addr, you could damage your OS
% port       optional integer vector indicating parallel port indices
%               defaults to first port found in /proc/sys/dev/parport/
% address    optional integer vector indicating hardware memory address
%               corresponding to ports.
%               eg, the first value in /proc/sys/dev/parport/parport0/base-addr
%
% Returns: logical matrix of values read (rows correspond to pins, columns
% to ports) -- use no return value to merely write
%
% if multiple ports/addrs are supplied, the same output/pins are used for each.
%
% if you want pp to be as fast as possible, supply both the port
% and addr, and set slowChecks to false.
%
% the parallel port's pins are divided into three registers, and some pins
% are logically inverted.  pp takes care of these details for you.
%
% you cannot write to the status register (pins 10, 11-13, 15).
% values read from the data register (pins 2-9) are likely the values
% you wrote, not input from external equipment.  use the status or control
% register (pins 1, 14, 16-17) to read input.
%
% pp works for built-in as well as add-on (PCI/PCMCIA) parallel ports
% if their drivers are installed.  on fedora 15, i found both to be
% installed by default.
%
% pp requires the corresponding compiled mex file (ppMex).
% you may need to recompile it for your arch -- see instructions in ppMex.c.
% for fastest operation, you could call ppMex directly, but it does no input
% validation, and depends on formatting provided by getPinInfo as performed 
% in this file.
%
% ppMex is currently configured to use iopl/inb/outb, which require root
% (ie, you need to start matlab with sudo).  we may someday switch to ppdev,
% which is not supposed to require root, but the current prototype ppdev code 
% seems to need it to read /dev/parport* anyway.
%
% Examples:
% vals = pp(uint8([1 2 10 3]))                               % read some pins (slow)
% vals = pp(uint8([1 2 10 3]),[],false,uint8(0),uint64(888)) % read some pins (fast)
%
% pp(uint8([16 4 8 1]),[true false true true])                            % write to some pins (slow)
% pp(uint8([16 4 8 1]),[true false true true],true, uint8(0),uint64(888)) % write to some pins (slow -- validates port address for safety)
% pp(uint8([16 4 8 1]),[true false true true],false,uint8(0),uint64(888)) % write to some pins (fast -- dangerous if addr is incorrect)
%
% vals = pp(uint8([16 4 8 1]),[true false true true]) % write some pins, then immediately read from them, hopefully verifying what you wrote
%
% Copyright (C) 2011 Erik Flister, University of Oregon, erik.flister <at> gmail

if ~exist('slowChecks','var') || isempty(slowChecks)
    slowChecks=true;
end

if ~exist('output','var')
    output = logical([]);
end

useSscanf=true; %maybe textscan is faster?
pportDir='/proc/sys/dev/parport/';

if slowChecks
    if ~isunix || ismac %IsLinux probably more appropriate, but requires psychtoolbox
        error('only runs on linux')
    end
    
    if ~isvector(pins) || ~isinteger(pins) || ~all(pins>0) || ~all(pins<=17) || length(unique(pins))<length(pins)
        error('pins must be integer vector 1<=pins<=17 with no duplicates')
    end
    
    if ~islogical(output) || (~isempty(output) && ~all(size(output)==size(pins)))
        error('output must be logical vector same size as pins')
    end
    
    [s dmesg]=unix('dmesg | grep parport');
    if s~=0
        error('couldn''t dmesg')
    end
    
    [s dev]=unix('ls -al /dev | grep parport');
    if s~=0
        error('couldn''t dev')
    end
    
    [s drv]=unix('grep ppdev /proc/devices');
    if s~=0
        error('couldn''t proc')
    end
    
    [s lsm]=unix('lsmod | grep ppdev');
    if s~=0
        error('couldn''t lsmod ppdev')
    end
    
    [s lsmp]=unix('lsmod | grep parport');
    if s~=0
        error('couldn''t lsmod parport')
    end
    
    [s iop]=unix('cat /proc/ioports | grep parport');
    if s~=0
        error('couldn''t ioports')
    end
end

if slowChecks || ~exist('port','var') || isempty(port)
    ports=uint8([]);
    
    d=dir(pportDir);
    for i=1:length(d)
        if d(i).isdir
            if useSscanf
                [A, count, errmsg] = sscanf(d(i).name, 'parport%u');
                if count==1 && isempty(errmsg) && ~isempty(A)
                    ports(end+1)=uint8(A);
                end
            else
                C = textscan(d(i).name, 'parport%u8');
                if ~isempty(C{1})
                    ports(end+1)=C{1};
                end
            end
        end
    end
    
    if ~exist('port','var') || isempty(port)
        port=ports(1);
    end
    
    if ~isvector(port) || ~isinteger(port) || ~all(port>=0) || ~all(ismember(port,ports)) || length(unique(port))<length(port)
        error('port must be integer vector of valid port IDs with no duplicates')
    end
    
    ports=intersect(port,ports);
    if length(ports)<length(port)
        error('couldn''t find all ports')
    end
else
    ports=port;
end

if ~exist('addr','var') || isempty(addr)
    addr=zeros(size(port),'uint64');
end

if slowChecks
    if ~isvector(addr) || ~isinteger(addr) || ~all(addr>=0) || ~all(size(addr)==size(port))
        error('addr must be integer vector >=0 same size as port')
    end
end

for i=1:length(ports)
    name = ['parport' num2str(ports(i))];
    base = ['cat ' pportDir name filesep];
    
    if slowChecks
        [s modes]=unix([base 'modes']);
        if s~=0
            error('couldn''t cat modes')
        end
        if isempty(strfind(modes,'SPP'))
            error('SPP not supported')
        end
        
        if isempty(strfind(dev,name)) || isempty(strfind(dmesg,name))
            error('pport in pportDir but not dev or dmesg')
        end
    end
    
    if addr(i)==0 || slowChecks
        [s a]=unix([base 'base-addr']);
        if s~=0
            error('couldn''t cat base-addr')
        end
        if useSscanf
            [a, count, errmsg] = sscanf(a, '%u %*u'); 
            % the second number is always 0 for me (ubuntu 11/fedora 15), 
            % but kkd reported a 1912 on parport0 for his machine (ubuntu 12.04).  
            % according to http://www.kernel.org/doc/Documentation/parport.txt 
            % this is just another address for the port?  what's it for?
            if count==1 && isempty(errmsg) && ~isempty(a)
                a=uint64(a);
            else
                a
                count
                errmsg
                [s a]=unix([base 'base-addr'])
                error('bad addr')
            end
        else
            a = textscan(a, '%u64 %*u64');
            if ~isempty(a{1})
                a=a{1};
            else
                error('bad addr')
            end
        end
        if addr(i)==0
            addr(i)=a;
        else
            if addr(i)~=a
                error('port and address don''t match')
            end
        end
    end
end

bitSpecs=getPinInfo(pins);
inds = logical(bitSpecs(:,3));
    function x = inv (x)        
        x(inds) = ~x(inds);
    end

if ~isempty(output)
    output = inv(output);
end

% w=warning('off', 'MATLAB:concatenation:integerInteraction');
input = inv(ppMex([uint64(ports(:)) uint64(addr(:))],[bitSpecs(:,1:2) uint8(output(:))]));
% warning(w.state, 'MATLAB:concatenation:integerInteraction');
end

function out=getPinInfo(pinNum)
pportSpec=uint8([... %[bitNum,regOffset,inv]
    0 2 1; %1
    0 0 0; %2
    1 0 0; %3
    2 0 0; %4
    3 0 0; %5
    4 0 0; %6
    5 0 0; %7
    6 0 0; %8
    7 0 0; %9
    6 1 0; %10
    7 1 1; %11
    5 1 0; %12
    4 1 0; %13
    1 2 1; %14
    3 1 0; %15
    2 2 0; %16
    3 2 1; %17
    ]);
try
    out=pportSpec(pinNum,:);
catch e
    e
    error('pin num must be integer 1-17')
end
end
