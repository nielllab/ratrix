close all

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

sbxaligndir
makeSbxMoviesBatch

% params to use: spatial 2, temporal 4, frmrate 25, yes to align

psfilename = 'c:\temp.ps';
if exist(psfilename,'file')==2;delete(psfilename);end



tic



% topo2pSession('G62EE8TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62EE8TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62EE8TT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62EE8TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62EE8TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62EE8TT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);

% topo2pSession('G62AA3TT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62AA3TT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62AA3TT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AA3TT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62AA3TT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62AA3TT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);

topo2pSession('G62TX210TT_001_001.sbx','topoXsession_V2.mat',psfilename);
topo2pSession('G62TX210TT_001_002.sbx','topoYsession_V2.mat',psfilename);

% topo2pSession('G62BB8RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62BB8RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62BB8RT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB8RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62BB8RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62BB8RT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);

% topo2pSession('G62Y9RT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62Y9RT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62Y9RT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y9RT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62Y9RT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62Y9RT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);

% 
% topo2pSession('G62TX19LT_001_001.sbx','topoXsession_V2.mat',psfilename);
% topo2pSession('G62TX19LT_001_002.sbx','topoYsession_V2.mat',psfilename);
% grating2pSession('G62TX19LT_001_003.sbx','gratingSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX19LT_001_004.sbx','sizeSession_PRE_V2.mat',psfilename);
% sizeSelect2pSession('G62TX19LT_001_005.sbx','sizeSession_POST_V2.mat',psfilename);
% grating2pSession('G62TX19LT_001_006.sbx','gratingSession_POST_V2.mat',psfilename);


% sizeSelect2pSession('g62tx1rt_001_007.sbx','sizeSessionPOST_V2.mat',psfile);
% 
% topo2pSession('g62tx1rt_001_000.sbx','topoXsessionPRE_V2.mat',psfile);
% topo2pSession('g62tx1rt_001_001.sbx','topoYsessionPRE_V2.mat',psfile);
% topo2pSession('g62tx1rt_001_008.sbx','topoXsessionPOST_V2.mat',psfile);
% topo2pSession('g62tx1rt_001_009.sbx','topoYsessionPOST_V2.mat',psfile);


% 


toc

% 
% try
%     dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )
% 
% catch
%     display('couldnt generate pdf');
% end
%delete(psfile);

dos(['ps2pdf ' psfilename ' "' newpdfFile '"'] )
if exist(newpdfFile,'file')
%     ['ps2pdf ' psfilename ' "' psfilenameFinal(1:(end-2)) 'pdf"']
    display('generated pdf using dos ps2pdf')
else
    try
        ps2pdf('psfile', psfilename, 'pdffile', newpdfFile)
        newpdfFile
        display('generated pdf using builtin matlab ps2pdf')
    catch
        display('couldnt generate pdf');
        keyboard
    end
end

delete(psfilename);
%getCellsBatch;
