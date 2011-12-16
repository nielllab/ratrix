function lptwriteLinux(pins,vals,slowChecks,port,addr)

% lptwriteLinux(pins,vals,[slowChecks],[port],[addr])
%
% set TTL levels on parallel port pins under linux
%
% Arguments:
% pins       integer vector of hardware pin nums to set
% vals       logical vector same size as pins indicating TTL levels
% slowChecks optional logical scalar (default true) 
%               indicates whether to run extensive and slow input 
%               validation, checking all relevant OS information
%               regarding the ports (that i could find)
% port       optional integer vector indicating parallel port indices
%               defaults to first port found in /proc/sys/dev/parport/
% addr       optional integer vector indicating hardware memory address
%               corresponding ports.
%               eg, the first value in /proc/sys/dev/parport/parport0/base-addr
%
% if multiple ports/addrs are supplied, the same set of vals/pins are used for each.
%
% if you want lptwriteLinux to be as fast as possible, supply both the port
% and addr, and set slowChecks to false.
%
% the parallel port's pins are divided into three registers, and some pins
% are logically inverted.  lptwriteLinux takes care of these details for
% you.
%
% lptwriteLinux works for built-in as well as add-on (PCI) parallel ports
% if their drivers are installed.  on fedora 15, i found both were
% installed by default.
%
% lptwriteLinux requires the corresponding compiled mex file (lptwriteLinuxMex).  
% for fastest operation, you could call it directly, but it does no input 
% validation, and depends on formatting provided by getBitSpecForPinNum.
%
% Examples:
% lptwriteLinux(uint8([1 10 15]),[true false true])
% lptwriteLinux(uint8([1 10 15]),[true false true],true,uint8(0),uint64(51200))
%
% Author: Erik Flister, University Oregon, 2011 (C).

if ~exist('slowChecks','var') || isempty(slowChecks)
    slowChecks=true;
end

useSscanf=true; %maybe textscan is faster?
pportDir='/proc/sys/dev/parport/';

if slowChecks
    if ~isunix
        error('only runs on unix')
    end
    
    if ~isvector(pins) || ~isinteger(pins) || ~all(pins>0) || ~all(pins<=17) || length(unique(pins))<length(pins)
        error('pins must be integer vector 1<=pins<=17 with no duplicates')
    end
    
    if ~islogical(vals) || ~all(size(vals)==size(pins))
        error('vals must be logical vector same size as pins')
    end
    
    [s dmesg]=unix('dmesg | grep parport');
    if s~=0
        error('couldn''t dmesg')
    end
    
    [s dev]=unix('ls -al /dev | grep parport');
    if s~=0
        error('couldn''t dev')
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
            error('couldn''t cat base-adddr')
        end
        if useSscanf
            [a, count, errmsg] = sscanf(a, '%u 0');
            if count==1 && isempty(errmsg) && ~isempty(a)
                a=uint64(a);
            else
                error('bad addr')
            end
        else
            a = textscan(a, '%u64 0');
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

bitSpecs=getBitSpecForPinNum(pins); %[bitNum,regOffset,inv]
vals(logical(bitSpecs(:,3)))=~vals(logical(bitSpecs(:,3)));

% w=warning('off', 'MATLAB:concatenation:integerInteraction');
lptwriteLinuxMex([uint64(ports(:)) uint64(addr(:))],uint8([bitSpecs(:,1:2) vals(:)]));
% warning(w.state, 'MATLAB:concatenation:integerInteraction');
end

function out=getBitSpecForPinNum(pinNum)
pportSpec=uint8([... %[bitNum,regOffset,inv]
    8 2 1; %1
    8 0 0; %2
    7 0 0; %3
    6 0 0; %4
    5 0 0; %5
    4 0 0; %6
    3 0 0; %7
    2 0 0; %8
    1 0 0; %9
    2 1 0; %10
    1 1 1; %11
    3 1 0; %12
    4 1 0; %13
    7 2 1; %14
    5 1 0; %15
    6 2 0; %16
    5 2 1; %17
    ]);
try
    out=pportSpec(pinNum,:);
catch e
    e
    error('pin num must be integer 1-17')
end
end