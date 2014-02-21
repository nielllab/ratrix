function ledPhotodiodeTest
old = cd('C:\Users\nlab\Desktop\ratrix\bootstrap');
setupEnvironment;
cd(old);

durMins = .1;
numReps = 20;

led = uint8(5);
addr = hex2dec('0378');
slow = false;

for i = 1:numReps
    pp(led,true ,slow,[],addr);
    WaitSecs(durMins*60*3/4);
    pp(led,false,slow,[],addr);
    WaitSecs(durMins*60*1/4);
end

end