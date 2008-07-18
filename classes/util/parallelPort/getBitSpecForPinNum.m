function out=getBitSpecForPinNum(pinNum)
if ~isinteger(pinNum) || pinNum<1 || pinNum>17
    error('pin num must be integer 1-17')
else
    switch pinNum %bitSpec is [bitNum,regOffset,inv]
        case 1
            out=[8 2 1];
        case 2
            out=[8 0 0];
        case 3
            out=[7 0 0];
        case 4
            out=[6 0 0];
        case 5
            out=[5 0 0];
        case 6
            out=[4 0 0];
        case 7
            out=[3 0 0];
        case 8
            out=[2 0 0];
        case 9
            out=[1 0 0];
        case 10
            out=[2 1 0];
        case 11
            out=[1 1 1];
        case 12
            out=[3 1 0];
        case 13
            out=[4 1 0];
        case 14
            out=[7 2 1];
        case 15
            out=[5 1 0];
        case 16
            out=[6 2 0];
        case 17
            out=[5 2 1];
        otherwise
    end
    out=int8(out);
end