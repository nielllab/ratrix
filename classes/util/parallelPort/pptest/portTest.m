% updated to test http://people.usd.edu/~schieber/psyc770/IO32on64.html

% note http://www.highrez.co.uk/Downloads/InpOut32/default.htm not likely
% to work on pci cards
% (http://tech.groups.yahoo.com/group/psychtoolbox/message/9328)

% actual    appears    wired   sig
% 1         13          l lick  c0-
% 2         12          r lick  d0
% 3         11                  d1
% 4         10          c lick  d2
% 5         9           frame   d3
% 6         8                   d4
% 7         7                   d5
% 8         6           valve5  d6
% 9         5           valve4  d7
% 10        4           valve3  s6
% 11        3           valve2  s7-
% 12        2           valve1  s5
% 13        1                   s4
% 14        25          gnd     c1-
% 15        24          gnd     s3
% 16        23          gnd     c2
% 17        22          gnd     c3-
% 18        21          gnd     gnd
% 19        20          gnd     gnd
% 20        19          gnd     gnd
% 21        18          gnd     gnd
% 22        17                  gnd
% 23        16                  gnd
% 24        15                  gnd
% 25        14                  gnd

function portTest

%DO NOT CHANGE THIS -- SWAPPERS USE IT TO CHECK COMPONENTS!!!

addr='0378';
addr='C800';
addr='E030'
%addr='C480';

valves=[6 7 8 1 2];
sensors=[4 2 3];
closed=char('0'*ones(1,8));
lastBlockedSensors=sensors;

ioObj = io32;
status = io32(ioObj);
if status~=0
    status
    error('driver installation not successful')
end

while true
    out=dec2bin(io32(ioObj,hex2dec(addr)+1),8)=='0';
    this=out(sensors); 
    if ~all(this==lastBlockedSensors)
        clc
        lastBlockedSensors=this %type out the state of the left, center, right sensors (zero=open, one=blocked)
        'hit space to quit, or 1-2-3 to activate valves L-C-R'
    end
    
    [blah blah codes]=KbCheck;
    if codes(KbName('space'))
        io32(ioObj,hex2dec(addr),bin2dec(closed));
        break
    end
    
    t=closed;
    t(valves(codes(cellfun(@KbName,{'1!' '2@' '3#' '4$' '5%'})) | [out(sensors) 0 0]))='1';
    io32(ioObj,hex2dec(addr),bin2dec(t));
    
    out1 = dec2bin(io32(ioObj,hex2dec(addr)),8);
    out2 = dec2bin(io32(ioObj,hex2dec(addr)+1),8);
    out3 = dec2bin(io32(ioObj,hex2dec(addr)+2),8);

    [out1 ' ' out2 ' ' out3]
end




if false
    method='pci';

    switch method

        case 'pcmcia'
            portAddress='FFF8';
        case 'pci'
            portAddress='B888';
        otherwise
            error('method should be pci or pcmcia')
    end

    leftV = '00000001';
    centerV = '00000010';
    rightV = '00000100';
    closeV = '00000000';
    leftP = 2;
    centerP = 3;
    rightP = 4;

    poking = 0;
    while 1
        pause(.01)
        %status=dec2bin(lpt1.read);

        %y=lptread(1+hex2dec(portAddress))

        status=dec2bin(lptread(1+hex2dec(portAddress)));
        %disp(sprintf('%c %c %c',status(2),status(3),status(4)));

        left=status(leftP)=='1';
        center=status(centerP)=='1';
        right=status(rightP)=='1';
        [left center right]

        if poking
            if ~(left||center||right)
                poking=0;
                lptwrite(hex2dec(portAddress),  bin2dec(closeV))
            end
        else
            if left||center||right
                poking=1;
                if left
                    valve = leftV;
                elseif center
                    valve = centerV;
                elseif right
                    valve = rightV;
                end

                lptwrite(hex2dec(portAddress), bin2dec(valve))
            end
        end
    end
end