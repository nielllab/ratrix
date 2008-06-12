function out=getFeaturePatchStim(patchX,patchY,type,variableParams,staticParams,extraParams)
%creates matrix of images size patchY x patchX x length(variableParams)
%used for inflating different object types
%this could be a method, but it is generally useful 

    switch type
        case 'squareGrating-variableOrientation'
            featurePatchStim=zeros(patchX,patchY,length(variableParams));
            params=staticParams;
            %params= radius   pix/cyc  phase orientation ontrast thresh xPosPct yPosPct
             for i=1:length(variableParams)
                params(4)=variableParams(i);  %4th parameter is orientation
                featurePatchStim(:,:,i)=computeGabors(params,extraParams.mean,patchX,patchY,'square',extraParams.normalizeMethod,1);
             end
        case 'squareGrating-variableOrientationAndPhase'
            error('not defined yet')
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
 