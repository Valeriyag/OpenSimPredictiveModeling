function [x_dot] = plantFunctionOpenSim(t, x, controlsFuncHandle, osimModel, ...
    osimState,tp,pCoeffs)

%plantFunctionOpenSim - wraps an OpenSimModel and an OpenSimState into a 
%   function which can be passed as a input to a Matlab integrator, such as
%   ode45, or an optimization routine, such as fmin.
%
%  This function is a modified version of OpenSim's Dynamic Walking
%  Example.
%
%  x_dot = OpenSimPlantFunction(t, x, controlsFuncHandle, osimModel, 
%   osimState)
%
%
% Input:
%   t is the time at the current step
%   x is a Matlab column matrix of state values at the current step
%   controlsFuncHandle is a handle to a function which computes thecontrol
%   vector
%   osimModel is an org.opensim.Modeling.Model object 
%   osimState is an org.opensim.Modeling.State object
%
% Output:
%   x_dot is a Matlab column matrix of the derivative of the state values

import org.opensim.modeling.*;

    % Error Checking
    if(~isa(osimModel, 'org.opensim.modeling.Model'))
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\topensimModel is not type (org.opensim.modeling.Model).']);
    end
    if(~isa(osimState, 'org.opensim.modeling.State'))
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\topensimState is not type (org.opensim.modeling.State).']);
    end
    if(size(x,2) ~= 1)
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\tThe argument x is not a column matrix.']);
    end
    if(size(x,1) ~= osimState.getY().size())
        error('OpenSimPlantFunction:InvalidArgument', [...
            '\tError in OpenSimPlantFunction\n',...
            '\tThe argument x is not the same size as the state vector.',...
            'It should have %d rows.'], osimState.getY().size());
    end
%     if(~isa(controlsFunc, 'function_handle'))
%        error('OpenSimPlantFunction:InvalidArgument', [...
%             '\tError in OpenSimPlantFunction\n',...
%             '\tcontrolsFunc is not a valid function handle.']); 
%     end
    
    % Check size of controls

    % Update state with current values  
    osimState.setTime(t);
    numVar = osimState.getNY();
    for i = 0:1:numVar-1
        osimState.updY().set(i, x(i+1,1));
    end
    
    % Update the state velocity calculations
    %osimModel.computeStateVariableDerivatives(osimState);
    
    % Update model with control values if a control function is provided
    if(~isempty(controlsFuncHandle))
       controlVector = controlsFuncHandle(osimModel,osimState,tp,pCoeffs);    %Should just give it the time, not ask for it from the model 12-17-14 Mtg with Ton
       osimModel.setControls(osimState, controlVector);
%        for i = 1:osimModel.getNumControls()     %Remove?  Just for testing?  12-17-14 Mtg with Ton
%            controlValues(i) = controlVector.get(i-1);
%        end
    end
    
    % Update the derivative calculations in the State Variable
    osimModel.computeStateVariableDerivatives(osimState);
    
%     varToPassOut = arm26_AddOutValues(osimModel,osimState);
%     assignin('caller','varInBase',varToPassOut);
%     evalin('caller','varPassedOut(end+1)=varInBase;')
%     

    
    x_dot = zeros(numVar,1);
    % Set output variable to new state
    for i = 0:1:numVar-1
        x_dot(i+1,1) = osimState.getYDot().get(i);
    end
    a=1;
    
    
end
