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