function gradObj=gradObjOpenSimModel(Pv)
%gradObjOpenSimModel - function to be used in anonymous function for
%   optimizer.  Given control input matrix, the gradient of the objective for
%   the control inputs will be calculated
%
%gradObj=gradObjOpenSimModel(Pv)
%
%   Inputs:
%       Pv - A verctor of Control Values (this is reshaped into a matrix,
%           vector is used because that it was is provided by IPOPT).
%           Vector is formated such that:
%               [C1@t0 C2@t0.. C1@t1 C2@t1.... C1@t3 C2@t3....]
%
%   Global Variables:
%       m - this is a global structure with "constants" used in the
%           the analysis. m.constObjFuncName contains the name (string) 
%           of the constraints function to be used. m.h determines change
%           in control value to be used (finite differences).
%           See objOpenSimModel for details.
%            
%   Outputs:
%       gradObj - a vector with the gradient for each control vector.

global m

display([datestr(now,13) ' Calculating Objective Gradient'])

% Initalize the model
m.osimModel.initSystem();

% Unflatten the controls vector to a matrix (columns are controls, rows are
% times for the spline
Pm=reshape(Pv,[],length(m.tp))';

%Evalute the model (Integrate and calculate obj/const) 
modelResults = runOpenSimModel(m.osimModel, m.controlsFuncHandle,...
    m.timeSpan, m.integratorName, m.integratorOptions,m.tp,Pm,m.constObjFuncName);

%Using the above evaluation as a starting, get the gradient
gradObj=evalGradOpenSimModel(modelResults,m.osimModel, m.controlsFuncHandle,...
    m.timeSpan, m.integratorName, m.integratorOptions,m.tp,Pm,m.constObjFuncName,m.h);

gradObj=reshape(gradObj',1,[]);  % Reshape so [c1t0....c6t0 c1t1....c6t1 c1t3....c6t3]

%Get the objetive
obj=modelResults.objective;

m.runCnt=m.runCnt+1;

display([datestr(now,13) ' Objective Gradient Complete' '(' num2str(m.runCnt) ')'])

% Update bestYet 
if m.bestYetValue<obj;
    m.bestYetValue=obj;
    m.bestYetIndex=m.runCnt;
end

%Update the log file to include this step
if m.saveLog
    data.functionType=2;
    data.P=Pv;
    data.modelResults=modelResults;
    data.runCnt=m.runCnt;
    data.obj=[];
    data.gradObj=gradObj;
    data.constr=[];
    data.jacConst=[];
    data.time=now;
    varName=['log' num2str(m.runCnt)];
    eval([varName '=data;']);
    save('logFile',varName, 'm','-append')
end



