[data,columnNames,isInDegrees]=osLoadMotFile('test_states.sto');

%Get the fiberlength values from the file
fiberCnt=0;
fiberKey=strfind(columnNames,'.fiber_length');
for i=1:length(fiberKey)
    if ~isempty(fiberKey{i})
       fiberCnt=fiberCnt+1;
       fiberNames{fiberCnt}=strrep(columnNames{i},'.fiber_length','');
       muscleDb.(fiberNames{fiberCnt}).length=data(end,i);
    end
end


