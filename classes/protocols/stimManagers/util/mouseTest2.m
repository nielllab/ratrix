function mouseTest2
priorityLevel=MaxPriority('GetSecs','KbCheck','GetMouse','WaitSecs');
oldPriority=Priority(priorityLevel);

n=100;
x=nan(3,n);

[x(2,1) x(3,1)]=GetMouse;
x(1,1)=GetSecs;

for i=2:n
    x(1,i)=WaitSecs('YieldSecs', .001);
    while any(isnan(x(2:3,i)))
        [a,b]=GetMouse;
        if any([a b]'~=x(2:3,i-1))
            [x(2,i),x(3,i)]=deal(a,b);
            [a,b]
        end
    end
end

Priority(oldPriority);

plot(diff(x(1,:)))
hold on
plot(x(2:3,:)')
mean(diff(x(1,:)))
priorityLevel