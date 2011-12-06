function lptwriteLinux(port,pins,vals,slowChecks,addrs)
if ~exist('slowChecks','var') || isempty(slowChecks)
    slowChecks=true;
end

if ~exist('addrs','var') || isempty(addrs)
    addrs=zeros(size(port),'uint64');
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
    
    if ~isvector(port) || ~isinteger(port) || ~all(port>=0) || ~all(ismember(port,ports)) || length(unique(port))<length(port)
        error('port must be integer vector of valid port IDs with no duplicates')
    end
    
    if ~isvector(addrs) || ~isinteger(addrs) || ~all(addrs>=0) || ~all(size(addrs)==size(port))
        error('addrs must be integer vector >=0 same size as port')
    end
    
    ports=intersect(port,ports);
    if length(ports)<length(port)
        error('couldn''t find all ports')
    end
else
    ports=port;
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
    
    if addrs(i)==0
        [s addr]=unix([base 'base-addr']);
        if s~=0
            error('couldn''t cat base-adddr')
        end
        if useSscanf
            [A, count, errmsg] = sscanf(addr, '%u 0');
            if count==1 && isempty(errmsg) && ~isempty(A)
                addrs(i)=uint64(A);
            else
                error('bad addr')
            end
        else
            C = textscan(addr, '%u64 0');
            if ~isempty(C{1})
                addrs(i)=C{1};
            else
                error('bad addr')
            end
        end
    end
end

bitSpecs=getBitSpecForPinNum(pins); %[bitNum,regOffset,inv]
vals(bitSpecs(:,3))=~vals(bitSpecs(:,3));

lptwriteLinux([ports(:) addrs(:)],[bitSpecs(:,1:2) vals(:)]);
end