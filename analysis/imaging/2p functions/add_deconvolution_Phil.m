function add_deconvolution(ops, db)
ops = build_ops3(db, ops);
ops0 = ops;

try
    ppool = gcp ;
catch
end

% warning('ops0.imageRate now represents the TOTAL frame rate of the recording over all planes. This warning will be disabled in a future version. ')

for i = 1:length(ops.planesToProcess)
    iplane  = ops.planesToProcess(i);
    
    fpath = sprintf('%s/F_%s_%s_plane%d_proc.mat', ops.ResultsSavePath, ...
        ops.mouse_name, ops.date, iplane);
    if exist(fpath, 'file')
        load(fpath);
    else
        fpath = sprintf('%s/F_%s_%s_plane%d.mat', ops.ResultsSavePath, ...
            ops.mouse_name, ops.date, iplane);
        dat = load(fpath);
    end
    
%     if isfield(dat, 'dat') %dat.dat not a field on my guy 5/19/17??? is
%%%%     this necessary?
%         dat = dat.dat; % just in case...
%     end
    
    % overwrite fields of ops with those saved to file
    ops = addfields(ops, dat.ops);
    
    % set up options for deconvolution
    ops.imageRate    = getOr(ops0, {'imageRate'}, 0.1); % total image rate (over all planes)
    ops.sensorTau    = getOr(ops0, {'sensorTau'}, 2); % approximate timescale in seconds
    ops.sameKernel   = getOr(ops0, {'sameKernel'}, 1); % 1 for same kernel per plane, 0 for individual kernels (not recommended)
    ops.sameKernel   = getOr(ops0, {'sameKernel'}, 1);
    ops.maxNeurop    = getOr(ops0, {'maxNeurop'}, Inf); % maximum neuropil coefficient (default no max)
    ops.recomputeKernel    = getOr(ops0, {'recomputeKernel'}, 0);
    ops.deconvType  = 'L0'; %type of deconvolution; OASIS or L0
    
    
    fprintf('Spike deconvolution, plane %d... \n', iplane)
    
    % compute neuropil coefficient and run deconvolution on
    % neuropil-corrected trace
    stat = run_deconvolution3(ops, dat);
    
    dat.stat = stat;
    
    save(fpath, '-struct', 'dat')
end
%
