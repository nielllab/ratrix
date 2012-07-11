        %         background.contrastFactor=0;
        %         background.sizeFactor=0;
        %         background.densityFactor=0;
setBackground(dots,[])


stimManager 
setReinfAssocSecs(dots,1)
setDuration(dots,inf)
setMode(dots,'expert')
setTextureSize(dots,[maxWidth maxHeight])
setZoom(dots,ones(1,2))