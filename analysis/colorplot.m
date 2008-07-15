
function out=colorplot(varargin)
%out=colorplot(x,y,numColors)
%out=colorplot(x,y,numColors,startColor,endColor)
%out=colorplot(x,y, 20,[0.2,0.8,0.9],[0.7,0.0,0.1]);

completed=0;

if nargin < 3
    error('must specify x, y and number of color steps -  colors optional')
end

x= varargin{1};
y= varargin{2};
numColors= varargin{3};

if nargin ==3  % use hsvdefault
    hsvcolor=hsv(floor(numColors*1.1));
end

if nargin ==5  % use hsvdefault
    %this utility is unused.
    startColor=varargin{4};
    endColor=varargin{5};
    inc=(endColor-startColor)/numColors;  % amount of color change
    hsvcolor=-99;
end
    
if nargin >5  % to
    error('too many input args')
end

%MAKE TEST DATA
%N=1010;
%numColors=20;
%x=randn(1,N);
%y=randn(1,N);
%x(1:N/2)=x(1:N/2)+17;
%y(1:N/2)=y(1:N/2)+7.5+0.06*[1:N/2];
%startColor=[0.2,0.8,0.9];
%endColor=[0.7,0.0,0.1];

chunkSize=floor(size(x,2)/numColors);
 
if (chunkSize==0)
    error('data must vary on 2nd dim, try transpose')
end


%main color change plot loop
%hold off
for i=1:numColors-1
    ss=chunkSize*(i-1)+1;
    ee=chunkSize*(i)+1;
    if  hsvcolor==-99; %using colors specified
        plot(x(ss:ee),y(ss:ee),'.','color',startColor+(inc*i)); %
    else %using default colors
         plot(x(ss:ee),y(ss:ee),'.','color',hsvcolor(i,:));
    end
    
    hold on
end 

%plot leftovers to end
ss=chunkSize*(numColors);
ee=size(x,2);

if  hsvcolor==-99; %using colors specified
    plot(x(ss:ee),y(ss:ee),'.','color',startColor+(inc*numColors)); %
else %using default colors
    plot(x(ss:ee),y(ss:ee),'.','color',hsvcolor(numColors,:))
end

completed=1;
out=completed;