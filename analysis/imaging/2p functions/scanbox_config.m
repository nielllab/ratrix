global sbconfig; 

% User dependent settings

sbconfig.speedbelt_com = []; %keep getting a bug looking for this field
sbconfig.scanbox_com    = 'COM4';           % scanbox serial communication port
sbconfig.laser_com      = '';           % laser serial communication port
sbconfig.laser_type     = '';               % laser type (CHAMELEON, DISCOVERY or use '' if controlling with manufacturer's GUI) 
sbconfig.tri_knob       = 'COM3';           % knobby's serial port (or IP address like '164.67.38.247' for knobby tablet (knobby tablet is '10.111.65.94') or '127.0.0.1' for virtual knobby) %niell COM7 for knobby 2.0
sbconfig.tri_knob_ver   = 2;                % knobby version (1 [small screen] or 2 [large screen]) 
sbconfig.tri_com        = 'COM5';           % motor controller communication serial port
sbconfig.tri_baud       = 57600;            % baud rate of motor controller
sbconfig.quad_com       = '';               % monitor quadrature encoder of rotating platform [ARduino based]
sbconfig.quad_cal       = 20*pi/1440;       % cm/count (r=10cm platform).  
sbconfig.deadband       = [120 150];        % size of laser deadband at left/right margins %default is [120 150]
sbconfig.datadir        = 'd:\data';       % default root data directory
sbconfig.autoinc        = true;             % auto-increment experiment # field
sbconfig.freewheel      = true;            % enable freewheeling of motors (power will be turned off upon reaching position)
sbconfig.balltracker    = false;             % enable ball tracker (0 - disabled, 1- enabled)
sbconfig.ballcamera     = 'M640';           % model of ball camera
sbconfig.eyetracker     = true;             % enable eye tracker  (0 - disabled, 1- enabled)
sbconfig.eyecamera      = 'M1280';          % model of eye camera
sbconfig.portcamera     = true;             % enable path camera (0 - disabled, 1- enabled)
sbconfig.pathcamera     = 'Manta';
sbconfig.pathcamera_format = 'Mono8';       % format for path camera (use > 8 bits only if doing intrinsic/epi-imaging)
sbconfig.pathlr         = true;            % switch camera image lr? (Use camera hardware option if availabe!)
sbconfig.imask          = 3;                % interrupt masks (3 TTL event lines are available)
%sbconfig.pockels_lut    = uint8(interp1([0,3,11,25,42,62,81,100,120,135,148,155],[0:10:110],[0:155/255:155])); %niell
% sbconfig.pockels_lut    = uint8([ ...
%  0     5    10    16    20    21    23    24    25    26    27    29    30    31    32    33    34    36    37    38    39    40    41    42    42    43    43    44    45    45    46    47    47 ...
% 48    49    49    50    51    51    52    53    53    54    54    55    56    56    57    58    58    59    60    60    61    62    62    63    64    64    65    66    66    67    68    68    69 ...
% 70    70    71    72    72    73    74    74    75    76    76    77    78    78    79    80    80    81    81    82    82    83    83    84    85    85    86    86    87    87    88    88    89 ... 
% 89    90    90    91    91    92    92    93    93    94    94    95    96    96    97    97    98    98    99    99   100   100   101   101   102   102   103   103   104   104   105   105   106 ...
% 107   107   108   108   109   109   110   110   111   111   112   112   113   113   114   114   115   115   116   116   117   118   118   119   119   120   120   121   121   122   122   123   124 ...
% 124   125   125   126   126   127   128   128   129   129   130   130   131   132   132   133   133   134   134   135   136   136   137   137   138   138   139   140   140   141   142   142   143 ...
% 144   144   145   146   146   147   148   148   149   150   150   151   152   152   153   154   154   155   156   156   157   158   158   159   160   160   161   162   163   164   165   166   167 ...
% 168   168   169   170   171   172   173   174   175   176   177   177   178   179   180   182   184   186   248   190   192   194   196   198   200 ...
% ]);                                                 % your look up table (must have *exactly* 256 entries)
                                                    % Note that if pockelscal.m exists this will get overwritten 
sbconfig.mmap           = false;                    % enable/disable memory mapped file stream and plugin server %used to be set to true 010518
sbconfig.plugin = {'rolling','montage'};            % plugin options
sbconfig.optocal = [];                              % optotune calibration (use [] for default) - will be overwritten if calibration file present
sbconfig.optoval = 0:170:1700;                      % sequence of current values for calibration
sbconfig.optorange = -320;                          % range to cover durign calibration (must be > than estimated range of optotune)
sbconfig.optostep  = -10;                            % step size in micrometers for optotune calibration
sbconfig.optoframes = 10;                           % number of frames at each step for optotune z-stack calibration
sbconfig.phys_cores = uint16(feature('numCores'));  % total number of physical cores
sbconfig.cores_uni = sbconfig.phys_cores;           % number of cores in unidirectional scanning 
sbconfig.cores_bi  = sbconfig.phys_cores;           % number of cores in bidirectional scanning 
sbconfig.etl = 860;                                 % default ETL value
sbconfig.resfreq = 7920;                            % resonant freq for your mirror 
sbconfig.lasfreq = 80400000;                        % laser freq at 920nm
sbconfig.knobbyreset    = true;                     % automatically reset knobby upon start up? (beta)
sbconfig.firmware = '4.1';                          % required firmware version 3.4
sbconfig.unidirectional = true;                     % default unidirectional (true)_or bidirectional (false)
sbconfig.cam_ignore = false;                        % allows imaging with cam port enabled (e.g. for alignment or debugging). 
sbconfig.trig_sel = false;                          % make it true TTL1 is used for start/stop trial, otherwise signal should come from header
sbconfig.knobby_table = ...                         % dx dy dz mem frame#
    [0 0 10 0 30; ...
     0 0 10 0 60; 
     0 0 10 0 90; 
     0 0 10 0 120; 
     0 0 10 0 150; 
     0 0 10 0 180];


%sbconfig.pmeter_id = 'USB0::0x1313::0x8078::P0012223::0::INSTR'; % PM100D power meter ID (leave blank if not available)
sbconfig.pmeter_id = [];                                          % PM100D power meter ID (leave blank if not available)


% PLEASE do NOT change these settings unless you understand what your are doing!
sbconfig.pmt_amp_type   = 'variable';   % 'variable' or 'fixed' amplifiers?
sbconfig.trig_level     = 160;          % trigger level
sbconfig.trig_slope     = 0;            % trigger slope (0 - positive, 1 - negative)
sbconfig.nbuffer = 16;                  % number of buffers in ring (depends on your memory)
sbconfig.margin = 20;
sbconfig.bishift =[0    0    0    0    0    0   0   0   0    0   0   0   0  ]; % sub pixel shift (integer >=0)
sbconfig.stream_host = '';
sbconfig.stream_port = 7001;            % where to stream data to...
sbconfig.rtmax = 30000;                 % maximum real time data points
sbconfig.gpu_pages = 0;               % max number of gpu pages (make it zero if no GPU desired) Dario changed this from 250 to zero to stop the error we were getting when he set this back up, see emails 5/6/19
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
sbconfig.ephysRate = 1000;              % sampling rate (samples/sec)

sbconfig.hsync_sign    = 1;             % 0-normal, 1-flip horizontal axis %%%prlp set to 1 01/24/18
sbconfig.gain_override = 1;             % override default gain settings?

% sbconfig.gain_galvo = logspace(log10(1),log10(8),13);  % more options now!
% sbconfig.gain_resonant_mult = 0.98;                     % resonant multiplier (>1.0) was 1.4286
% sbconfig.gain_resonant = sbconfig.gain_resonant_mult * sbconfig.gain_galvo;
sbconfig.dv_galvo      = 64;            % dv per line (64 is the maximum) -- don't touch!


%from scanbox 112016, niell lab specific
sbconfig.gain_resonant = [1.67 3.34 6.67]*1.2 *1.2; % gains for x1, x2 and x4 (x)
sbconfig.gain_galvo    = [1.91 3.82 7.67]*1.2 *1.3; % same for galvo (y)

sbconfig.wdelay = 50;                   % warmup delay for resonant scanner (in tens of ms)

% sbconfig.pmt_amp_type   = 'variable';   % 'variable' or 'fixed' amplifiers?
% sbconfig.trig_level     = 160;          % trigger level
% sbconfig.trig_slope     = 0;            % trigger slope (0 - positive, 1 - negative)
% sbconfig.nbuffer = 16;                  % number of buffers in ring (depends on your memory)
% sbconfig.margin = 20;
% sbconfig.bishift =[0    0    0    0    0    0   0   0   0    0   0   0   0  ]; % sub pixel shift (integer >=0)
% sbconfig.stream_host = '';
% sbconfig.stream_port = 7001;            % where to stream data to...
% sbconfig.rtmax = 30000;                 % maximum real time data points
% sbconfig.gpu_pages = 250;               % max number of gpu pages (make it zero if no GPU desired)
% sbconfig.gpu_interval = 10;             % delta frames between gpu-logged frames
% sbconfig.gpu_dev = 1;                   % gpu device #
% sbconfig.nroi_auto = 4;                 % number of ROIs to track in auto alignment
% sbconfig.nroi_auto_size = [64 68 72 76 82 86 92 96 102 108 114 122 128];  % size of ROIs for diffnt mag settings
% sbconfig.nroi_parallel = 0;             % use parallel for alignment
% sbconfig.stream_host = 'localhost';     % stream to this host name
% sbconfig.stream_port = 30000;           % and port...
% 
% sbconfig.obj_length = 98000;            % objective length from center of rotation to focal point [um] 
% sbconfig.qmotion        = 0;            % quadrature motion controller 
% sbconfig.qmotion_com    = '';           % comm port for quad controller
% sbconfig.ephys = false;                 % enable ephys data acquisition
% sbconfig.ephysDev = 'Dev1';             % which NI device to use
% sbconfig.ephysRate = 1000;              % sampling rate (samples/sec)
% 
sbconfig.xevents = false;               % external events from NI box
sbconfig.xeventsDev = 'Dev2';           % Device
sbconfig.xeventsClock = 'Dev2/PFI9';    % clock input
sbconfig.xeventsRate = 16;              % expected data rate 
% 
% sbconfig.hsync_sign    = 1;             % 0-normal, 1-flip horizontal axis
% sbconfig.gain_override = 1;             % override default gain settings?
% 
% sbconfig.gain_galvo = logspace(log10(1),log10(8),13);  % more options now!
% sbconfig.gain_resonant_mult = 1.42;                     % resonant multiplier (>1.0) was 1.42 [1.16 for Nikon x25]
% sbconfig.gain_resonant = sbconfig.gain_resonant_mult * sbconfig.gain_galvo;
% sbconfig.dv_galvo      = 64;            % dv per line (64 is the maximum) -- don't touch!
% 
% sbconfig.wdelay = 50;                   % warmup delay for resonant scanner (in tens of ms)
sbconfig.cam_pulse_width = 16;          % default pulse width in steps of 125us -- thus 16 = 2ms

% SLM config variables

sbconfig.slm    = false;                       % SLM option 
sbconfig.slmdev = 'Dev1';                     % SLM daq device used
sbconfig.slmTrigger = 'Dev1/PFI9';
sbconfig.slmcal = 'slmcal';                   % SLM calibration file

sbconfig.slmwidth  = 1920;
sbconfig.slmheight = 1080;
sbconfig.slm_centerx = sbconfig.slmwidth/2;
sbconfig.slm_centery = sbconfig.slmheight/2;
sbconfig.slm_prismx = -sbconfig.slmwidth/2;
sbconfig.slm_prismy = -sbconfig.slmwidth/2;
sbconfig.slm_size = 30;                          % default size

sbconfig.slm_nx = 3;                            % # of points in calibration grid in x and y - must be odd!
sbconfig.slm_ny = 3;

sbconfig.slm_validation_power = .03;             % slm power during validation (NaN means automatic calibration)
sbconfig.slm_threshold = 50000;                  % target intensity for automatic power calib (use 0.75*maxvalue for camera)
sbconfig.slm_powerlow = 0;                   % brackets for binary search
sbconfig.slm_powerhigh = 0.4;                    % make sure threshold falls in-between

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
sbconfig.agc_prctile = [1e-5 1e-3]; % bounds on percent pixels saturated wanted
sbconfig.agc_threshold = 250;       % threshold above which is considered saturated (255 is max value)

% objective list
sbconfig.objectives = {'Nikon 16x/0.8w/WD3.0','Nikon 25x/1.10w/WD2.0'};

% Optogenetics panel

sbconfig.optogenetics = false;
sbconfig.led_id = [];
sbconfig.led_stim_com = [];
% sbconfig.led_id = 'USB0::0x1313::0x80C8::M00476084::INSTR'; % Thorlabs DC2020 controller
% sbconfig.led_stim_com = 'COM8';                             % Arduino pulse generator

% Bishift calibration saved
sbconfig.bishift = [-10 -9 -7 -3 -3 0 3 7 14 21 30 40 58 ];

% Bishift calibration saved
sbconfig.bishift = [-10 -9 -7 -3 -3 0 3 7 14 21 30 40 58 ];
