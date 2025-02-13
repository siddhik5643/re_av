function [model, constraint] = model()

import casadi.*
model = struct();
constraint = struct();

model_name = 'model';

%% model parameters

% R = SX.sym('R');
% % 
% sym_p = vertcat(R);

%% casadi model
% set up states & controls
posx = SX.sym('posx');
posy = SX.sym('posy');
theta = SX.sym('thetha');
v = SX.sym('v');
x = vertcat(posx, posy, theta, v);

% controls
ang_vel = SX.sym('ang_vel');
accl = SX.sym('accl');
u = vertcat(ang_vel, accl);

% xdot
posxdot = SX.sym('posxdot');
posydot = SX.sym('posydot');
thetadot = SX.sym('thethadot');
vdot = SX.sym('vdot');
xdot = vertcat(posxdot, posydot, thetadot, vdot);

%parameter
params=[];

%algebraic variables
z =[];

% dyanmics
f_expl = vertcat( ...
    v*cos(theta),...
    v*sin(theta),...
    ang_vel,...
    accl...
    );

%constraints
% cons = v*;
%statebounds

%inputbounds


% path input bounds

%initial conditions
model.x0 = [0, 0, 0, 0];

%constraints struc
constraint.expr = [];

model.f_impl_expr = f_expl - xdot;
model.f_expl_expr = f_expl;
model.x = x;
model.xdot = xdot;
model.u = u;
model.z = z;
% model.params = sym_p;
model.name = model_name;

end
