function [hrs y]=scratch2
% D:\physDB\164\02.27.09\8d315fc3a807c5b249e5ebf3e99a8cbd19e0ffd4 %1G
% D:\physDB\164\03.17.09\3b43c16b7b96f501204aa3bca54bd522856d2320
% D:\physDB\164\03.25.09\fd0540a23f6a44ae778fdc547bb870bf9bd1f5e0
% D:\physDB\164\03.25.09\d323c77443323baa89ecf35cd31758cd6446bdfd %1.5G
% D:\physDB\164\03.13.09\1dde0e88c83352d9790baa30af013905e63a48e7 %2G
% D:\physDB\188\04.23.09\a7e4526229bb5cd78d91e543fc4a0125360ea849
% D:\physDB\188\04.24.09\9196f9c63cf78cac462dac2cedd55306961b7fd0
% D:\physDB\188\04.29.09\eb9916e6e433e0599a743952acd19ec218eb83cb %2.2G
% D:\physDB\164\03.25.09\d6ed451b974604f67bca8bb76c3b4cba6d6bdb67 %4.6G -- something like 3.5 hrs
% D:\physDB\188\04.23.09\4b45921ce9ef4421aa984128a39f2203b8f9a381 %4.1G

b='D:\physDB\164\03.25.09\d6ed451b974604f67bca8bb76c3b4cba6d6bdb67\stim.d6ed451b974604f67bca8bb76c3b4cba6d6bdb67';
step=0.0000249;
start=376.0000181;
hrs=3.48196573658334;
targRate=1000;
%minRate=2;
%maxRate=5;

f=[b '.txt'];
m=[b '.mat'];

% fid=fopen(f);
% for i=1:10
%     fprintf('%s\n',fgetl(fid));
% end
% fclose(fid);

if ~exist(m,'file')
    tic;
    hrs=reduceTxt(f,step,start);
    toc
else
    hrs=hrs;
end

y=whos('-file',m);

% if false && IsWin
%     [m1 m2]=memory;
%     m1=m1.MaxPossibleArrayBytes;
% else
%     m1=6*10^8; %makes 3.5 hrs @ 40kHz doubles about 300 MB and 3kHz
% end
% newRate=m1/8/60/60/hrs/2;
% if newRate<minRate*targRate
%     error('largest contig not big enough')
% elseif newRate>maxRate*targRate
%     newRate=maxRate*targRate;
% end
newRate=targRate;
group=floor((1/step)/newRate);

newOut=nan(1,ceil(hrs*60*60*newRate));
newT=newOut;
loc=1;
tmp=[];

tic
for i=1:length(y)
    var=sprintf('out%d',i-1);
    z=load(m,var);
    if start~=z.(var)(1,1)
        error('bad start')
    end
    start=z.(var)(end,1)+step;
    if ~all(abs(diff(z.(var)(:,1))-step)<.00000000001)
        error('bad step')
    end
    
    zStart=group-size(tmp,1)+1;
    newChunks=floor((size(z.(var),1)-zStart+1)/group);
    zEnd=zStart-1+group*newChunks;
    newLoc=loc+newChunks;
    
    if ~isempty(tmp)
        oTmp=tmp(:,2);
        tTmp=tmp(:,1);
    else
        tTmp=[];
        oTmp=[];
    end
    newOut(loc:newLoc)=mean([ [oTmp;z.(var)(1:zStart-1,2)] reshape(z.(var)(zStart:zEnd,2),group,newChunks)]);
    newT  (loc:newLoc)=mean([ [tTmp;z.(var)(1:zStart-1,1)] reshape(z.(var)(zStart:zEnd,1),group,newChunks)]);
    tmp=[];
    tmp(1:size(z.(var),1)-zEnd,:)=z.(var)(zEnd+1:end,:);
    
    loc=newLoc+1;
    fprintf('%g%% done\n',100*i/length(y))
end

clear('z');

fo=find(isnan(newOut),1,'first');
ft=find(isnan(newT),1,'first');
if isempty(fo) && isempty(ft)
    %pass
else
    if fo==ft && all(isnan(newOut(fo:end))) && all(isnan(newT(ft:end)))
        newT=newT(1:ft-1);
        newOut=newOut(1:fo-1);
    else
        error('bad nans')
    end
end
toc

tic
save([b '.contig.mat'],'newOut','newT');
toc

clear('newOut');

u=1./unique(diff(newT));
if any((u-mean(u))>.00001)
    error('edge error')
end

end