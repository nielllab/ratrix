function out=computeFlickerFields(params,type,mean,width,height,cornerMarkOn)

% params = [1 16 0.5 0.001 1/2 1/2 ];
% grating=computeFlickerFields(params,0.5,200,200,1);

fieldWidthPct=params(:,1);
fieldHeightPct=params(:,2);
contrasts=params(:,3);
thresh=params(:,4);
xPosPct=params(:,5);
yPosPct=params(:,6);



numFields = size(params,1);

xSize=width;
ySize=height;

img = zeros(numFields,ySize,xSize);
invImg = zeros(numFields,ySize,xSize);
out = zeros(ySize,xSize,2);

switch(type)
    case 0 % Binary Flicker
        % For each field create the random white noise at a certain contrast
        for i=1:numFields
            yStart = ceil((yPosPct(i)-fieldHeightPct(i)/2)*ySize);
            yStop = ceil((yPosPct(i)+fieldHeightPct(i)/2)*ySize);
            xStart = ceil((xPosPct(i)-fieldWidthPct(i)/2)*xSize);
            xStop = ceil((xPosPct(i)+fieldWidthPct(i)/2)*xSize);
            field=zeros(ySize,xSize);
            invField=zeros(ySize,xSize);
            % Create a positive binary field of flicker
            signMap = sign(ones(length(yStart:yStop),length(xStart:xStop))-0.5);
            field(yStart:yStop,xStart:xStop)=signMap*contrasts(i)/2;
            invField(yStart:yStop,xStart:xStop)=signMap*-1*contrasts(i)/2;
            % If any values are below threshold, set them to zero
            field(abs(field)<thresh(i))=0;
            invField(abs(field)<thresh(i))=0;
            img(i,:,:)=field;
            invImg(i,:,:)=invField;
        end        
    case 1 % Gaussian Flicker
        error('Gaussian flicker not currently supported')
        % THIS NEEDS TO BE FIXED TO WORK FOR GAUSSIAN!
        % Need a way to have Gaussian distribution of contrast fit be
        % normalized to fit within the contrast bounds
        % For each field create the random white noise at a certain contrast
        for i=1:numFields
            yStart = ceil((yPosPct(i)-fieldHeightPct(i)/2)*ySize);
            yStop = ceil((yPosPct(i)+fieldHeightPct(i)/2)*ySize);
            xStart = ceil((xPosPct(i)-fieldWidthPct(i)/2)*xSize);
            xStop = ceil((xPosPct(i)+fieldWidthPct(i)/2)*xSize);
            field=zeros(ySize,xSize);
            invField=zeros(ySize,xSize);
            % Create a random binary field of flicker with variance of contrast
            valMap = randn(length(yStart:yStop),length(xStart:xStop));
            field(yStart:yStop,xStart:xStop)=valMap*contrasts(i)/2;
            invField(yStart:yStop,xStart:xStop)=valMap*-1*contrasts(i)/2;
            % If any values are below threshold, set them to zero
            field(abs(field)<thresh(i))=0;
            invField(abs(field)<thresh(i))=0;
            img(i,:,:)=field;
            invImg(i,:,:)=invField;
        end               
    otherwise
        error('Unkown flicker field type')
end

% Compress all of the fields into a single set of frames with specified mean
calcImg = zeros(numFields,ySize,xSize);
for i=1:2^numFields
    for j=1:numFields
        if bitget(i-1,j)
            calcImg(j,:,:) = img(j,:,:);
        else
            calcImg(j,:,:) = invImg(j,:,:);
        end
    end
    out(:,:,i)=mean+squeeze(sum(calcImg,1));
end
%firstOut=mean+squeeze(sum(img,1));
%secondOut=mean+squeeze(sum(invImg,1));
%out(:,:,1)=firstOut;
%out(:,:,2)=secondOut;

% Normalize all values so that all are 0<=val<=1
out(out<0)=0;
out(out>1)=1;

% Set the corner marker used for frame counting
if cornerMarkOn
    out(1,1,:)=0;
    out(1,2,:)=1;
end