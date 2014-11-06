% Load Library
%run the model using OpenSim's Manager

import org.opensim.modeling.*;

osimModelName='OpenSimModels/Arm26_Optimize.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();


%% Do integration
manager = Manager(osimModel);
manager.setInitialTime(0);
manager.setFinalTime(1);
done = manager.integrate(osimState);

