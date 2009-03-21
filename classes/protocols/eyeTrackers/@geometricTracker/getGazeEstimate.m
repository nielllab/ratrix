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
        gaze=[(et.MonitorImSizePixs(1)/2)+et.MonitorPixPerMm(1)*(et.eyeToMonitorTangentMm*tan(asin((cr(1)-pup(1))/(et.CameraPixPerMm(1)*et.Rp))-(et.degreesCameraIsClockwiseOfMonitorCenter*pi/180))+et.eyeRightOfMonitorCenterMm),...
            (et.MonitorImSizePixs(2)/2)+et.MonitorPixPerMm(2)*(et.eyeToMonitorTangentMm*tan(atan((cr(2)-pup(2))/(et.CameraPixPerMm(2)*et.Rp))-(et.degreesCameraIsAboveEye*pi/180))+et.eyeAboveMonitorCenterMm)];
    case 'yCorrected'
        Rp0b=sqrt(((cr(2)-pup(2))/CameraPixPerMm(2)+Rcornea*sin((alpha*pi/180)/2))^2+Rp^2);
        RpCorrectedb=sqrt(sqrt(((cr(2)-pup(2))/CameraPixPerMm(2)+Rcornea*sin((alpha*pi/180)/2))^2+Rp^2)^2 -(((cr(2)-pup(2)))/CameraPixPerMm(2))^2 );
        gaze=[(MonitorImSizePixs(1)/2)+MonitorPixPerMm(1)*(eyeToMonitorTangentMm*tan(asin((cr(1)-pup(1))/(CameraPixPerMm(1)*RpCorrectedb))-(degreesCameraIsClockwiseOfMonitorCenter*pi/180))+eyeRightOfMonitorCenterMm),...
            (MonitorImSizePixs(2)/2)+MonitorPixPerMm(2)*(eyeToMonitorTangentMm*tan(asin((cr(2)-pup(2))/(CameraPixPerMm(2)*Rp0b))-(degreesCameraIsAboveEye*pi/180))+eyeAboveMonitorCenterMm)];
end

if 0
    if any(imag(gaze)>0)
        sca
        keyboard
        error('no imaginary values allowed!')
    end
end


% %don't need this, but this line explains the relation of long to short code
% %angle2=[asin((cr(1)-pup(1))/(CameraPixPerMm(1)*RpCorrected)), asin((cr(2)-pup(2))/(CameraPixPerMm(2)*Rp0))];
%
%
% x=gaze2(1);
% y=gaze2(2);

if 0
    %LONG CODE
    %cr=[crx,cry];
    %pup=[pupx,pupy];
    dif=cr-pup;                                %distance between corneal reflection and pupil center
    dif=dif./CameraPixPerMm;                   %convert pixels to mm

    %MODE ONE, simple
    horiz1=asin(dif(1)/Rp);                   %eqn 1, only use when vertical position is on camera axis =0
    %without correction will have less noise b/c no Rp0 estimated
    vert1=atan(dif(2)/Rp);                    %eqn 6, use Rp and tangent, why? see diagram
    %in this mode you should have RefIR at horizontal position, not above

    %MODE TWO, uses correction
    Yraw=dif(2);
    y=Yraw+Rcornea*sin((alpha*pi/180)/2);     %corrected y, accounts for position of LED, eqn 3
    Rp0=sqrt(y.^2+Rp.^2);
    RpCorrected=sqrt(Rp0.^2-Yraw.^2);         %corrected Rp at this vertical position, eqn 5
    horiz2=asin(dif(1)/RpCorrected);          %eqn 1, but with adjusted Rp
    vert2=asin(dif(2)/Rp0);                   %eqn 6, use sin and great circle radius

    angle1=[-horiz1,vert1];                         % in radians
    angle2=[-horiz2,vert2];                         % in radians
    angle1deg=angle1*180/pi;                         % in degrees, good for viewing, not used in code
    angle2deg=angle2*180/pi;                         % in degrees, good for viewing, not used in code

    physicalOffset=[eyeRightOfMonitorCenterMm,eyeAboveMonitorCenterMm];
    angularOffset=[degreesCameraIsClockwiseOfMonitorCenter*pi/180,degreesCameraIsAboveEye*pi/180];
    centerScreenPix=MonitorImSizePixs/2;

    gazeMm1=eyeToMonitorTangentMm*tan(angle1-angularOffset);   %the mm of offset from gaze
    gazeMm2=eyeToMonitorTangentMm*tan(angle2-angularOffset);   %the mm of offset from gaze
    gaze1= centerScreenPix+(physicalOffset+gazeMm1).*MonitorPixPerMm;  %estimate of gaze in Monitor Pix
    gaze2= centerScreenPix+(physicalOffset+gazeMm2).*MonitorPixPerMm;  %estimate of gaze in Monitor Pix

    switch method
        case 1
            x=gaze1(1);
            y=gaze1(2);
        case 2
            x=gaze2(1);
            y=gaze2(2);
    end

    %
    % %reasoning about signs...
    %     %if gaze coordinates way off screen check sign of angle1-angularOffset
end