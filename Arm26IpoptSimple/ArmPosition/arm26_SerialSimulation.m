%arm26_SerialSimulation - Script to test and troublshoot functions 
%   (objective, gradinet  objective, constraint, and constraint jacobian) 
%   used during IPOPT in serial fashion. 

clear
% Load Library
import org.opensim.modeling.*;

osimModelName='OpenSimModels/Arm26_Optimize.osim';
%osimModelName='OpenSimModels/Arm26_UnitsCheck.osim';
%osimModelName='OpenSimModels/OptimizationArm26_noForces.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();

% Integrate plant using Matlab Integrator
timeSpan = [0 1];
integratorName = 'ode15s';
%integratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
integratorOptions =[];

numControls=osimModel.getNumControls();
tp=[0 1 2];
P=ones(length(tp),numControls);
P(1,:)=P(1,:)*0.1; %All controls at time 0 = 0.01
P(2,:)=P(2,:)*0.1; %All controls at Time 1 = 0.02
P(3,:)=P(3,:)*0.1; %All controls at Time 2 = 0.03

constObjFuncName='arm26CalcObjConstraints';
controlsFuncHandle = @plantControlsFunctionOpenSim;
%controlsFuncHandle = [];
    
     
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

save('logFile','osimModelName')
Pv=reshape(P',1,[]);   %Convert to row vectors where c1@t0 c2@t0 .... c6@t0  c1@t1......

%obj1=objOpenSimModel(Pv);
 obj2=objOpenSimModel(Pv);
gradObj=gradObjOpenSimModel(Pv);
constr=constOpenSimModel(Pv);
jacConst=jacConstOpenSimModel(Pv);


%%
% load('logFile')
% figure
% 
% 
% for i=2:size(log2.modelResults.OutputData.data,2)
%     plot(log2.modelResults.OutputData.data(:,1),log2.modelResults.OutputData.data(:,i),'color',pcolors(i))
%     hold on
% end
    
    