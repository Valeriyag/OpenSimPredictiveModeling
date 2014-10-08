% arm26_ForwardRun - Script to run the arm26 model (with default control 
%     parameters).  This model is used to check the MATLAB integrator against
%     the results from the OpenSim forward tool.

% First, import the classes from the jar file so that these can be called
% directly
import org.opensim.modeling.*

% Generate a new model object by loading the tug of war model from file
%osimModel = Model('tug_of_war_muscles_controller.osim');
osimModel = Model('OpenSimModels/Arm26_Optimize.osim');

% Set up the visualizer to show the model and simulation
osimModel.setUseVisualizer(false);

% Initializing the model
osimModel.initSystem();

%% DEFINE SOME PARAMETERS FOR THE SIMULATION

% Define the new tool object which will be run
tool = ForwardTool(); %--> to see all properties which can be set type 'methodsview(tool)'

% Define the model which the forward tool will operate on
tool.setModel(osimModel);

% Define the start and finish times for simulation
tool.setStartTime(0);
tool.setFinalTime(1);
tool.setSolveForEquilibrium(false);

% Define the name of the forward analysis
tool.setName('arm26_ForwardRun');

% Run the simulation
tool.run();  %--> rotate the view to see the tug of war simulation

