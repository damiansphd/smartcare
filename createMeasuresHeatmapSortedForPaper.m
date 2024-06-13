function createMeasuresHeatmapSortedForPaper(physdata, offset, cdPatient, study)

% createMeasuresHeatmapSortedForPaper - creates the Patient/Measures
% heatmap just for study period, sorted by number of days with measures

fprintf('Creating Sorted Heatmap of Measures for Study Period\n');
fprintf('----------------------------------------------------\n');
tic

subfolder = sprintf('Plots/%s', study);

if ismember(study, {'SC', 'TM'})
    studyduration = 184;
elseif ismember(study, {'CL'})
    studyduration = 184;
elseif ismember(study, {'BR', 'AC'})
    studyduration = max(physdata.ScaledDateNum);
else
    fprintf('**** Unknown Study ****');
    return;
end

% get the date scaling offset for each patient
%patientoffsets = getPatientOffsets(physdata);

if ismember(study, {'SC'})
    
    alldataset       = physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum'});
    pdcountallmtable = varfun(@max, alldataset, 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
    pcountallmtable  = varfun(@max, pdcountallmtable(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
    totdays          = sum(pcountallmtable.max_ScaledDateNum);
    totmeas          = sum(pdcountallmtable.GroupCount);
    
    fprintf('All Measures\n');
    fprintf('------------\n');
    fprintf('\n');  
    meastype   = 'All';
    filttype   = 'All';
    datafilter = {''};
    bccolor    = [0 0.4470 0.7410];
    tickrange  = [0, 2500, 5000, 7500];
    ticklabels = {'0', '2,500', '5,000', '7,500'};
    dataset       = physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);

    
    fprintf('\n');
    fprintf('Active Measures\n');
    fprintf('---------------\n');
    fprintf('\n');
    meastype   = 'Active';
    filttype   = 'Exc';
    datafilter = {'ActivityRecording'};
    bccolor    = [0.4940 0.1840 0.5560];
    tickrange  = [0, 2500, 5000, 7500];
    ticklabels = {'0', '2,500', '5,000', '7,500'};
    dataset       = physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);


    fprintf('\n');
    fprintf('Core Measures\n');
    fprintf('-------------\n');
    fprintf('\n');     
    meastype   = 'Core';
    filttype   = 'Inc';
    datafilter = {'CoughRecording', 'LungFunctionRecording', 'O2SaturationRecording', 'PulseRateRecording', 'WellnessRecording'};
    bccolor    = [0.8500 0.3250 0.0980];
    tickrange  = [0, 2500, 5000, 7500, 10000, 12500];
    ticklabels = {'0', '2,500', '5,000', '7,500', '10,000', '12,500'};
    dataset       = physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);

                                    
    fprintf('\n');
    fprintf('Passive Measures\n');
    fprintf('----------------\n');
    fprintf('\n');     
    meastype   = 'Passive';
    filttype   = 'Inc';
    datafilter = {'ActivityRecording'};
    bccolor    = [0.9290 0.6940 0.1250];
    tickrange  = [0, 10000, 20000];
    ticklabels = {'0', '10,000', '20,000'};
    dataset       = physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);                                
    
    
    fprintf('\n');
    fprintf('Mandatory Measures\n');
    fprintf('------------------\n');
    fprintf('\n');     
    meastype   = 'Mandatory';
    filttype   = 'Inc';
    datafilter = {'ActivityRecording', 'CoughRecording', 'LungFunctionRecording', 'O2SaturationRecording', 'PulseRateRecording', 'WeightRecording', 'WellnessRecording'};
    bccolor    = [0.6350 0.0780 0.1840];
    tickrange  = [0, 2500, 5000, 7500];
    ticklabels = {'0', '2,500', '5,000', '7,500'};
    dataset       = physdata(physdata.ScaledDateNum < (studyduration + 1), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);                 
    
elseif ismember(study, {'BR', 'AC'})
    
    alldataset       = physdata(~ismember(physdata.RecordingType, {'LungFunctionRecording'}), {'SmartCareID','ScaledDateNum'});
    pdcountallmtable = varfun(@max, alldataset, 'GroupingVariables', {'SmartCareID', 'ScaledDateNum'});
    pcountallmtable  = varfun(@max, pdcountallmtable(:,{'SmartCareID', 'ScaledDateNum'}), 'GroupingVariables', {'SmartCareID'});
    totdays          = sum(pcountallmtable.max_ScaledDateNum);
    totmeas          = sum(pdcountallmtable.GroupCount);
    
    fprintf('All Measures\n');
    fprintf('------------\n');
    fprintf('\n');  
    meastype   = 'All';
    filttype   = 'All';
    datafilter = {''};
    bccolor    = [0 0.4470 0.7410];
    tickrange  = [0, 5000, 10000, 15000, 20000];
    ticklabels = {'0', '5,000', '10,000', '15,000', '20,000'};
    dataset       = physdata(~ismember(physdata.RecordingType, {'LungFunctionRecording'}), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);

    
    fprintf('\n');
    fprintf('Active Measures\n');
    fprintf('---------------\n');
    fprintf('\n');
    meastype   = 'Active';
    filttype   = 'Exc';
    datafilter = {'CalorieRecording', 'MinsAsleepRecording', 'MinsAwakeRecording', 'RestingHRRecording'};
    bccolor    = [0.4940 0.1840 0.5560];
    tickrange  = [0, 5000, 10000, 15000, 20000];
    ticklabels = {'0', '5,000', '10,000', '15,000', '20,000'};
    dataset       = physdata(~ismember(physdata.RecordingType, {'LungFunctionRecording'}), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);

    
    fprintf('\n');
    fprintf('Core Measures\n');
    fprintf('-------------\n');
    fprintf('\n');     
    meastype   = 'Core';
    filttype   = 'Inc';
    datafilter = {'CoughRecording', 'FEV1Recording', 'O2SaturationRecording', 'PulseRateRecording', 'WellnessRecording'};
    bccolor    = [0.8500 0.3250 0.0980];
    tickrange  = [0, 5000, 10000, 15000, 20000];
    ticklabels = {'0', '5,000', '10,000', '15,000', '20,000'};
    dataset       = physdata(~ismember(physdata.RecordingType, {'LungFunctionRecording'}), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);

        
    fprintf('\n');
    fprintf('Passive Measures\n');
    fprintf('----------------\n');
    fprintf('\n');     
    meastype   = 'Passive';
    filttype   = 'Inc';
    datafilter = {'CalorieRecording', 'MinsAsleepRecording', 'MinsAwakeRecording', 'RestingHRRecording'};
    bccolor    = [0.9290 0.6940 0.1250];
    tickrange  = [0, 10000, 20000];
    ticklabels = {'0', '10,000', '20,000'};
    dataset       = physdata(~ismember(physdata.RecordingType, {'LungFunctionRecording'}), {'SmartCareID','ScaledDateNum', 'RecordingType'}); 
    [pdcountmtable] = calcDataComplianceStats(dataset, totdays, totmeas, studyduration, meastype, filttype, ...
                                        datafilter, bccolor, tickrange, ticklabels, subfolder, study);                                
                                
    
end

end
