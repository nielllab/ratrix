function gaze=getGazeEstimate(et,cr,pup)
%using Fick coordinates; see Stahl, 2002 and 2004
%toDo:  find whats causing the imaginary component
el = getConstants(et);

cr(cr==el.MISSING_DATA)=nan;
pup(pup==el.MISSING_DATA)=nan;

%Short code
switch et.method
    case 'cr-p'
        %these are not in terms of screen coordinates, and do not acoud for eye curvature, animal position, etc
        %but they do monotonically relate to gaze angle.
        gaze=cr-pup;
    case 'simple'
        %same function in few lines, less interpretable b/c no intermediate variables
        gaze=[(et.MonitorImSizePixs(1)/2)+et.MonitorPixPerMm(1)*(et.eyeToMonitorTangentMm*tan(-asin((cr(:,1)-pup(:,1))/(et.CameraPixPerMm(1)*et.Rp))-(et.degreesCameraIsClockwiseOfMonitorCenter*pi/180))+et.eyeRightOfMonitorCenterMm),...
            (et.MonitorImSizePixs(2)/2)+et.MonitorPixPerMm(2)*(et.eyeToMonitorTangentMm*tan(atan((cr(:,2)-pup(:,2))/(et.CameraPixPerMm(2)*et.Rp))-(et.degreesCameraIsAboveEye*pi/180))+et.eyeAboveMonitorCenterMm)];
    case 'yCorrected'
        Rp0b=sqrt(((cr(:,2)-pup(:,2))/et.CameraPixPerMm(2)+et.Rcornea*sin((et.alpha*pi/180)/2)).^2+et.Rp^2);
        Yraw=((cr(:,2)-pup(:,2))/et.CameraPixPerMm(2));
        RpCorrectedb=sqrt(sqrt((Yraw+et.Rcornea*sin((et.alpha*pi/180)/2)).^2+et.Rp^2).^2-Yraw.^2);
        gaze=[(et.MonitorImSizePixs(1)/2)+et.MonitorPixPerMm(1)*(et.eyeToMonitorTangentMm*tan(-asin((cr(:,1)-pup(:,1))./(et.CameraPixPerMm(1)*RpCorrectedb))-(et.degreesCameraIsClockwiseOfMonitorCenter*pi/180))+et.eyeRightOfMonitorCenterMm),...
            (et.MonitorImSizePixs(2)/2)+et.MonitorPixPerMm(2)*(et.eyeToMonitorTangentMm*tan(asin((cr(:,2)-pup(:,2))./(et.CameraPixPerMm(2)*Rp0b))-(et.degreesCameraIsAboveEye*pi/180))+et.eyeAboveMonitorCenterMm)];
end

if 0
    if any(imag(gaze)>0)
        sca
        keyboard
        error('no imaginary values allowed!')
    end
end


% %don't need this, but this line explains the relation of long to short code
% angle2test=[asin((cr(:,1)-pup(:,1))/(et.CameraPixPerMm(1)*RpCorrectedb)), asin((cr(:,2)-pup(:,2))/(et.CameraPixPerMm(2)*Rp0b))];
%
%
% x=gaze2(1);
% y=gaze2(2);


errorCheck=false;
if errorCheck
    %LONG CODE
    %cr=[crx,cry];
    %pup=[pupx,pupy];
    
    ns=size(cr,1);
    dif=cr-pup;                                %distance between corneal reflection and pupil center
    dif=dif./repmat(et.CameraPixPerMm,ns,1);                   %convert pixels to mm

    %MODE ONE, simple
    horiz1=asin(dif(:,1)/et.Rp);                   %eqn 1, only use when vertical position is on camera axis =0
    %without correction will have less noise b/c no Rp0 estimated
    vert1=atan(dif(:,2)/et.Rp);                    %eqn 6, use Rp and tangent, why? see diagram
    %in this mode you should have RefIR at horizontal position, not above

    %MODE TWO, uses correction
    Yraw=dif(:,2);
    y=Yraw+et.Rcornea*sin((et.alpha*pi/180)/2);     %corrected y, accounts for position of LED, eqn 3
    Rp0=sqrt(y.^2+et.Rp^2);
    RpCorrected=sqrt(Rp0.^2-Yraw.^2);         %corrected Rp at this vertical position, eqn 5
    horiz2=asin(dif(:,1)./RpCorrected);          %eqn 1, but with adjusted Rp
    vert2=asin(dif(:,2)./Rp0);                   %eqn 6, use sin and great circle radius

%     angle1=[horiz1,vert1];                         % in radians
%     angle2=[horiz2,vert2];                         % in radians
    angle1=[-horiz1,vert1];                         % in radians -- if this is correct put an minus in front of asin in short code too, then check long and short match
    angle2=[-horiz2,vert2];                         % in radians
    angle1deg=angle1*180/pi;                         % in degrees, good for viewing, not used in code
    angle2deg=angle2*180/pi;                         % in degrees, good for viewing, not used in code

    physicalOffset=repmat([et.eyeRightOfMonitorCenterMm,et.eyeAboveMonitorCenterMm],ns,1);
    angularOffset=repmat([et.degreesCameraIsClockwiseOfMonitorCenter*pi/180,et.degreesCameraIsAboveEye*pi/180],ns,1);
    centerScreenPix=repmat(et.MonitorImSizePixs/2,ns,1);

    gazeMm1=et.eyeToMonitorTangentMm*tan(angle1-angularOffset);   %the mm of offset from gaze
    gazeMm2=et.eyeToMonitorTangentMm*tan(angle2-angularOffset);   %the mm of offset from gaze
    gaze1= centerScreenPix+(physicalOffset+gazeMm1).*repmat(et.MonitorPixPerMm,ns,1);  %estimate of gaze in Monitor Pix
    gaze2= centerScreenPix+(physicalOffset+gazeMm2).*repmat(et.MonitorPixPerMm,ns,1);  %estimate of gaze in Monitor Pix

    

    switch et.method
        case 'simple'
            if ~all((gaze(:)-gaze1(:))==0)
                gaze
                gaze1
                theDif=gaze-gaze1
                error('these should be the same!')
            end
        case 'yCorrected'
            if ~all((gaze(:)-gaze2(:))==0)
                
                gaze
                gaze2
                theDif=gaze-gaze2
                %angle2test==angle2
                error('these should be the same!')
            end
    end

    % %reasoning about signs...
    %     %if gaze coordinates way off screen check sign of angle1-angularOffset
end