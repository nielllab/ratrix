    [f p] = uigetfile('*.mat','session data');
    display('loading data')
    sessionName = fullfile(p,f);
    tic, load(sessionName); toc
    cycLength = cycLength/dt;
    
    [f p] = uigetfile('*.mat','generic points file');
    load(fullfile(p,f),'x','y','refFrame');
    
    sprintf('enter width of window for cell body extraction')
    sprintf('typical = 4 or 5 for cell body on scanbox 1x, but depends of fov and zoom')
    w = input('width : ');
    showImg = input('show images? 0/1 ');
    
    [pts dF ptsfname icacorr cellImg usePts] = get2pPtsAuto(dfofInterp,greenframe,x,y,refFrame,w, showImg);
    
    [f p] = uiputfile('*.mat','save points data');
    if f~=0
        save(fullfile(p,f),'pts','dF','coverage','greenframe','usePts');
    end