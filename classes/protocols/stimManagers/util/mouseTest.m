function mouseTest
close all
clc

priorityLevel = MaxPriority('GetSecs','SetMouse','GetMouse','WaitSecs');
oldPriority = Priority(priorityLevel);

n = 100;
x = nan(4,n);
[width, height] = Screen('WindowSize',min(Screen('Screens')));
p = [width height]/2;
for i = 1:n
    x(1,i) = GetSecs;
    x(4,i) = 0;
    while any(isnan(x(2:3,i)))
        [a,b] = GetMouse;
        if any([a b] ~= p)
            x(2:3,i) = [a b];
        else
            x(4,i) = x(4,i) + 1;
        end
    end
    SetMouse(p(1),p(2)); %takes 1/4 second on OSX for GetMouse to see something new after this!    
end

Priority(oldPriority);

subplot(2,1,1)
semilogy(diff(x(1,:))*1000)
xlabel('sample')
ylabel('ms')
title(sprintf('median = %g ms',1000*median(diff(x(1,:)))))

subplot(2,1,2)
semilogy(x(4,:))
ylabel('spins')

% figure
% plot(x(2:3,:)')

priorityLevel