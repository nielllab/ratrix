function out=getFeaturePatchStim(t,patchX,patchY,type,variableParam1, variableParam2, staticParams,extraParams)
%creates matrix of images size patchY x patchX x length(variableParams1) x length(variableParams2)
%used for inflating different object types
%this could be a method, but it is generally useful 

if size(staticParams, 2)~=8
                variableParam1= variableParam1
                variableParam2= variableParam2
                staticParams = staticParams
    error ('wrong numbers of params will be passed to computeGabors')
end

    switch type
        case 'variableOrientation'
            featurePatchStim=zeros(patchX,patchY,length(variableParam1));
            params=staticParams;
            %params= radius   pix/cyc  phase orientation contrast thresh xPosPct yPosPct
             for i=1:length(variableParam1)
                params(4)=variableParam1(i);            %4th parameter is orientation
                %Get the right contrast...
                index=find(variableParam1(i)==t.calib.orientations);
                params(5)=t.calib.contrastScale(index); %5th parameter is contrast
                featurePatchStim(:,:,i)=computeGabors(params,t.mean,patchX,patchY,t.gratingType,t.gaborNormalizeMethod,0);
             end     
        case 'variableOrientationAndPhase'
            featurePatchStim=zeros(patchX,patchY,length(variableParam1), length(variableParam2));
            params=staticParams;
            %params= radius   pix/cyc  phase orientation contrast thresh xPosPct yPosPct
             for i=1:length(variableParam1)

                params(4)=variableParam1(i);            %4th parameter is orientation
                index=find(variableParam1(i)==t.calib.orientations);
                params(5)=t.calib.contrastScale(index); %5th parameter is contrast
                for j = 1: length(variableParam2)
                params(3)=variableParam2(j);            %3rd parameter is the phase
                featurePatchStim(:,:,i,j)=computeGabors(params,t.mean,patchX,patchY,t.gratingType,t.gaborNormalizeMethod,0);
                end
             end 
        otherwise
            error(sprintf('%s is not a defined type of feature',type))
    end
    out=featurePatchStim;
    
%sample call from the inflate of ifFeatureGoRightWithTwoFlank
%     staticParams=[radius  s.pixPerCycs  s.phase    0        1    s.thresh  1/2     1/2   ];
%     extraParams.normalizeMethod=normalizeMethod;
%     extraParams.mean=s.mean;
%     s.goRightStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientation',s.goRightOrientations,staticParams,extraParams)
%     s.goLeftStim= getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientation',s.goLeftOrientations, staticParams,extraParams)
%     s.flankerStim=getFeaturePatchStim(patchX,patchY,'squareGrating-variableOrientation',s.flankerOrientations,staticParams,extraParams)
 