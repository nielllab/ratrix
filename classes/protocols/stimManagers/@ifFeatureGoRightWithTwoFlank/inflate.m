function s=inflate(s)
%method to inflate stim patches

%determine patch size
maxHeight=getMaxHeight(s);
patchX=ceil(maxHeight*s.stdGaussMask*s.stdsPerPatch);  %stdGaussMask control patch size which control the radius
patchY=patchX;

%DETERMINE RADIUS OF GABOR
normalizeMethod='normalizeVertical';
if s.thresh==0.001 && strcmp(normalizeMethod,'normalizeVertical')
    radius=1/s.stdsPerPatch;
else
    radius=1/s.stdsPerPatch;
    s.thresh=s.thresh
    thresh=0.001;
    params =[radius 16 0 pi 1 thresh 1/2 1/2 ];
    grating=computeGabors(params,0.5,200,200,'square','normalizeVertical',1);
    imagesc(abs(grating-0.5)>0.001)
    imagesc(grating)
    %error('Uncommon threshold for gabor edge; radius 1/s.stdsPerPatch normally used with thresh 0.001')

    %find std -- works if square grating
    h=(2*abs(0.5-grating(100,:)));
    plot(h)
    oneSTDboundary=find(abs(h-exp(-1))<0.01);  %(two vals)
    oneStdInPix=diff(oneSTDboundary)/2
end

% %make patches  when inflating used to happen on gratings
% %     params= radius   pix/cyc      phase orientation ontrast thresh % xPosPct yPosPct
% staticParams =[radius  s.pixPerCycs  -99    -99        1    s.thresh  1/2     1/2   ];
% extraParams.normalizeMethod=normalizeMethod;
% extraParams.mean=s.mean;
% 

mask=computeGabors([radius 999 0 0 1 s.thresh 1/2 1/2],0,patchX,patchY,'none',normalizeMethod,0);  %range from 0 to 1

%mask=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientat
%ionAndPhase',0,0,[radius 1000 0 0 1 s.thresh 1/2 1/2],0);
s.mask= mask;  %keep as double

flankerStim=1; % just a place holder
s.flankerStim= uint8(double(intmax('uint8'))*(flankerStim));
%performs the follwoing function:
% if isinteger(stimulus.flankerStim)
%         details.mean=stimulus.mean*intmax(class(stimulus.flankerStim));
% end

s=fillLUT(s,s.typeOfLUT,s.rangeOfMonitorLinearized,0);

