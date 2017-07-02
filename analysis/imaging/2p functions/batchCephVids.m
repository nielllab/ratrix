clear files
done =0; i=0;
while done==0;
    [f p] = uigetfile({'*.tif'},'.mat or .tif file');
    if f~=0
       i = i+1;
       files{i} = fullfile(p,f);
    else done=1;
    end
end

for i = 1:length(files);
    fname = files{i};
    genericSutterVidsRG;
end
