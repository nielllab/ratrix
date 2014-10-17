function  pts=getMapPts(imhandle,fname)
%%% Loads an image file and allows user to select points that will be used
%%% for subsequent map analysis

if ~exist('imhandle','var')
[f,p] = uigetfile('*.fig','reference map');
open(fullfile(p,f));
else
    figure(imhandle)
end
hold on

sz=size(get(get(gca,'Children'),'CData'))

done=0;
npts=0;

while ~done
    [y x b] = ginput(1);
    if b==3 %%% right click
        done = 1;
        break
    elseif b ==1
        npts =npts+1;
        pts(npts,1)=round(x);
        pts(npts,2)=round(y);
        plotdata(npts) = plot(round(y),round(x),'g*'); plotdata2(npts) = plot(round(y),round(x),'bo');
    elseif b==32 %%% spacebar
        delete(plotdata(npts)); delete(plotdata2(npts))
        npts=npts-1;    
    end
end
pts



if ~exist('fname','var')
[f,p] = uiputfile('*.mat','map points');
save(fullfile(p,f),'pts','sz');
elseif ~isempty(fname)
    save(fname,'pts')
end


