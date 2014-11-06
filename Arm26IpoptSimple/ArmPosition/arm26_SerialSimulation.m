%arm26_SerialSimulation - Script to test and troublshoot functions 
%   (objective, gradinet  objective, constraint, and constraint jacobian) 
%   used during IPOPT in serial fashion. 


%% Setup OpenSim Model

% Load Library
import org.opensim.modeling.*;

osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize.osim';

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
integratorName = 'ode23';
% IntegratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
integratorOptions =[];

%% Setup Controls
controlsFuncHandle = @plantControlsFunctionOpenSim;  % Controls function  
controlsFuncHandle = [];  % Controls function

% Initial Control Values
numControls=osimModel.getNumControls();
tp=[0 1 2];
P=ones(length(tp),numControls);


a=[	      0.05000000	      0.05000000	      0.05000000	      0.09572922	      0.10845805	      0.07009430	      0.05000000	      0.10712417];
a=0.9;
P(1,:)=P(1,:).*a; %All controls at time 0 = 0.01
P(2,:)=P(2,:).*a; %All controls at Time 1 = 0.02
P(3,:)=P(3,:).*a; %All controls at Time 2 = 0.03


% Add a prescribed controller if a controls function is not provided
if isempty(controlsFuncHandle)
    addPrescribedController;
end

% Flatten Initial Controls Values
Po=reshape(P',1,[]);   %Convert to row vectors where c1@t0 c2@t0 .... c6@t0  c1@t1......


constObjFuncName='arm26CalcObjConstraints';  %Objective and constraint function



% Setup and Initial Log file
format='yy-mm-dd-HH-MM-SS';
logFileName=['logfile_' datestr(now,format)];
save(logFileName,'osimModelName')



% Setup needed global for storing "fixed" parameters
global m
m.osimModel=osimModel;
m.controlsFuncHandle=controlsFuncHandle;
m.timeSpan=timeSpan;
m.integratorName=integratorName;
m.integratorOptions=integratorOptions;
m.tp=tp;
m.constObjFuncName=constObjFuncName;
m.h=0.00001;
m.saveLog=logFileName;  %Set to [] for no log
m.runCnt=0;
m.bestYetValue=Inf;
m.bestYetIndex=[];
m.lastPm=[];
m.lastModelResults=[];
m.lastGradObj=[];
m.lastJacConst=[];

Pv=reshape(P',1,[]);   %Convert to row vectors where c1@t0 c2@t0 .... c6@t0  c1@t1......

obj1=objOpenSimModel(Pv);
%obj2=objOpenSimModel(Pv);
%constr=constOpenSimModel(Pv);
%gradObj=gradObjOpenSimModel(Pv); 
%jacConst=jacConstOpenSimModel(Pv);


%%
% load('logFile')
% figure
% 
% 
% for i=2:size(log2.modelResults.OutputData.data,2)
%     plot(log2.modelResults.OutputData.data(:,1),log2.modelResults.OutputData.data(:,i),'color',pcolors(i))
%     hold on
% end
    
    