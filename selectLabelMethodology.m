function [testlabelmthd, testlabeltxt] = selectLabelMethodology()

% selectLabelMethodology - enter the gap between the end of a treatment and the
% start of the next. Used to define the list of interventions

fprintf('\n');
fprintf('1: Consensus decline start\n');
fprintf('2: Earliest decline start\n');
fprintf('\n');

stestlabelmthd = input('Enter test label methodology (1-2) ? ', 's');
testlabelmthd = str2double(stestlabelmthd);
if (isnan(testlabelmthd) || testlabelmthd < 1 || testlabelmthd > 2)
    fprintf('Invalid choice - defaulting to 1\n');
    testlabelmthd = 1;
end

if testlabelmthd == 1
    testlabeltxt = 'consensus';
elseif testlabelmthd == 2
    testlabeltxt = 'earliest';
else
    fprintf('Should not get here....\n');
    testlabelmthd = 0;
    testlabeltxt = ' ';
end

end

