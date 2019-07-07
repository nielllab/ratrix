global sbconfig;

% User dependent settings

sbconfig.scanbox_com    = 'COM6';           % scanbox serial communication port
sbconfig.scope_model    = 'STANDARD';       % NLW Scope model (STANDARD or MESOSCOPE)
sbconfig.laser_com      = '';               % laser serial communication port
sbconfig.laser_type     = '';               % laser type (CHAMELEON, DISCOVERY or use '' if controlling with manufacturer's GUI) 
sbconfig.tri_knob       = 'COM3';           % knobby's serial port (or IP address like '164.67.38.247' for knobby tablet or '127.0.0.1' for virtual knobby)
sbconfig.tri_knob_ver   = 2;                % knobby version (1 [small screen] or 2 [large screen]) 
sbconfig.tri_com        = 'COM5';           % motor controller communication serial port
sbconfig.tri_baud       = 57600;            % baud rate of motor controller
sbconfig.quad_com       = '';               % monitor quadrature encoder of rotating platform [ARduino based]
sbconfig.quad_cal       = 20*pi/1440;       % cm/count (r=10cm platform).  
sbconfig.speedbelt_com  = '';               % phenosys speedbelt
sbconfig.deadband       = [120 150];        % size of laser deadband at left/right margins
sbconfig.datadir        = 'd:\data';        % default root data directory
sbconfig.autoinc        = true;             % auto-increment experiment # field
sbconfig.freewheel      = true;             % enable freewheeling of motors (power will be turned off upon reaching position)
sbconfig.balltracker    = true;             % enable ball tracker (0 - disabled, 1- enabled)
sbconfig.ballcamera     = 'M640';           % model of ball camera
sbconfig.eyetracker     = true;             % enable eye tracker  (0 - disabled, 1- enabled)
sbconfig.eyecamera      = 'M1280';          % model of eye camera
sbconfig.portcamera     = true;             % enable path camera (0 - disabled, 1- enabled)
sbconfig.pathcamera     = 'Manta';
sbconfig.pathcamera_format = 'Mono8';      % format for path camera (use > 8 bits only if doing intrinsic/epi-imaging)
sbconfig.pathlr         = true;            % switch camera image lr? (Use camera hardware option if availabe!)
sbconfig.imask          = bin2dec('00001101');    % interrupt mask
sbconfig.pockels_range  = uint8([1 2]);           % set pockels range [vdac pga]
sbconfig.pockels_lut    = uint8([]);              % your look up table (must have *exactly* 256 entries)
sbconfig.mmap           = false;                    % enable/disable memory mapped file stream and plugin server
sbconfig.plugin = {...
    'rolling', ...
    'pixel_histogram',...
    'twopmts', ...
    'viewref'};                                     % plugin options
sbconfig.optocal = [];                              % optotune calibration (use [] for default) - will be overwritten if calibration file present
sbconfig.optoval = 0:170:1700;                      % sequence of current values for calibration
sbconfig.optorange = -320;                          % range to cover durign calibration (must be > than estimated range of optotune)
sbconfig.optostep  = -10;                           % step size in micrometers for optotune calibration
sbconfig.optoframes = 10;                           % number of frames at each step for optotune z-stack calibration
sbconfig.phys_cores = uint16(feature('numCores'));  % total number of physical cores - should be uint16
sbconfig.cores_uni = sbconfig.phys_cores;           % number of cores in unidirectional scanning 
sbconfig.cores_bi  = sbconfig.phys_cores;           % number of cores in bidirectional scanning 
sbconfig.etl = 860;                                 % default ETL value
sbconfig.resfreq = 8000;                            % nominal resonant freq for your mirror 
sbconfig.lasfreq = 80000000;                        % nomial laser freq
sbconfig.knobbyreset    = true;                     % automatically reset knobby upon start up? (beta)
sbconfig.firmware = '10.4';                         % required firmware version
sbconfig.unidirectional = true;                     % default unidirectional (true)_or bidirectional (false)
sbconfig.cam_ignore = false;                        % allows imaging with cam port enabled (e.g. for alignment or debugging). 
sbconfig.trig_sel = false;                           % make it true TTL1 is used for start/stop trial, otherwise signal should come from header
sbconfig.knobby_table = ...                         % dx dy dz mem frame#
    [0 0 10 0 30; ...
     0 0 10 0 60; 
     0 0 10 0 90; 
     0 0 10 0 120; 
     0 0 10 0 150; 
     0 0 10 0 180];


%sbconfig.pmeter_id = 'USB0::0x1313::0x8078::P0012223::0::INSTR'; % PM100D power meter ID (leave blank if not available)
sbconfig.pmeter_id = [];                                          % PM100D power meter ID (leave blank if not available)
sbconfig.news      = false;             % Display latest news from Scanbox website on startup

% PLEASE do NOT change these settings unless you understand what your are doing!
sbconfig.samples_per_pixel = round(sbconfig.lasfreq / sbconfig.resfreq * 4 / 10000);    % (samples/pixel)
sbconfig.pmt_amp_type   = {'variable','variable','variable','variable'}; % 'variable' or 'fixed' amplifiers?
sbconfig.pmt_names = {'GCaMP6s','tdTomato','Texas Red','Chrome'};   
sbconfig.trig_level     = 160;          % trigger level
sbconfig.trig_slope     = 0;            % trigger slope (0 - positive, 1 - negative)
sbconfig.nbuffer = 16;                  % number of buffers in ring (depends on your memory)
sbconfig.margin = 20;
sbconfig.bishift =[0    0    0    0    0    0   0   0   0    0   0   0   0  ]; % sub pixel shift (integer >=0)
sbconfig.stream_host = '';
sbconfig.stream_port = 7001;            % where to stream data to...
sbconfig.rtmax = 30000;                 % maximum real time data points
sbconfig.gpu_pages = 0;                 % max number of gpu pages (make it zero if no GPU desired)
sbconfig.gpu_interval = 10;             % delta frames between gpu-logged frames
sbconfig.gpu_dev = 1;                   % gpu device #
sbconfig.nroi_auto = 4;                 % number of ROIs to track in auto alignment
sbconfig.nroi_auto_size = [64 68 72 76 82 86 92 96 102 108 114 122 128];  % size of ROIs for diffnt mag settings
sbconfig.nroi_parallel = 0;             % use parallel for alignment
sbconfig.stream_host = 'localhost';     % stream to this host name
sbconfig.stream_port = 30000;           % and port...

sbconfig.obj_length = 98000;            % objective length from center of rotation to focal point [um] 
sbconfig.qmotion        = 0;            % quadrature motion controller 
sbconfig.qmotion_com    = '';           % comm port for quad controller
sbconfig.ephys = false;                 % enable ephys data acquisition
sbconfig.ephysDev = 'Dev1';             % which NI device to use
sbconfig.ephysRate = 1000;              % sampling rate (samples/sec)

sbconfig.xevents = false;               % external events from NI box
sbconfig.xeventsDev = 'Dev2';           % Device
sbconfig.xeventsClock = 'Dev2/PFI9';    % clock input
sbconfig.xeventsRate = 16;              % expected data rate 

sbconfig.hsync_sign    = 1;             % 0-normal, 1-flip horizontal axis
sbconfig.gain_override = 1;             % override default gain settings?

% sbconfig.gain_galvo = logspace(log10(1),log10(8),13);  % more options now!
% sbconfig.gain_resonant_mult = 1.42;                     % resonant multiplier (>1.0) was 1.42 [1.16 for Nikon x25]
% sbconfig.gain_resonant = sbconfig.gain_resonant_mult * sbconfig.gain_galvo;
sbconfig.dv_galvo      = 64;            % dv per line (64 is the maximum) -- don't touch!

%from scanbox 112016, niell lab specific
sbconfig.gain_resonant = [1.67 3.34 6.67]*1.2 *1.2; % gains for x1, x2 and x4 (x)
sbconfig.gain_galvo    = [1.91 3.82 7.67]*1.2 *1.3; % same for galvo (y)

sbconfig.wdelay = 50;                   % warmup delay for resonant scanner (in tens of ms)
% sbconfig.cam_pulse_width = 16;          % default pulse width in steps of 125us -- thus 16 = 2ms

% SLM config variables

sbconfig.slm    = false;                      % SLM option 
sbconfig.slmdev = 'Dev1';                     % SLM daq device used
sbconfig.slmTrigger = 'Dev1/PFI9';
sbconfig.slmcal = 'slmcal';                   % SLM calibration file

sbconfig.slmwidth  = 1920;
sbconfig.slmheight = 1080;
sbconfig.slm_centerx = sbconfig.slmwidth/2;
sbconfig.slm_centery = sbconfig.slmheight/2;
sbconfig.slm_prismx = -sbconfig.slmwidth/2;
sbconfig.slm_prismy = -sbconfig.slmwidth/2;
sbconfig.slm_size = 90;                          % default size

sbconfig.slm_nx = 5;                            % # of points in calibration grid in x and y - must be odd!
sbconfig.slm_ny = 3;

sbconfig.slm_validation_power = NaN;             % slm power during validation (NaN means automatic calibration)
sbconfig.slm_threshold = 50000;                  % target intensity for automatic power calib (use 0.75*maxvalue for camera)
sbconfig.slm_powerlow = -0.05;                   % brackets for binary search
sbconfig.slm_powerhigh = 0.1;                    % make sure threshold falls in-between

switch sbconfig.pathcamera
    case 'pco'
        sbconfig.slm_calexposure = 0.05;
        sbconfig.slm_threshold = 50000;       % threshold above which is considered saturated (255 is max value)
    case 'GT2750'
        sbconfig.slm_calexposure = 0.1;
        sbconfig.slm_threshold = 3000;       % threshold above which is considered saturated (255 is max value)
    otherwise
        sbconfig.slm_calexposure = 1;
        sbconfig.slm_threshold = 250;       % threshold above which is considered saturated (255 is max value)
end

% Laser AGC

sbconfig.agc_period = 1;            % adjust power every T seconds
sbconfig.agc_factor = [0.93 1.08];  % factor to change laser power down or up if outside prctile bounds
sbconfig.agc_prctile = [1e-4 1e-3]; % bounds on percent pixels saturated wanted
sbconfig.agc_threshold = 250;       % threshold above which is considered saturated (255 is max value)

% objective list
sbconfig.objectives = {'Nikon_16x_dlr','Nikon_25x_dlr'};

% Optogenetics panel

sbconfig.optogenetics = false;
sbconfig.led_id = 'USB0::0x1313::0x80C8::M00476084::INSTR'; % Thorlabs DC2020 controller
sbconfig.led_stim_com = 'COM8';                             % Arduino pulse generator
sbconfig.led_id = '';                                       % Thorlabs DC2020 controller
sbconfig.led_stim_com = '';    


% fix gpu problem
warning off parallel:gpu:device:DeviceLibsNeedsRecompiling
try
    gpuArray.eye(2)^2;
catch ME
end
try
    nnet.internal.cnngpu.reluForward(1);
catch ME
end
