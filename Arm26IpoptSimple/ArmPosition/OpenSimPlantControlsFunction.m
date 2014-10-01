function modelControls = OpenSimPlantControlsFunction(osimModel, osimState)
%OpenSimPlantControlsFunction - This function allows for the generation of
%varying control values from the optimizer.  Currently dummy values are
%being utilized.
%
%  This function is a modified version of OpenSim's Dynamic Walking
%  Example.
%
%OpenSimPlantControlsFunction
%   outVector = OpenSimPlantControlsFunction(osimModel, osimState)
%   This function computes a control vector which for the model's
%   actuators.  The current code is for use with the script
%   DesignMainStarterWithControls.m
%
% Input:
%   osimModel is an org.opensim.Modeling.Model object
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   outVector is an org.opensim.Modeling.Vector of the control values
% -----------------------------------------------------------------------


% Load Library
import org.opensim.modeling.*;

% Check Size
if(osimModel.getNumControls() < 1)
    error('OpenSimPlantControlsFunction:InvalidControls', ...
        'This model has no controls.');
end

% Get a reference to current model controls
modelControls = osimModel.updControls(osimState);

% Initialize a vector for the actuator controls
% Most actuators have a single control.  For example, muscle have a
% signal control value (excitation);
actControls = Vector(1, 0.0);

%Dummy optimizer input
tP=[0 2];
P=[0 1];

simTime=osimState.getTime();

for i=1:length(P)
    controls=spline(tP,P,simTime);
    
    % Set Actuator Controls
    actControls.set(0, controls);
    
    % Update modelControls with the new values
    osimModel.updActuators().get(i-1).addInControls(actControls, modelControls);
end

%     % Calculate the controls based on any proprty of the model or state
%     LKnee_rz = osimModel.getCoordinateSet().get('LKnee_rz').getValue(osimState);
%     LKnee_rz_u = osimModel.getCoordinateSet().get('LKnee_rz').getSpeedValue(osimState);
%
%     % Position Control to slightly flexed Knee
%     wn = 5.0;
%     kp = wn^2;
%     kv = 2*wn;
%     LKnee_rz_des = -90*pi/180;
%     val = -kv * LKnee_rz_u - kp * (LKnee_rz - LKnee_rz_des);

% Set Actuator Controls
%actControls.set(0, val);

% Update modelControls with the new values
%osimModel.updActuators().get('coordAct_LK').addInControls(actControls, modelControls);

end
