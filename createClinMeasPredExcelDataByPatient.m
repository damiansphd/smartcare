clear; close all; clc;

[studynbr, study, studyfullname] = selectStudy();

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[datamatfile, clinicalmatfile, ~] = getRawDataFilenamesForStudy(study);
[physdata, offset] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
[cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
    cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);

if ismember(study, 'SC')
    patlist = [24, 30, 32, 59, 79, 115, 140, 173, 188, 214, 215, 241];
elseif ismember(study, 'TM')
    patlist = cdPatient.ID';
else
    fprintf('Need to add patient list for other studies\n');
end

[modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(study, '',      '', 'IntrFilt', 'TGap',       '');

fprintf('Loading model run results data\n');
load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));

basedir = setBaseDir();
subfolder = 'ExcelFiles';
outputfilename = sprintf('ClinMeasPred-%s.xlsx', modelrun);

nonmeascols = 8;

outputdata = table('Size',[1 nonmeascols], ...
    'VariableTypes', {'double', 'double',        'datetime',   'double', 'double', 'double' ,           'double',   'double'     }, ...
    'VariableNames', {'ID',     'ScaledDateNum', 'Date', 'OralAB', 'IVAB',   'InterventionStart', 'CRPLevel', 'ExStartProb'});

%tempmeasures = measures(measures.Mask==1,:);
tempmeasures = measures;
mnum = size(tempmeasures,1);
mcols = nan(1,mnum);
mcols = array2table(mcols);
outputdata = [outputdata mcols];
for i = 1:mnum
    outputdata.Properties.VariableNames{i + nonmeascols} = sprintf('%s_Raw',tempmeasures.DisplayName{i});
end
outputdata = [outputdata mcols];
for i = 1:mnum
    outputdata.Properties.VariableNames{i + nonmeascols + mnum} = sprintf('%s_Smooth',tempmeasures.DisplayName{i});
end

rowtoadd = outputdata;

patientoffsets = getPatientOffsets(physdata);

for i = 1:size(cdPatient,1)
    if ismember(cdPatient.ID(i), patlist)

        fprintf('Patient %2d\n', cdPatient.ID(i));
        fprintf('----------\n');
        outputdata(1:size(outputdata,1),:) = [];
        scid = cdPatient.ID(i);
        
        tmpInterventions = amInterventions(amInterventions.SmartCareID == scid,:);

        patoffset = patientoffsets.PatientOffset(patientoffsets.SmartCareID == scid);
        minscdn = min(physdata.ScaledDateNum(physdata.SmartCareID == scid));
        %minscdt = min(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
        minscdt = datetime(offset + patoffset + minscdn - 1, 'ConvertFrom', 'datenum');
        maxscdn = max(max(physdata.ScaledDateNum(physdata.SmartCareID == scid)), max(tmpInterventions.IVScaledStopDateNum));
        %maxscdt = max(physdata.Date_TimeRecorded(physdata.SmartCareID == scid));
        maxscdt = datetime(offset + patoffset + maxscdn - 1, 'ConvertFrom', 'datenum');

        rowtoadd.ID                = scid;
        rowtoadd.OralAB            = nan;
        rowtoadd.IVAB              = nan;
        rowtoadd.InterventionStart = nan;
        rowtoadd.CRPLevel          = nan;
        rowtoadd.ExStartProb       = nan;

        for a = minscdn:maxscdn
            rowtoadd.ScaledDateNum     = a;
            outputdata = [outputdata; rowtoadd];
        end

        %outputdata.Date = [datetime(minscdt-seconds(1)):datetime(maxscdt-seconds(1))]';
        outputdata.Date = (minscdt:maxscdt)';

        
        for a = 1:size(tmpInterventions,1)
            outputdata.InterventionStart(tmpInterventions.IVScaledDateNum(a)) = 1;
            fprintf('Intervention Start: ScaledDataNum = %d, Date = %s\n', tmpInterventions.IVScaledDateNum(a), datestr(tmpInterventions.IVStartDate(a),1));
        end

        tmpCRP = cdCRP(cdCRP.ID == scid,:);
        for a = 1:size(tmpCRP,1)
            scdatenum = datenum(tmpCRP.CRPDate(a)) + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
            outputdata.CRPLevel(outputdata.ScaledDateNum==scdatenum) = tmpCRP.NumericLevel(a);
            fprintf('CRP Measure: ScaledDataNum = %d, Date = %s, Level = %d\n', scdatenum, ...
               datestr(tmpCRP.CRPDate(a),1), tmpCRP.NumericLevel(a));
        end

        tmpOralAB = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'Oral'),:);
        for a = 1:size(tmpOralAB,1)
            startdn = datenum(tmpOralAB.StartDate(a)) + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
            stopdn  = datenum(tmpOralAB.StopDate(a))  + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
            outputdata.OralAB(outputdata.ScaledDateNum >= startdn & outputdata.ScaledDateNum <= stopdn) = 1;
            fprintf('Oral AB:     ScaledDateNum %d:%d, Date = %s:%s\n', startdn, stopdn, ...
               datestr(tmpOralAB.StartDate(a),1), datestr(tmpOralAB.StopDate(a),1)) ;
        end

        tmpIVAB   = cdAntibiotics(cdAntibiotics.ID == scid & ismember(cdAntibiotics.Route, 'IV'),:);
        for a = 1:size(tmpIVAB,1)
            startdn = datenum(tmpIVAB.StartDate(a)) + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
            stopdn  = datenum(tmpIVAB.StopDate(a))  + 1 - offset - patientoffsets.PatientOffset(patientoffsets.SmartCareID==scid);
            outputdata.IVAB(outputdata.ScaledDateNum >= startdn & outputdata.ScaledDateNum <= stopdn) = 1;
            fprintf('IV AB:       ScaledDateNum %d:%d, Date = %s:%s\n', startdn, stopdn, ...
               datestr(tmpIVAB.StartDate(a),1), datestr(tmpIVAB.StopDate(a),1)) ;
        end

        for a = 1:nmeasures
            %if (measures.Mask(a) == 1)
                measurements = reshape(amDatacube(scid, minscdn:maxscdn, a), [maxscdn - minscdn + 1, 1]);
                column = sprintf('%s_Raw',measures.DisplayName{a});
                outputdata(minscdn:maxscdn, {column}) = array2table(measurements);
                column = sprintf('%s_Smooth',measures.DisplayName{a});
                %outputdata(minscdn:maxscdn, {column}) = array2table(smooth(measurements,5));
                outputdata(minscdn:maxscdn, {column}) = array2table(movmean(measurements,[2 2], 'omitnan'));
            %end
        end

        for a = 1:ninterventions
            if (amInterventions.SmartCareID(a) == scid)
                lc = amInterventions.LatentCurve(a);
                interstartdn = amInterventions.IVScaledDateNum(a);
                periodstart = interstartdn + ex_start;
                periodend = periodstart + (max_offset - 1);
                pdstart = 1;
                if periodstart < 1
                    periodstart = 1;
                    pdstart = (max_offset - 1) - (periodend - periodstart - 1);
                end
                interpd = overall_pdoffset(lc, a, pdstart:max_offset);
                outputdata.ExStartProb(periodstart:periodend) = interpd;
            end
        end

        patientsheet = sprintf('Patient %d', scid);
        writetable(outputdata,  fullfile(basedir, subfolder, outputfilename), 'Sheet', patientsheet);

        fprintf('\n');
    end
end



