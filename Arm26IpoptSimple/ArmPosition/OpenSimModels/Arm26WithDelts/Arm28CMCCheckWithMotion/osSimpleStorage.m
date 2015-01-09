function osSimpleStorage(fileName,resultsName,columnNames,data,inDegrees)


% resultsName={'results name'};
% fileName='stop3.txt';
% inDegrees=1;
% data=magic(4)/1.3;
% columnNames={'a','b','c','d'};


dlmwrite(fileName,resultsName,'delimiter','');
dlmwrite(fileName,'version=1','delimiter','','-append');
nR=num2str(size(data,1));
dlmwrite(fileName,['nRows=',nR],'delimiter','','-append');
nC=num2str(size(data,2));
dlmwrite(fileName,['nColumns=',nC],'delimiter','','-append');
if inDegrees
    dlmwrite(fileName,'inDegrees=yes','delimiter','','-append');
else
    dlmwrite(fileName,'inDegrees=no','delimiter','','-append');
end
dlmwrite(fileName,'endheader','delimiter','','-append');


fid = fopen(fileName,'a');
for i=1:length(columnNames)-1
    fprintf(fid, '%s\t', columnNames{i});
end
fprintf(fid, '%s\n', columnNames{i+1});
dlmwrite(fileName,data,'precision','%16f','delimiter','\t','-append')

%type(fileName)
