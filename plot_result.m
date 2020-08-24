x=[1 3 4 5 ];
max=[-127 -133 -129 -200];
bc=[-126 -167 -197 -200];
fem=[-101 -129 -172 -200];
sm=[-116 -185 -200 -200];
gail=[-101 -109 -102 -101];
ex=[-101 -101 -101 -101];
rand=[-200 -200 -200 -200];
figure;
hold on;
axis([0.5 5 -250 -70])
plot(x,max,'b+-')
plot(x,bc,'go-')
plot(x,fem,'r+-')
plot(x,sm,'k+-')
plot(x,gail,'c+-')
plot(x,rand,'m+-')
plot(x,ex,'m+-')