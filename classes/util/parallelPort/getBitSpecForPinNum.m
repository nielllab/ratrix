function out=getBitSpecForPinNum(pinNum)
pportSpec=int8([... %[bitNum,regOffset,inv]
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