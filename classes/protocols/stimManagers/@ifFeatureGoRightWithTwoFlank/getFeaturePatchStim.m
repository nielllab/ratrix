function out=getFeaturePatchStim(t,patchX,patchY,type,parameters)
%creates matrix of images size patchY x patchX x (whatever is necessary)
%used for inflating different object types

switch type
    case 'variableOrientationAndPhase'  % specific instance of gratings
        orients=parameters{1};
        phases=parameters{2};
        staticParams=parameters{3};
        normalizeMethod=parameters{4};
        contrastScale=parameters{5};

        % check
        if size(staticParams, 2)~=8
            error ('wrong numbers of params will be passed to computeGabors')
        end
        if ~isempty(contrastScale)
            error('was never implimented')
            %index=find(orients(i)==t.calib.orientations);
        else
            contrast=1;
        end

        %setup
        out=zeros(patchX,patchY,length(orients), length(phases));
        gaborParams=staticParams;
        %params= radius   pix/cyc  phase orientation contrast thresh xPosPct yPosPct
        for i=1:length(orients)
            gaborParams(4)=orients(i); %4th parameter is orientation
            gaborParams(5)=contrast;   %5th parameter is contrast
            for j = 1: length(phases)
                gaborParams(3)=phases(j);            %3rd parameter is the phase
                out(:,:,i,j)=computeGabors(gaborParams,t.mean,patchY,patchX,t.gratingType,normalizeMethod,0);
            end
        end
    otherwise
        error(sprintf('%s is not a defined type of feature',type))
end