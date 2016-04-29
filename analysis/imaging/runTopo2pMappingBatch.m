close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

% sbxaligndir
% 
% makeSbxMoviesBatch

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end


tic

topo2pSession('g62w9rt_001_000.sbx','topoXsession1.mat',psfile);
topo2pSession('g62w9rt_001_001.sbx','topoYsession1.mat',psfile);
topo2pSession('g62w9rt_001_002.sbx','topoXsession2.mat',psfile);
topo2pSession('g62w9rt_001_003.sbx','topoYsession2.mat',psfile);
topo2pSession('g62w9rt_001_004.sbx','topoXsession3.mat',psfile);
topo2pSession('g62w9rt_001_005.sbx','topoYsession3.mat',psfile);
topo2pSession('g62w9rt_001_006.sbx','topoXsession4.mat',psfile);
topo2pSession('g62w9rt_001_007.sbx','topoYsession4.mat',psfile);
topo2pSession('g62w9rt_001_008.sbx','topoXsession5.mat',psfile);
topo2pSession('g62w9rt_001_009.sbx','topoYsession5.mat',psfile);
topo2pSession('g62w9rt_001_010.sbx','topoXsession6.mat',psfile);
topo2pSession('g62w9rt_001_011.sbx','topoYsession6.mat',psfile);
topo2pSession('g62w9rt_001_012.sbx','topoXsession7.mat',psfile);
topo2pSession('g62w9rt_001_013.sbx','topoYsession7.mat',psfile);
topo2pSession('g62w9rt_001_014.sbx','topoXsession8.mat',psfile);
topo2pSession('g62w9rt_001_015.sbx','topoYsession8.mat',psfile);
topo2pSession('g62w9rt_001_016.sbx','topoXsession9.mat',psfile);
topo2pSession('g62w9rt_001_017.sbx','topoYsession9.mat',psfile);
topo2pSession('g62w9rt_001_018.sbx','topoXsession10.mat',psfile);
topo2pSession('g62w9rt_001_019.sbx','topoYsession10.mat',psfile);
topo2pSession('g62w9rt_001_020.sbx','topoXsession11.mat',psfile);
topo2pSession('g62w9rt_001_021.sbx','topoYsession11.mat',psfile);
topo2pSession('g62w9rt_001_022.sbx','topoXsession12.mat',psfile);
topo2pSession('g62w9rt_001_023.sbx','topoYsession12.mat',psfile);
topo2pSession('g62w9rt_001_024.sbx','topoXsession13.mat',psfile);
topo2pSession('g62w9rt_001_025.sbx','topoYsession13.mat',psfile);
topo2pSession('g62w9rt_001_026.sbx','topoXsession14.mat',psfile);
topo2pSession('g62w9rt_001_027.sbx','topoYsession14.mat',psfile);
topo2pSession('g62w9rt_001_028.sbx','topoXsession15.mat',psfile);
topo2pSession('g62w9rt_001_029.sbx','topoYsession15.mat',psfile);
topo2pSession('g62w9rt_001_030.sbx','topoXsession16.mat',psfile);
topo2pSession('g62w9rt_001_031.sbx','topoYsession16.mat',psfile);
topo2pSession('g62w9rt_001_032.sbx','topoXsession17.mat',psfile);
topo2pSession('g62w9rt_001_033.sbx','topoYsession17.mat',psfile);
topo2pSession('g62w9rt_001_034.sbx','topoXsession18.mat',psfile);
topo2pSession('g62w9rt_001_035.sbx','topoYsession18.mat',psfile);
topo2pSession('g62w9rt_001_036.sbx','topoXsession19.mat',psfile);
topo2pSession('g62w9rt_001_037.sbx','topoYsession19.mat',psfile);
topo2pSession('g62w9rt_001_038.sbx','topoXsession20.mat',psfile);
topo2pSession('g62w9rt_001_039.sbx','topoYsession20.mat',psfile);
topo2pSession('g62w9rt_001_040.sbx','topoXsession21.mat',psfile);
topo2pSession('g62w9rt_001_041.sbx','topoYsession21.mat',psfile);
topo2pSession('g62w9rt_001_042.sbx','topoXsession22.mat',psfile);
topo2pSession('g62w9rt_001_043.sbx','topoYsession22.mat',psfile);
topo2pSession('g62w9rt_001_044.sbx','topoXsession23.mat',psfile);
topo2pSession('g62w9rt_001_045.sbx','topoYsession23.mat',psfile);
topo2pSession('g62w9rt_001_046.sbx','topoXsession24.mat',psfile);
topo2pSession('g62w9rt_001_047.sbx','topoYsession24.mat',psfile);
topo2pSession('g62w9rt_001_048.sbx','topoXsession25.mat',psfile);
topo2pSession('g62w9rt_001_049.sbx','topoYsession25.mat',psfile);
topo2pSession('g62w9rt_001_050.sbx','topoXsession26.mat',psfile);
topo2pSession('g62w9rt_001_051.sbx','topoYsession26.mat',psfile);
topo2pSession('g62w9rt_001_052.sbx','topoXsession27.mat',psfile);
topo2pSession('g62w9rt_001_053.sbx','topoYsession27.mat',psfile);
topo2pSession('g62w9rt_001_054.sbx','topoXsession28.mat',psfile);
topo2pSession('g62w9rt_001_055.sbx','topoYsession28.mat',psfile);
topo2pSession('g62w9rt_001_056.sbx','topoXsession29.mat',psfile);
topo2pSession('g62w9rt_001_057.sbx','topoYsession29.mat',psfile);
topo2pSession('g62w9rt_001_058.sbx','topoXsession30.mat',psfile);
topo2pSession('g62w9rt_001_059.sbx','topoYsession30.mat',psfile);


toc


try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
%delete(psfile);

%getCellsBatch;
