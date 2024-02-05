function sbx2tif_select_chan(fname,chan,varargin)

% sbx2tif
% Generates tif file from sbx files
% chan is the channel to convert
% Argument is the number of frames to convert
% If no argument is passed the whole file is converted

z = sbxread(fname,1,1);
global info;

if(nargin>2)
    N = min(varargin{1},info.max_idx);
else
    N = info.max_idx;
end

k = 0;
done = 0;
while(~done && k<=N)
    try
        q = sbxread(fname,k,1);
        q = squeeze(q(chan,:,:));
        if(k==1)
            imwrite(q,[fname '.tif'],'tif');
        else
            imwrite(q,[fname '.tif'],'tif','writemode','append');
        end
    catch
        done = 1;
    end
    k = k+1;
end