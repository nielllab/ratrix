function mouseTest
n=100;
x=nan(3,n);
[width, height]=Screen('WindowSize',min(Screen('Screens')));
p=[width height]/2;
for i=1:n
    x(1,i)=GetSecs;
    while any(isnan(x(2:3,i)))
        [a,b]=GetMouse;
        if any([a b]~=p)
            [x(2,i),x(3,i)]=deal(a,b);
            [a,b]
        end
    end
    SetMouse(p(1),p(2)); %takes 1/4 second on OSX for GetMouse to see something new after this!
end
plot(diff(x(1,:)))
hold on
plot(x(2:3,:)')
mean(diff(x(1,:)))