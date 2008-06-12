function [tf loc]=clientIsRegistered(r,c)
loc=0;
tf=false;
clients={r.serverRegister{:,1}};
for i=1:length(clients)
    if c.equals(clients{i})
        if loc==0
            loc=i;
            tf=true;
        else
            error('multiple instances of that client in the register')
        end
    end
end