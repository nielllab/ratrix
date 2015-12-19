function portTest

%DO NOT CHANGE THIS -- SWAPPERS USE IT TO CHECK COMPONENTS!!!
addr='0378';
%addr='E800';
%addr='E030';
%addr='E480';
valves=[6 7 8];
sensors=[4 2 3];

states = '01';

flipParity = true;
if flipParity
    c=2;
else
    c=1;
end

c=states(c);

closed=char(states(1)*ones(1,8));
lastBlockedSensors=sensors;

while true
    out=dec2bin(lptread(hex2dec(addr)+1),8)==c;
    this=out(sensors); 
    if ~all(this==lastBlockedSensors)
        clc
        lastBlockedSensors=this %type out the state of the left, center, right sensors (zero=open, one=blocked)
        'hit space to quit, or 1-2-3 to activate valves L-C-R'
    end
    
    [~, ~, codes]=KbCheck;
    if codes(KbName('space'))
        lptwrite(hex2dec(addr),bin2dec(closed));
        break
    end
    
    t=closed;
    t(valves(codes(cellfun(@KbName,{'1!' '2@' '3#'})) | out(sensors)))=states(2);
    lptwrite(hex2dec(addr),bin2dec(t));
    
    %dec2bin(lptread(hex2dec(addr)),8)
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