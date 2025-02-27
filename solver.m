clear all
import casadi.*
run('C:\Solvers\acados\examples\acados_matlab_octave\acados_env_variables_windows.m')
%% Solver parameters
compile_interface = 'auto';
codgen_model = 'true';
nlp_solver = 'sqp'; % sqp, sqp_rti
qp_solver = 'full_condensing_qpoases';
    % full_condensing_hpipm, partial_condensing_hpipm, full_condensing_qpoases
nlp_solver_exact_hessian = 'True'; % false=gauss_newton, true=exact
qp_solver_cond_N = 50; % for partial condensing
regularize_method = 'no_regularize';
% regularize_method = 'project';
%regularize_method = 'mirror';
%regularize_method = 'convexify';
qp_solver_warm_start = 2; % (0) cold start, (1) warm start primal variables, (2) warm start and dual variables
% integrator type
sim_method = 'erk'; % erk, irk, irk_gnsf

%% horizon parameters
N = 2;
T = 1e-3; % time horizon length

%% model dynamics

[model, constraint] = model();

nx = length(model.x);
nu = length(model.u);

%% model to create the solver
ocp_model = acados_ocp_model();

%% acados ocp model
ocp_model.set('name', model.name);
ocp_model.set('T', T);

% symbolics
ocp_model.set('sym_x', model.x);
ocp_model.set('sym_u', model.u);
ocp_model.set('sym_xdot', model.xdot);
%ocp_model.set('sym_z', model.z);
% ocp_model.set('sym_p', model.params);

% dynamics
if (strcmp(sim_method, 'erk'))
    ocp_model.set('dyn_type', 'explicit');
    ocp_model.set('dyn_expr_f', model.f_expl_expr);
else % irk irk_gnsf
    ocp_model.set('dyn_type', 'implicit');
    ocp_model.set('dyn_expr_f', model.f_impl_expr);
end

nbx = 1;
Jbx = zeros(nbx,nx);
Jbx(1,4) = 1;
ocp_model.set('constr_Jbx', Jbx);
ocp_model.set('constr_lbx', -12);
ocp_model.set('constr_ubx', 12);

nbu = 1;
Jbu = zeros(nbx,nx);
Jbu(1,2) = 1;
ocp_model.set('constr_Jbu', Jbu);
ocp_model.set('constr_lbu', -1);
ocp_model.set('constr_ubu', 1);

% nc = 3;
% C = zeros(nc,nx);
% D = [0 1;
%     0.8660 -0.5;
%     0.8660 0.5];
% ocp_model.set('constr_C', C);
% ocp_model.set('constr_D', D);
% ocp_model.set('constr_lg', [constraint.U_minvalue; constraint.U_minvalue; constraint.U_minvalue]);
% ocp_model.set('constr_ug', [constraint.U_maxvalue; constraint.U_maxvalue; constraint.U_maxvalue]);

% 
% nh = 1;
% ocp_model.set('constr_expr_h', constraint.expr);
% ocp_model.set('constr_lh', -3.5);
% ocp_model.set('constr_uh', 3.5);

% set intial condition
ocp_model.set('constr_x0', model.x0);

ocp_model.set('cost_type', 'linear_ls');
ocp_model.set('cost_type_e', 'linear_ls');

% number of outputs is the concatenation of x and u
ny = nx +nu;
ny_e = nx;

% % The linear cost contributions is defined through Vx, Vu and Vz
Vx = zeros(ny, nx);
Vx_e = zeros(ny_e, nx);
Vu = zeros(ny, nu);

Vx(1:nx,:) = eye(nx);
Vx_e(1:nx,:) = eye(nx);
Vu(nx+1:end,:) = eye(nu);

% Vx = eye(ny);
% Vx_e = eye(ny);
% Vu = eye(ny);
ocp_model.set('cost_Vx', Vx);
ocp_model.set('cost_Vx_e', Vx_e);
ocp_model.set('cost_Vu', Vu);
% 
% Define cost on states and input
Q = diag([1, 1, 0, 1]);
R = eye(nu);
R(1, 1) = 10;
R(2, 2) = 1e-6;
Qe = diag([10, 10, 0, 10]);

unscale = N / T;
W = unscale * blkdiag(Q, R);
W_e = Qe / unscale;
ocp_model.set('cost_W', W);
ocp_model.set('cost_W_e', W_e);
% 
% set intial references
y_ref = zeros(ny,1);
y_ref_e = zeros(ny_e,1);
% y_ref(1) = 1; % set reference on 's' to 1 to push the car forward (progress)
% ocp_model.set('cost_y_ref_0', y_ref_0);
ocp_model.set('cost_y_ref', y_ref);
ocp_model.set('cost_y_ref_e', y_ref_e);
%% acados ocp set opts
ocp_opts = acados_ocp_opts();
ocp_opts.set('compile_interface', compile_interface);
ocp_opts.set('codgen_model', codgen_model);
ocp_opts.set('param_scheme_N', N);
ocp_opts.set('nlp_solver', nlp_solver);
ocp_opts.set('nlp_solver_exact_hessian', nlp_solver_exact_hessian);
ocp_opts.set('sim_method', sim_method);
ocp_opts.set('sim_method_num_stages', 4);
ocp_opts.set('sim_method_num_steps', 3);
ocp_opts.set('sim_method_newton_iter', 3);
ocp_opts.set('qp_solver', qp_solver);
ocp_opts.set('qp_solver_warm_start', qp_solver_warm_start);
ocp_opts.set('regularize_method', regularize_method);
ocp_opts.set('qp_solver_cond_N', qp_solver_cond_N);
ocp_opts.set('nlp_solver_tol_stat', 1e-4);
ocp_opts.set('nlp_solver_tol_eq', 1e-4);
ocp_opts.set('nlp_solver_tol_ineq', 1e-4);
ocp_opts.set('nlp_solver_tol_comp', 1e-4);
%% create ocp solver
ocp_solver = acados_ocp(ocp_model, ocp_opts);
% 
% 
% %% Simulate
% dt = T / N;
% Tf = 10.00;  % maximum simulation time[s]
% Nsim = round(Tf / dt);
% sref_N = 3;  % reference for final reference progress
% 
% % initialize data structs
% simX = zeros(Nsim, nx);
% simU = zeros(Nsim, nu);
% s0 = model.x0(1);
% tcomp_sum = 0;
% tcomp_max = 0;
% 
% ocp_solver.set('constr_x0', model.x0);
% ocp_solver.set('constr_lbx', model.x0, 0)
% ocp_solver.set('constr_ubx', model.x0, 0)
% 
% % set trajectory initialization
% ocp_solver.set('init_x', model.x0' * ones(1,N+1));
% ocp_solver.set('init_u', zeros(nu, N));
% ocp_solver.set('init_pi', zeros(nx, N));
% 
% % simulate
% for i = 1:Nsim
%     % update reference
%     sref = s0 + sref_N;
%     for j = 0:(N-1)
%         yref = [s0 + (sref - s0) * j / N, 0, 0, 0, 0, 0, 0, 0];
%         % yref=[1,0,0,1,0,0,0,0]
%         ocp_solver.set('cost_y_ref', yref, j);
%     end
%     yref_N = [sref, 0, 0, 0, 0, 0];
%     % yref_N=np.array([0,0,0,0,0,0])
%     ocp_solver.set('cost_y_ref_e', yref_N);
% 
%     % solve ocp
%     t = tic();
% 
%     ocp_solver.solve();
%     status = ocp_solver.get('status'); % 0 - success
%     if status ~= 0 && status ~= 2
%         % borrowed from acados/utils/types.h
%         %statuses = {
%         %    0: 'ACADOS_SUCCESS',
%         %    1: 'ACADOS_NAN_DETECTED',
%         %    2: 'ACADOS_MAXITER',
%         %    3: 'ACADOS_MINSTEP',
%         %    4: 'ACADOS_QP_FAILURE',
%         %    5: 'ACADOS_READY'
%         error(sprintf('acados returned status %d in closed loop iteration %d. Exiting.', status, i));
%     end
%     %ocp_solver.print('stat')
% 
%     elapsed = toc(t);
% 
%     % manage timings
%     tcomp_sum = tcomp_sum + elapsed;
%     if elapsed > tcomp_max
%         tcomp_max = elapsed;
%     end
% 
%     % get solution
%     x0 = ocp_solver.get('x', 0);
%     u0 = ocp_solver.get('u', 0);
%     for j = 1:nx
%         simX(i, j) = x0(j);
%     end
%     for j = 1:nu
%         simU(i, j) = u0(j);
%     end
% 
%     % update initial condition
%     x0 = ocp_solver.get('x', 1);
%     % update initial state
%     ocp_solver.set('constr_x0', x0);
%     ocp_solver.set('constr_lbx', x0, 0);
%     ocp_solver.set('constr_ubx', x0, 0);
%     s0 = x0(1);
% 
%     % check if one lap is done and break and remove entries beyond
%     if s0 > Sref(end) + 0.1
%         % find where vehicle first crosses start line
%         N0 = find(diff(sign(simX(:, 1))));
%         N0 = N0(1);
%         Nsim = i - N0 + 1;  % correct to final number of simulation steps for plotting
%         simX = simX(N0:i, :);
%         simU = simU(N0:i, :);
%         break
%     end
% end
% 
% %% Plots
% t = linspace(0.0, Nsim * dt, Nsim);
% 
% % Plot results
% figure(1);
% subplot(2,1,1);
% plot(t, simU(:,1), 'r');
% hold on;
% plot(t, simU(:,2), 'g');
% hold off;
% title('closed-loop simulation');
% legend('dD','ddelta');
% xlabel('t');
% ylabel('u');
% grid;
% xlim([t(1), t(end)]);
% 
% subplot(2,1,2);
% plot(t, simX);
% xlabel('t');
% ylabel('x');
% legend('s','n','alpha','v','D','delta');
% grid;
% xlim([t(1), t(end)]);
% 
% % Plot track
% figure(2);
% plotTrackProj(simX, track_file);
% 
% % Plot alat
% alat = zeros(Nsim,1);
% for i = 1:Nsim
%     alat(i) = full(constraint.alat(simX(i,:),simU(i,:)));
% end
% figure(3);
% plot(t, alat);
% line([t(1), t(end)], [constraint.alat_min, constraint.alat_min], 'LineStyle', '--', 'Color', 'k');
% line([t(1), t(end)], [constraint.alat_max, constraint.alat_max], 'LineStyle', '--', 'Color', 'k');
% xlabel('t');
% ylabel('alat');
% xlim([t(1), t(end)]);

