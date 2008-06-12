function out=computeGabors(params,waveform,mean,width,height)
    
    radius=params(:,1);
    pixPerCyc=params(:,2);
    phase=params(:,3);
    orientation=params(:,4);
    contrast=params(:,5);
    thresh=params(:,6);
    xPosPct=params(:,7);
    yPosPct=params(:,8);   
      
    numGabors = size(params,1);
    
    xSize=width;
    ySize=height;

    img = zeros(numGabors,ySize,xSize);
    biggest=max(xSize,ySize);
    diagonal=sqrt((xSize/2)^2 + (ySize/2)^2);
    
    for i=1:numGabors

        line=contrast(i)*sin(phase(i) + (0:biggest*2)*(2*pi)/pixPerCyc(i))/2;
        %line=contrast*(sin(phase + (0:ySize*2)*(2*pi)/pixPerCyc)/2);
        
        switch waveform
            case 'sine'
                %do nothing; you're done.
            case 'square'
                line=contrast(i)*(line>0)
            otherwise
                error('waveform must be ''sine'' or ''square''');
        end
        
        grating=repmat(line',1,biggest*2);
        %grating=repmat(line',1,xSize*2);
            
        %pmm hates calling imrotate which is slow, even though the fuction
        %says it shouldn't be for 90 deg rotations...
        if abs(orientation(i)-1) <0.00001  %check if vertical
            rotated=grating;
        elseif orientation(i) == abs(mod((orientation(i)-pi*[1:10])/(pi/2),2)-1)<0.00001  % check if horizontal
            rotated=grating';
        else          
            rotated=imrotate(grating,orientation(i)*360/(2*pi),'bilinear','crop');
        end
        
        xStart = ceil(.25*xSize);
        yStart = ceil(.25*ySize);
        rotated = rotated(xStart:xStart+xSize-1,yStart:yStart+ySize-1);

        mask=zeros(ySize,xSize);
        mask(1:xSize*ySize)=mvnpdf([reshape(repmat((-ySize/2:(-ySize/2 + ySize -1))',1,xSize),xSize*ySize,1) reshape(repmat(-xSize/2:(-xSize/2+xSize-1),ySize,1),xSize*ySize,1)],[yPosPct(i)*ySize-ySize/2 xPosPct(i)*xSize-xSize/2],radius(i)*diag([diagonal diagonal]));
        mask=mask/max(max(mask));

        masked = rotated'.*mask;

        masked(abs(masked)<thresh(i))=0;
        img(i,:,:)=masked;
    end
    
    out=mean+squeeze(sum(img,1));
    
    out(out<0)=0;
    out(out>1)=1;
    
    out(1)=0;
    out(2)=1;