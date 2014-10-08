function [objective,constraints]=arm26CalcObjConstraints(osimState,osimModel,motionData)
%arm26CalcObjConstraints - function calculate the constraint and objective
%   values of the arm26 model.  This function is specific to the arm26
%   model.
%
%   This function is called during the calculation of constraints and 
%   objective (see constOpenSim).
%
%   Inputs: 
%           osimState: an OpenSim state object (need not be the final) for
%               the model.
%           osimModel:  a reference to the OpenSim model
%           motionData: structure with generalized coordinate and other
%               data from integration.  See integrateOpenSimPlant.m for 
%               details.
%
%   Outputs:  
%           objective:  value (scaler) of the objective to be minimized.
%           constraints: vector with constraint values    


% Load Library
import org.opensim.modeling.*;

% Update to get to the final state
for i=2:size(motionData.data,2)
    osimState.updY().set(i-2, motionData.data(end,i));
end
osimModel.computeStateVariableDerivatives(osimState);

%massCenter = Vec3(0.0,0.0,0.0);
velocity   = Vec3(0.0,0.0,0.0);
position = Vec3(0.0,0.0,0.0);
bodySet = osimModel.getBodySet();
%bodySet.get('r_ulna_radius_hand').getMassCenter(massCenter);
massCenter=bodySet.get('r_ulna_radius_hand').getMassCenter();
simbodyEngine = osimModel.getSimbodyEngine();
simbodyEngine.getVelocity(osimState, osimModel.getBodySet().get('r_ulna_radius_hand'), massCenter, velocity);
simbodyEngine.getPosition(osimState, osimModel.getBodySet().get('r_ulna_radius_hand'), massCenter, position);

%Objective Maximize the velocity in the +y direction
objective=-velocity.get(1);  %Neg because IPOPT minimizes

% Determine Constraints

% Hand Horizontal Velocity ~0
constraints(1)=velocity.get(0);

% Hand located in front 
constraints(2)=position.get(0);

% Elbow Joint Never Hyper Extend
constraints(3)=min(motionData.data(:,3));   % This 3rd column is the elbow angle.  If the model changes, this will need to be updated.

% Dummy Constraint for troubleshooting
%constraints(4)=0;
