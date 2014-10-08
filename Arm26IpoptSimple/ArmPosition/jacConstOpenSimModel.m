function jacConst=jacConstOpenSimModel(Pv)
%jacConstOpenSimModel - function to be used in anonymous function for
%   optimizer.  Given control input matrix, the jacobian of the constraints 
%   will be calculated.
%
%jacConst=jacConstOpenSimModel(Pv)
%
%   Inputs:
%       Pv - A vector of Control Values (this is reshaped into a matrix,
%           vector is used because that it was is provided by IPOPT.
%           Vector is formated such that:
%               [C1@t0 C2@t0.. C1@t1 C2@t1.... C1@t3 C2@t3....]
%
%       Global Variables
%       m - this is a global structure with "constants" used in the
%           the analysis. m.constObjFuncName contains the name (string) 
%           of the constraints function to be used. m.h determines change
%           in control value to be used (finite differences).
%           See objOpenSimModel for details.
%
%
%   Outputs:
%       jacConst - matrix with jacobian of constraints
%           Each row is a constraint. Columns match the definition of Pv
%           


global m

display([datestr(now,13) ' Calculating Constraints Jacobian'])

%Initialize the model
m.osimModel.initSystem();

% Unflatten the controls vector to a matrix (columns are controls, rows are
% times for the spline
Pm=reshape(Pv,[],length(m.tp))';

modelResults = runOpenSimModel(m.osimModel, m.controlsFuncHandle,...
    m.timeSpan, m.integratorName, m.integratorOptions,m.tp,Pm,m.constObjFuncName);

%Using the above evaluation as a starting, get the gradient
[gradObj,gradConst]=evalGradOpenSimModel(modelResults,m.osimModel, m.controlsFuncHandle,...
    m.timeSpan, m.integratorName, m.integratorOptions,m.tp,Pm,m.constObjFuncName,m.h);

%Flatten 3dim matrix into 2 dim matrix where:
%      each row is for a constraint.  Columns match Pv
for i=1:size(gradConst,3)
    jacConst(i,:)=reshape(gradConst(:,:,i)',[],1)';
end

%Make sparse (doubtful any 0s though
jacConst=sparse(jacConst);

obj=modelResults.objective;

m.runCnt=m.runCnt+1;

display([datestr(now,13) ' Constraints Jacobian Complete' ...
    '(' num2str(m.runCnt) ')'])

%Update the bestYet
if m.bestYetValue<obj;
    m.bestYetValue=obj;
    m.bestYetIndex=m.runCnt;
end

%update the logFile
if m.saveLog
    data.functionType=4;
    data.P=Pv;
    data.modelResults=modelResults;
    data.runCnt=m.runCnt;
    data.obj=[];
    data.gradObj=[];
    data.constr=[];
    data.jacConst=jacConst;
    data.time=now;
    varName=['log' num2str(m.runCnt)];
    eval([varName '=data;']);
    save('logFile',varName, 'm','-append')
end



