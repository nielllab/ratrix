function MID(stim,spks)
% MID notes:
% need to recompile for osx/intel (original architecture not specified?)
% need the 'missing' src files from numerical recipes; makefile needs lines uncommented
% makefile has no clean target, so need to rm *.o btw recompiles
% makefile doesn't automatically make test_function, need make -f generic_makefile test_function

close all
clc

MIDpath='/Users/eflister/Desktop/MID/';
addpath(genpath(MIDpath));

    function in=normalize(in)
        in=in-min(in(:));
        in=in/max(in(:));
    end

if ~exist('stim','var') || isempty(stim)
    if exist('spks','var') && ~isempty(spks)
        error('can''t specify spks but not stim')
    end
    fprintf('simulating data\n');
    
    hz=100;
    mins=20;
    numFrames=1+mins*60*hz;
    stim=randn(1,numFrames);
    
    kernSecs=1;
    kernel=zeros(1,kernSecs*2*hz+1);
    lims=ceil(length(kernel)*[1 2]/5);
    kernel(lims(1):lims(2))=sin(linspace(0,2*pi,lims(2)-lims(1)+1));
    g=normalize(conv(stim,fliplr(kernel),'same'));
    
    spikeRate=20;
    [dist bins]=hist(g,100);
    
    nonlin=cumsum(dist)/length(g) > 1-spikeRate/hz;
    spks=rand(1,length(stim)) < interp1(bins,nonlin,g);
    stim=[randn(1,numFrames);stim;randn(2,numFrames)]; %verify everything works if we transpose this too
end

dims=size(stim);
switch length(dims)
    case 2
        if isscalar(unique(dims))
            error('frames and single dim of stim are same size -- we expect frames to be bigger')
        end
        [lens order]=sort(dims);
        stim=reshape(stim,[1 lens(order(1)) lens(order(2))]);
        
        numFrames=max(dims);
        dims=[1 min(dims)];
    case 3
        numFrames=dims(end);
        if max(dims)~=numFrames
            error('largest dim of stim (which we expect to be frames) wasn''t last')
        end
        dims=dims(1:2);
    otherwise
        error('stim must have dims (horiz x vert x frames)') %their readme doesn't specify horiz vs. vert -- check for accidental transpose
end

if ~isvector(spks) || length(spks)~=numFrames
    error('spks should be vector of length numFrames')
elseif any(spks<0)
    error('spks should not be negative')
    %we accept nonintegers in case an average rate has been computed eg from a PSTH
end

numBits=8;
type=sprintf('uint%d',numBits);
tmp=cellfun(@(x) feval(type,normalize(double(x))*double(intmax(type))),{stim,spks},'UniformOutput',false); %should later undo this scaling of spike rate
[stim exSpks]=deal(tmp{:});

tmpPath=fullfile(MIDpath,'tmp');
stimFile=fullfile(tmpPath,'stim.raw');
spkFile=fullfile(tmpPath,'spks.isk'); %why do they use .isk convention?  google says this is for "command files"...

cellName='tmp';
x0=0;
y0=0;
cx=1;
cy=1;
nlags=round(.5*hz);

justRead=true;
if ~justRead
    
    [status,message,messageid] = mkdir(tmpPath);
    if ~status
        message
        messageid
        error('mkdir fail')
    end
    
    writeBinaryFile(stimFile,stim);
    fprintf('wrote stim file with %d frames\n',numFrames)
    writeBinaryFile(spkFile,exSpks);
    fprintf('wrote spike file with %g spikes (%g)\n',sum(spks(:)),sum(exSpks(:)))
    
    if exist('hz','var')
        fprintf('spike rate was %g\n',sum(spks(:))/(numFrames/hz))
    end
    
    %consider modifying these to have output arguments of numframes and numspikes so can verify programmatically with no graphics output
    verify_stim_file(stimFile,dims(1),dims(2))
    verify_spike_file(spkFile)
    
    [status result]=system(sprintf('%s %s %s %s %s %d %d %d %g %g %g %g %g %g %d',fullfile(MIDpath,'do_MaxInfoDim_Nvec'),cellName,stimFile,spkFile,tmpPath,dims(1),dims(2),numFrames,x0,y0,dims(1),dims(2),cx,cy,nlags));
    result
    if status~=0
        status
        error('do_MaxInfoDim_Nvec fail')
    end
end

    function writeBinaryFile(name,data)
        % from readme:
        % The stimulus file has to be written in binary format, where each
        % pixel is in uint8 format. The spike file is also written in uint8
        % format, where each number corresponds to the number of spikes
        % for each frame of the stimulus movie.
        
        [fid message] = fopen(name, 'w');
        if ismember(fid,[-1:2])
            message
            error('fopen fail')
        end
        count=fwrite(fid, data, type);
        stop=false;
        try
            if count~=numel(data)
                count
                numel(data)
                error('fwrite didn''t do all vals')
            end
        catch ex
            ex.getReport
            stop=true;
        end
        status=fclose(fid);
        if status~=0
            error('fclose fail')
        end
        if stop
            error('error prior to close')
        end
    end

read_vec_pxpxt_file(fullfile(tmpPath,['Test_v_' cellName]),[dims(1) dims(2) nlags cx])
keyboard
read_app_file(fullfile(tmpPath,['app_' cellName]))

read_app_file(fullfile(tmpPath,['app_' cellName '_' sprintf('%dx%dx%d',1,4,50) '_1']))
end

% The parameters are:
%
% <cell name>
%     Identifier of each cell to be analyzed. All output
%     files will have this identifier in the file names.
%
% <stim file>
%     Stimulus file name.
%
% <spike file>
%     File containing the spikes for the current cell.
%
% <data root>
%     Data directory for storing the output files.
%
% <dimx> <dimy> <length>
%     Size of the stimulus movie.
%     Pixel dimensions in x (horizontal) and y (vertical)
%     directions and number of frames.
%
% <x0>,<y0>,<dx>,<dy>
%     The receptive field is typically analyzed in a
%     smaller window. These four numbers specify the
%     window of interest: the coordinates of the upper-
%     left corner pixel, width, and height.
%
% <cx>,<cy>
%     Downsampling factor. Typically, let cx=cy.
%     The estimated receptive field (maximally informative
%     dimensions) will have the size of (dx/cx,dy/cy).
%
% <nlags>
%     Number of frames to incorporate in estimating the
%     maximally informative dimensions. Receptive field is
%     a spatio-temporal kernel.  This parameter determines
%     the temporal extent, while the parameters dx and dy
%     determines the spatial extent of the receptive field.
%
% Optional arguments:
%
% -Nbins (integer num)
%     Number of bins to discretize probability
%     distribution. Default is 15.
%
% -Njack (integer num)
%     Total number of jackknife estimates,
%     corresponding to Nparts variable in source code.
%     Default is 4.
%
% -jack (integer num)
%     Jackknife run. If this argument is not
%     specified, all jackknives will run in
%     sequence.
%
% -errormargin (float num)
%     This parameter determines the early-stopping criteria.
%     If the improvement of information optimization drops
%     on a test-set, the optimization is stopped before
%     reaching the maximum iteration number (-Max parameter).
%     To force the program run longer, increase error margin.
%     Default is 0.75.
%
% -Max (integer num)
%     Maximum number of simulated annealing iterations.
%     This number should be comparable to the size of
%     maximally informative dimensions (i.e., in the
%     order of (dx/cx)*(dy/cy)*nlags).
%     Default is 1000.