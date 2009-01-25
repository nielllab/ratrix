%
%average across diagonals of a hankel matrix
%
%urut/nov04
function av  = aaad(S)

[M,N] = size(S);
K=M+N-1;
for i=1:K
    a=0;
    alpha=max(1,i-M+1);
    beta=min(N,i);
    for k=alpha:beta
        a=a+S(i-k+1,k);
    end
    av(i)=a*1/(beta-alpha+1);
end