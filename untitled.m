load matlab.mat

x = out.state(:,1);
y = out.state(:,2);
phi = out.state(:,3);
v = out.state(:,4);

figure(1)
hold on
plot(x,y);
grid on
hold off
