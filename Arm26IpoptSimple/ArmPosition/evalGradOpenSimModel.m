function [gradObj,gradC,gradModelResultsOut]=evalGradOpenSimModel(...
    modelResults,osimModel, controlsFuncHandle, timeSpan,...
    integratorName, integratorOptions,tp,P,constObjFuncName,h)
% evalGradOpenSimModel - evalue the gradient of the constraints and
%   objective function of an OpenSimModel.  This function is used in
%   optimizers.  Finite diference is used to calculate gradients.
%
%   An inital point is provided (modelResults) along with it's control
%   values (P).  Using finite difference with the a delta (h), gradients
%   of the constraints and the objective (constObjFuncName) are calculated.
%
%  For IPOPT, this function is wrapped in the anouynmous functions:
%       gradObjOpenSimModel and jacConstOpenSimModel
%
%   [gradObj,gradC,gradModelResultsOut]=evalGradOpenSimModel(...
%       modelResults,osimModel, controlsFuncHandle, timeSpan,...
%       integratorName, integratorOptions,tp,P,constObjFuncName,h)
%
%  Inputs:
%       modelResults: Initial Point to start gradient from 
%           (see integrateOpenSimPlant for definition)
%       controlsFunctionHandle:  A handle to model specific function that
%           contains the calculations for the OpenSim Model controls.
%       timeSpan: The time span to integrate over (see
%           IntegrateOpenSimPlant).  [0 2] will integrate from 0 to 2
%           seconds.
%       integratorName: String containg the name of the integrator to be
%           used.  For example: 'ode15s'
%       integratorOptions: Structure containing integrator options.  See
%           ode15s for examples.  
%           integratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
%       tp:  A vector of times at which the control values are provided.
%       P:  Control value Inputs into the model.  Matrix where:
%           Columns:  One column for each control (muscle) input in the
%               model.
%           Rows are the values of the control at the times in tp.  A cubic
%               spline is fit between the values for each control.
%       constObjFuncName: A handle to model specific function that
%           contains the calculations for the OpenSim Model constraint
%           values and objective.
%       h: delta value to add to controls in calculating finite differences
%
% Outputs:
%   gradObj: The gradient of the objective. This is a two dimensional
%       matrix: rows: time, columns: control
%   gradC: The jacobian of the constraints.  This is a 3 dimensional
%       matrix: rows: time, columns: control, page: constraint 


osimModel.initSystem();




numConstraints=length(modelResults.constraints);
numTime=size(P,1); %P Each Row is Time
numControls=size(P,2); %P Each Column is Control

numGrad=0;

for i=1:numTime
    for j=1:numControls
        numGrad=numGrad+1;
        
        display([datestr(now,13) ' Gradient Step ' num2str(numGrad) ...
            ' of ' num2str(numTime*numControls)])
        
        Pn=P;
        
        Pn(i,j)=Pn(i,j)+h;
        
        %Evaluate the model at P+h
        dModelResults = runOpenSimModel(osimModel, ... 
            controlsFuncHandle, timeSpan, integratorName, ...
            integratorOptions,tp,Pn, constObjFuncName);
        
        gradObj(i,j)=(dModelResults.objective - modelResults.objective)/h;
        
        
        %Calculate the jacobian of the constraints
        %3dim matrix: row(i): time, column(j) control, page(k) constraint 
        for k=1:numConstraints
            gradC(i,j,k) = (dModelResults.constraints(k) - ....
                modelResults.constraints(k))/h;
        end  
        
        %If the gradient Model results are requested, put them in a 
        %structure to be output.
        if nargout>2
           gradModelResultsOut{numGrad} = dModelResults;
        end
        
    end
end