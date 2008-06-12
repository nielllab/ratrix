function [s lastZone] = doPrime(s)
                    for i=1:length(s.zones)
                        fprintf('priming zone %d\n',i)
                        s.pump=doPrime(s.zones{i},s.pump);
                        lastZone=i;
                    end