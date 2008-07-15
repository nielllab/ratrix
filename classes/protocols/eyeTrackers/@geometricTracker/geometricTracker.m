function et=geometricTracker(varargin)
% geometricTracker claess constructor.
% tracks the eye using trigometric back calculation, given knownledge of the spatial geometry of the rig
% for more information about method see work by John Stahl 
%         method='simple';         % 'simple' involves less noise, 'yCorrected' better in principle for more accurate for non-tangetial vertical eye positions. but may have noise from yEstimate      
%         Rp=2;                    % in mm distance from pupil center to corneal surface see Stahl 2002 for methods of measuring it 
%         Rcornea=3;              % radius of the cornea in mm
%         alpha=12;                % degrees vertical angular elevation above camera of CR light source
%         beta=0;                 % degrees horizontal angular elevation above camera of CR light source
%         CameraImSizePixs=int16([1280,1024]);     % x pixels, y pixels,  Sol says: [1280,1024]
%         CameraImSizeMm=[42,28];       % measured to 0.5 mm acc on 061122
%         MonitorImSizePixs=int16([1024,768]);    % x pixels, y pixels  [1024,768];
%         MonitorImSizeMm=[400,290];      %measured to 10mm acc on 061122
%         eyeToMonitorTangentMm=300;         % measured 24 cm on 061122;   to be adjusted based on input from HorizTrack
%         eyeAboveMonitorCenterMm=-25;       % roughly measured on Oct 16, 2006;  to be adjusted based on input from JackHeight
%         eyeRightOfMonitorCenterMm=0;     % always zero (less than 1mm) in our rig;  user must center eye before recording
%         degreesCameraIsClockwiseOfMonitorCenter=45;  %roughly if camera is at right of monitor; to be entered by user
%         degreesCameraIsAboveEye=0;      %always zero (less than 3deg) in our rig;  user must center eye before recording
% et = geometricTracker(method, Rp, Rcornea, alpha, beta, CameraImSizePixs, CameraImSizeMm, MonitorImSizePixs, MonitorImSizeMn, eyeToMoinitorTangentMm, eyeAboveMonitorCenterMm, eyeRightOfMonitorCenterMm, degreesCameraIsClockwiseOfMonitorCenter, degreesCameraIsAboveEye)
% et = geometricTracker('simple', 2, 3, 12, 0, int16([1280,1024]), [42,28], int16([1024,768]), [400,290], 300, -25, 0, 45, 0)
% future idea:  et =geometricTracker(getDefaults(geometricTracker))

switch nargin
    case 0
        % if no input arguments, create a default object
        et.method=[];
        et.Rp=[];                   % in mm
        et.Rcornea=[];              % radius of the cornea in mm
        et.alpha=[];                % degrees vertical angular elevation above camera of CR light source
        et.beta=[];                 % degrees horizontal angular elevation above camera of CR light source
        et.CameraImSizePixs=[];     % x pixels, y pixels,  Sol says: [1280,1024]
        et.CameraImSizeMm=[];       %measured to 0.5 mm acc on 061122
        et.CameraPixPerMm=[];       %calulated
        et.MonitorImSizePixs=[];    %x pixels, y pixels  [1024,768];
        et.MonitorImSizeMm=[];      %measured to 10mm acc on 061122
        et.MonitorPixPerMm=[]       %calculated
        et.eyeToMonitorTangentMm=[];      %measured 24 cm on 061122;   to be adjusted based on input from HorizTrack
        et.eyeAboveMonitorCenterMm=[];    %roughly measured on Oct 16, 2006;  to be adjusted based on input from JackHeight
        et.eyeRightOfMonitorCenterMm=[];    %always zero (less than 1mm) in our rig;  user must center eye before recording
        et.degreesCameraIsClockwiseOfMonitorCenter=[];  %roughly if camera is at right of monitor; to be entered by user
        et.degreesCameraIsAboveEye=[];      %always zero (less than 3deg) in our rig;  user must center eye before recording
        et.humanConfirmation=false;         %this is set each session at run time.
        requiresCalibration = true;
        et = class(et,'geometricTracker',eyeLinkTracker(requiresCalibration));
        
%       et.hackScaleFactor=[];    % should be 1 for normal function.  Increases "camera resolution."  Acts like 1/Rp.
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'geometricTracker'))
            et = varargin{1};
        else
            error('Input argument is not a geometricTracker object')
        end
        
    case 14
        if ismember(varargin{1}, {'simple', 'yCorrected'})
            et.method=varargin{1};
        else
            error('method must be simple or ycorrected')
        end

        if varargin{2}>0 && varargin{2}<15
            et.Rp=varargin{2};
        else
            error('Rp must be a sensible measure (0-15) in mm of distance from pupil center to corneal surface');
        end

        if varargin{3}>0 && varargin{3}<30
            et.Rcornea=varargin{3};
        else
            error('Rcornea must be a sensible measure (0-30) in mm of distance of the radius of the cornea');
        end

        if varargin{4}>-90 && varargin{4}<90
            et.alpha=varargin{4};
        else
            error('alpha must be a sensible measure (-90 - 90) in degrees of vertical angle between camera axis and cr light source');
        end

        if varargin{5}==0
            et.beta=varargin{5};
        else
            error('beta must be 0 for John Stahl''s method to work');
        end
        
        if all(size(varargin{6})==[1 2]) && isinteger(varargin{6})
            et.CameraImSizePixs=double(varargin{6});
        else
            error('CameraImSizePixs must be x by y pixel and integers');
        end

        if all(size(varargin{7})==[1 2]) && all(varargin{7}>0)
            et.CameraImSizeMm=varargin{7};
        else
            error('CameraImSizeMm must be x by y mm and must be >0');
        end

        et.CameraPixPerMm=double(et.CameraImSizePixs)./et.CameraImSizeMm;
                
        if all(size(varargin{8})==[1 2]) && isinteger(varargin{8})
            et.MonitorImSizePixs=double(varargin{8});
        else
            error('MonitorImSizePixs must be x by y pixel and integers');
        end
                
        if all(size(varargin{9})==[1 2]) && all(varargin{9}>0)
            et.MonitorImSizeMm=varargin{9};
        else
            error('MonitorImSizeMm must be x by y mm and must be >0');
        end
        
        et.MonitorPixPerMm=double(et.MonitorImSizePixs)./et.MonitorImSizeMm;
        
        if all(size(varargin{10})==[1 1]) && all(varargin{10}>0)
            et.eyeToMonitorTangentMm=varargin{10};
        else
            error('eyeToMonitorTangentMm must a single number in mm and must be >0');
        end

        if all(size(varargin{11})==[1 1]) && all(abs(varargin{11})<300)
            et.eyeAboveMonitorCenterMm=varargin{11};
        else
            error('eyeAboveMonitorCenterMm must a single number in mm and the absolute value must be less than 300');
        end

        if all(size(varargin{12})==[1 1]) && all(abs(varargin{11})<300)
            et.eyeRightOfMonitorCenterMm=varargin{12};
        else
            error('eyeRightOfMonitorCenterMm must a single number in mm and must be >0');
        end

        if varargin{13}>0 && varargin{13}<180
            et.degreesCameraIsClockwiseOfMonitorCenter=varargin{13};
        else
            error('degreesCameraIsClockwiseOfMonitorCenter must be a sensible measure (0 - 180) in clockwise degrees of angle between camera axis and monitor');
        end

        if varargin{14}==0 %varargin{14}>-3 && varargin{14}<3
            et.degreesCameraIsAboveEye=varargin{14};
        else
            error('degreesCameraIsAboveEye should be zero');
            %error('degreesCameraIsAboveEye should be zero, but code tolerates (-3 - 3) in vertical degrees of angle between camera axis and the eye');
        end
        
        et.humanConfirmation=false;
        
        requiresCalibration = true;
        et = class(et,'geometricTracker',eyeLinkTracker(requiresCalibration));
    otherwise
        error('Wrong number of input arguments')
end

et=setSuper(et,et.eyeLinkTracker);