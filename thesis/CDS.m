function z=CDS(a,b,s,L,gamma,PEURC);
j=(b-a)*4;
Gamma_j=zeros(1,j+1);
for i=2:(j+1)
Gamma_j(i)=Gamma_j(i-1)+gamma(i);
end
fir=0;
sec=0;
thir=0;
for i=1:j
fir=fir+gamma(i)*quad(@(u)FIRST(u,Gamma_j,gamma,PEURC,i-1),i-1,i);
sec=sec+exp(-Gamma_j(i))*PEURC(i*90);
thir=thir+gamma(i)*quad(@(u)THIRD(u,Gamma_j,gamma,PEURC,i-1),i-1,i);
end
fir=s*fir;
sec=s*sec;
thir=L*thir;
z=fir+sec-thir;
return;


%PEURC=feval(fitobject,[1/360:1/360:1])
%CDS(0,1,.5050/4,0.4,gamma,PEURC)
%kk=[[gamma1/4*ones(1,5)] [gamma2/4*ones(1,8)] [gamma3/4*ones(1,8)] [gamma4/4*ones(1,8)] [gamma5/4*ones(1,12)]];
%fzero(@(gamma1)CDS(0,ba(1),sa(1)/4,L,kk,PEURC),gamma1)
%fzero(@(gamma1)CDS(0,ba(1),sa(1)/4,L,[[gamma1/4*ones(1,5)] [gamma2/4*ones(1,8)] [gamma3/4*ones(1,8)] [gamma4/4*ones(1,8)] [gamma5/4*ones(1,12)]],PEURC),gamma1)


function y=FIRST(u,Gamma_j,gamma,PEURC,mmin)
days=floor(u*90);
days(days == 0) = 1;
y=exp(-Gamma_j(mmin+1)-gamma(mmin+2).*(u-mmin)).*PEURC(days)'.*(u-mmin);
return;
%Third argument auxiliary function for the CDS pricing
function y=THIRD(u,Gamma_j,gamma,PEURC,mmin)
days=floor(u*90);
days(days == 0) = 1;
y=exp(-Gamma_j(mmin+1)-gamma(mmin+2).*(u-mmin)).*PEURC(days)';
return;