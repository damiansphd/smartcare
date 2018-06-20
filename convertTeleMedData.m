function [tmPatient, tmClinicVisits, tmAdmissions, tmAntibiotics, tmCRP, tmPFT, tmphysdata] = ...
    convertTeleMedData(tmData, tmPatient, tmClinicVisits, tmAdmissions, tmAntibiotics, tmCRP, tmPFT, tmphysdata, ...
    cvrowtoadd, admrowtoadd, poabrowtoadd, ivabrowtoadd, crprowtoadd, pftrowtoadd, phrowtoadd, fileid, offset)

% convertTelemedData - converts from TelemedData format to SmartCare format

if isequal(class(tmData.CRP), 'cell')
    numlevel = str2double(regexprep(tmData.CRP, '[<>]',''));
else
    numlevel = tmData.CRP;
end
numlevel = array2table(numlevel);
numlevel.Properties.VariableNames{1} = 'NumericLevel';
tmData = [tmData numlevel];

nmeasurements = size(tmData,1);

id = tmPatient.ID(tmPatient.ID==fileid);

prioradm = {''};
priorpoab = {''};
priorivab = {''};

for i = 1:nmeasurements
    
    % Clinic Visits
    if isequal(class(tmData.Clinic),'cell')
        if (tmData.Clinic{i} == 'Y')
           cvrowtoadd.ID = id;
           cvrowtoadd.Hospital = 'PAP';
           cvrowtoadd.StudyNumber = num2str(id);
           cvrowtoadd.ClinicID = 0;
           cvrowtoadd.AttendanceDate = tmData.Date(i);
           tmClinicVisits = [tmClinicVisits; cvrowtoadd];   
           fprintf('Clinic Visit on %s\n', datestr(tmData.Date(i),29));
        end
    end
    % Hospital Admissions
    if isequal(class(tmData.Admission),'cell')
        if (ismember(tmData.Admission(i),{'Y'}) & ~ismember(tmData.Admission(i),prioradm))
            admrowtoadd.ID = id;
            admrowtoadd.Hospital = 'PAP';
            admrowtoadd.StudyNumber = num2str(id);
            admrowtoadd.HospitalAdmissionID = 0;
            admrowtoadd.Admitted = tmData.Date(i);
            fprintf('Admission started on %s\n', datestr(tmData.Date(i),29));     
        end
        if (~ismember(tmData.Admission(i),{'Y'}) & ~ismember(tmData.Admission(i),prioradm))
            admrowtoadd.Discharge = tmData.Date(i-1);
            tmAdmissions = [tmAdmissions; admrowtoadd];
            fprintf('Admission ended on %s\n', datestr(tmData.Date(i-1),29));
        end 
        prioradm = tmData.Admission(i);
    end
    
    % Oral Antibiotics
    if isequal(class(tmData.POAbx),'cell')
        if (ismember(tmData.POAbx(i),{'Y'}) & ~ismember(tmData.POAbx(i),priorpoab))
            poabrowtoadd.ID = id;
            poabrowtoadd.Hospital = 'PAP';
            poabrowtoadd.StudyNumber = num2str(id);
            poabrowtoadd.AntibioticID = 0;
            poabrowtoadd.AntibioticName = 'Not Captured';
            poabrowtoadd.Route = 'Oral';
            poabrowtoadd.HomeIV_s_ = 'No';
            poabrowtoadd.StartDate = tmData.Date(i);
            fprintf('Oral AB started on %s\n', datestr(tmData.Date(i),29));     
        end
        if (~ismember(tmData.POAbx(i),{'Y'}) & ~ismember(tmData.POAbx(i),priorpoab))
            poabrowtoadd.StopDate = tmData.Date(i-1);
            tmAntibiotics = [tmAntibiotics; poabrowtoadd];
            fprintf('Oral AB ended on %s\n', datestr(tmData.Date(i-1),29));
        end 
        priorpoab = tmData.POAbx(i);
    end
    
    % IV Antibiotics
    if isequal(class(tmData.IVAbx),'cell')
        if (ismember(tmData.IVAbx(i),{'Y'}) & ~ismember(tmData.IVAbx(i),priorivab))
            ivabrowtoadd.ID = id;
            ivabrowtoadd.Hospital = 'PAP';
            ivabrowtoadd.StudyNumber = num2str(id);
            ivabrowtoadd.AntibioticID = 0;
            ivabrowtoadd.AntibioticName = 'Not Captured';
            ivabrowtoadd.Route = 'IV';
            if isequal(class(tmData.Admission),'cell') & ismember(tmData.Admission(i),{'Y'})
                ivabrowtoadd.HomeIV_s_ = 'No';
            else
                ivabrowtoadd.HomeIV_s_ = 'Yes';
            end
            ivabrowtoadd.StartDate = tmData.Date(i);
            fprintf('IV AB started on %s\n', datestr(tmData.Date(i),29));     
        end
        if (~ismember(tmData.IVAbx(i),{'Y'}) & ~ismember(tmData.IVAbx(i),priorivab))
            ivabrowtoadd.StopDate = tmData.Date(i-1);
            if isequal(class(tmData.Admission),'cell') & ismember(tmData.Admission(i-1),{'Y'}) & ismember(ivabrowtoadd.HomeIV_s_, {'Yes'})
                   ivabrowtoadd.HomeIV_s_ = 'IP+OP';
            end
            if isequal(class(tmData.Admission),'cell') & ~ismember(tmData.Admission(i-1),{'Y'}) & ismember(ivabrowtoadd.HomeIV_s_, {'No'})
                ivabrowtoadd.HomeIV_s_ = 'IP+OP';
            end
            tmAntibiotics = [tmAntibiotics; ivabrowtoadd];
            fprintf('IV AB ended on %s\n', datestr(tmData.Date(i-1),29));
        end 
        priorivab = tmData.IVAbx(i);
    end
    
    % CRP
    if ~isnan(tmData.NumericLevel(i))
        crprowtoadd.ID = id;
        crprowtoadd.Hospital = 'PAP';
        %crprowtoadd.StudyNumber = ' ';
        crprowtoadd.StudyNumber = num2str(id);
        crprowtoadd.CRPID = 0;
        crprowtoadd.CRPDate = tmData.Date(i);
        if isequal(class(tmData.CRP), 'cell')
            crprowtoadd.Level = tmData.CRP(i);
        else
            crprowtoadd.Level = num2str(tmData.CRP(i));
        end
        crprowtoadd.Units = 'mg/L';
        if (isequal(class(tmData.POAbx),'cell') & ismember(tmData.POAbx(i),{'Y'})) | (isequal(class(tmData.IVAbx),'cell') & ismember(tmData.IVAbx(i), {'Y'}))
            crprowtoadd.PatientAntibiotics = 'On';
        else
            crprowtoadd.PatientAntibiotics = 'Off';
        end
        crprowtoadd.NumericLevel = tmData.NumericLevel(i);
        tmCRP = [tmCRP; crprowtoadd];   
        fprintf('CRP taken on %s\n', datestr(tmData.Date(i),29));
    end
    
    % PFT
    if ~isnan(tmData.FEVI_L_(i))
        pftrowtoadd.ID = id;
        pftrowtoadd.Hospital = 'PAP';
        pftrowtoadd.StudyNumber = num2str(id);
        pftrowtoadd.LungFunctionID = 0;
        pftrowtoadd.LungFunctionDate = tmData.Date(i);
        pftrowtoadd.FEV1 = tmData.FEVI_L_(i);
        pftrowtoadd.FEV1_ = tmData.FEV1___(i);
        pftrowtoadd.FVC1 = NaN;
        pftrowtoadd.FVC1_ = NaN;
        pftrowtoadd.CalcFEV1SetAs = tmPatient.CalcFEV1SetAs(tmPatient.ID==id);
        pftrowtoadd.CalcFEV1_ = round((pftrowtoadd.FEV1 / pftrowtoadd.CalcFEV1SetAs) * 100);
        tmPFT = [tmPFT; pftrowtoadd];   
        fprintf('PFT taken on %s\n', datestr(tmData.Date(i),29));
    end
    
    % measurement data
    
    % weight
    if ~isnan(tmData.weight(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'WeightRecording'};
        phrowtoadd.WeightInKg = tmData.weight(i);
        tmphysdata = [tmphysdata; phrowtoadd];
    end
    
    % FEV1
    if ~isnan(tmData.FEV1_A_(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'LungFunctionRecording'};
        phrowtoadd.FEV1 = tmData.FEV1_A_(i);
        phrowtoadd.PredictedFEV = tmPatient.CalcPredictedFEV1(tmPatient.ID == id);
        phrowtoadd.FEV1_ = round(100 * phrowtoadd.FEV1 / phrowtoadd.PredictedFEV);
        phrowtoadd.CalcFEV1SetAs = tmPatient.CalcFEV1SetAs(tmPatient.ID == id);
        phrowtoadd.CalcFEV1_ = round(100 * phrowtoadd.FEV1 / phrowtoadd.PredictedFEV);
        tmphysdata = [tmphysdata; phrowtoadd];
    end
    
    % Pulse Rate
    if ~isnan(tmData.HR_mean_(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'PulseRateRecording'};
        phrowtoadd.Pulse_BPM_ = tmData.HR_mean_(i);
        tmphysdata = [tmphysdata; phrowtoadd];
    end
    
    % O2 Saturation
    if ~isnan(tmData.SpO2_mean_(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'O2SaturationRecording'};
        phrowtoadd.O2Saturation = tmData.SpO2_mean_(i);
        tmphysdata = [tmphysdata; phrowtoadd];
    end
    
    % Activity
    if ~isnan(tmData.Steps(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'ActivityRecording'};
        phrowtoadd.Activity_Steps = tmData.Steps(i);
        tmphysdata = [tmphysdata; phrowtoadd];
    end
    
    % Cough
    if ~isnan(tmData.CoughScore(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'CoughRecording'};
        phrowtoadd.Rating = tmData.CoughScore(i) * 10;
        tmphysdata = [tmphysdata; phrowtoadd];
    end
    
    % Wellness
    if ~isnan(tmData.WellnessScore(i))
        phrowtoadd = initialiseMeasurementRow(phrowtoadd, id, tmData.Date(i), offset);
        phrowtoadd.RecordingType = {'WellnessRecording'};
        phrowtoadd.Rating = tmData.WellnessScore(i) * 10;
        tmphysdata = [tmphysdata; phrowtoadd];
    end
end


end


