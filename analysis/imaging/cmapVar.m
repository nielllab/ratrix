function cm=cmapVar(val,mn,mx,cmap)
%%% inputs
%%% value to be mapped
%%% min/max of range
%%% selected colormap
%%% output = color triplet
if ~exist('cmap','var')
cmap = jet;
end
v=(val-mn)/(mx-mn);
if v<0
    v=0;
elseif v>1
    v=1;
end
v = ceil(v*63+1);
cm = cmap(v,:);