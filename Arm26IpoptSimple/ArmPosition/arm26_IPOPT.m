%arm26_IPOPT - Run Arm26 Optmization Problem with IPOPT.

%% Setup OpenSim Model

% Load Library
import org.opensim.modeling.*;

osimModelName='OpenSimModels/Arm26_Optimize.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();


%% Setup MATLAB Integrator
% Integrate plant using Matlab Integrator
timeSpan = [0 2];
integratorName = 'ode15s';
% IntegratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
integratorOptions =[];

%% Setup IPOPT

% Intial Control Values
numControls=osimModel.getNumControls();
tp=[0 1 2];
P=ones(length(tp),numControls);
P(1,:)=P(1,:)*0.1; %All controls at time 0 = 0.01
P(2,:)=P(2,:)*0.1; %All controls at Time 1 = 0.02
P(3,:)=P(3,:)*0.1; %All controls at Time 2 = 0.03
% Flatten Initial Controls Values
Po=reshape(P',1,[]);   %Convert to row vectors where c1@t0 c2@t0 .... c6@t0  c1@t1......

constObjFuncName='arm26CalcObjConstraints';  %Objective and constarint function
controlsFuncHandle = @plantControlsFunctionOpenSim;  % Controls function

% Setup needed global for storing "fixed" parameters
global m
m.osimModel=osimModel;
m.controlsFuncHandle=controlsFuncHandle;
m.timeSpan=timeSpan;
m.integratorName=integratorName;
m.integratorOptions=integratorOptions;
m.tp=tp;
m.constObjFuncName=constObjFuncName;
m.h=0.01;
m.saveLog=1;
m.runCnt=0;
m.bestYetValue=Inf;
m.bestYetIndex=[];

% Setup and Initial Log file
format='yy-mm-dd-HH-MM-SS';
logFileName=['logfile_' datestr(now,format)];
save(logFileName,'osimModelName')

% Set the IPOPT constraints
options.lb = 0.05.*ones(1,length(Po));  % Lower bound on the variables.
options.ub = 1.*ones(1,length(Po));  % Upper bound on the variables.
options.cl = [-0.001  0 0];   % Lower bounds on the constraint functions.
options.cu = [0.001 inf 3.14];   % Upper bounds on the constraint functions.

% Set the IPOPT options
options.ipopt.jac_c_constant        = 'yes';
options.ipopt.hessian_approximation = 'limited-memory';
options.ipopt.mu_strategy           = 'adaptive';
options.ipopt.tol                   = 1e-7;

% The callback functions.
funcs.objective         = @objOpenSimModel;
funcs.constraints       = @constOpenSimModel;
funcs.gradient          = @gradObjOpenSimModel;
funcs.jacobian          = @jacConstOpenSimModel;
funcs.jacobianstructure = @() sparse(ones(length(options.cl),length(Po)));





% Run IPOPT.
[x info] = ipopt(Po,funcs,options);
