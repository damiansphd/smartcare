% need to call this script during the execution of alignmentmodel on apr
% data to find diffs

basedir = setBaseDir();
mlsubfolder = 'MatlabSavedVariables';
olddatafile = 'amdata_20240202.mat';
load(fullfile(basedir, mlsubfolder, olddatafile));

maxdays = 178;
intrids = amInterventions.SmartCareID;

fprintf('Checking for differences in normmean\n');
fprintf('------------------------------------------\n');
for i = 1:size(intrids, 1)
    for m = 1:nmeasures
        if ~isequaln(normmean(i, m), normmean_20240202(i, m))
           fprintf('%2d:%2d(%12s): **** Diff **** Feb: %.4f, Apr: %.4f\n', amInterventions.SmartCareID(i), measures.Index(m), measures.DisplayName{m}, normmean_20240202(i, m), normmean(i, m));
        end
    end
    fprintf('\n');
end

fprintf('Checking for differences in normstd\n');
fprintf('------------------------------------------\n');
for i = 1:size(intrids, 1)
    for m = 1:nmeasures
        if ~isequaln(normstd(i, m), normstd_20240202(i, m))
           fprintf('%2d:%2d(%12s): **** Diff **** Feb: %.4f, Apr: %.4f\n', amInterventions.SmartCareID(i), measures.Index(m), measures.DisplayName{m}, normstd_20240202(i, m), normstd(i, m));
        end
    end
    fprintf('\n');
end

fprintf('Checking for differences in amDatacube\n');
fprintf('--------------------------------------\n');
for i = 1:size(intrids, 1)
    for m = 1:nmeasures
        for d = 1:maxdays
            if isequaln(amDatacube(amInterventions.SmartCareID(i), d, m), amDatacube_20240202(amInterventions.SmartCareID(i), d, m))
               %fprintf('%2d: %12s: %3d: amDatacube matches between Feb and Apr\n', amInterventions.SmartCareID(i), measures.DisplayName{m}, d);
            else
               fprintf('%2d:%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', amInterventions.SmartCareID(i), measures.Index(m), measures.DisplayName{m}, d, amDatacube_20240202(amInterventions.SmartCareID(i), d, m), amDatacube(amInterventions.SmartCareID(i), d, m));
            end
        end
    end
    fprintf('\n');
end

maxdays = 49;
fprintf('Checking for differences in amIntrDatacube\n');
fprintf('------------------------------------------\n');
for i = 1:size(intrids, 1)
    for m = 1:nmeasures
        for d = 1:maxdays
            if ~isequaln(amIntrDatacube(i, d, m), amIntrDatacube_20240202(i, d, m))
               fprintf('%2d:%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', amInterventions.SmartCareID(i), measures.Index(m), measures.DisplayName{m}, d, amIntrDatacube_20240202(i, d, m), amIntrDatacube(i, d, m));
            end
        end
    end
    fprintf('\n');
end

maxdays = 49;
fprintf('Checking for differences in amIntrNormcube\n');
fprintf('------------------------------------------\n');
for i = 1:size(intrids, 1)
    for m = 1:nmeasures
        for d = 1:maxdays
            if ~isequaln(amIntrNormcube(i, d, m), amIntrNormcube_20240202(i, d, m))
               fprintf('%2d:%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', amInterventions.SmartCareID(i), measures.Index(m), measures.DisplayName{m}, d, amIntrNormcube_20240202(i, d, m), amIntrNormcube(i, d, m));
            end
        end
    end
    fprintf('\n');
end

fprintf('Checking for differences in meancurvesum\n');
fprintf('----------------------------------------\n');
if all(all(all(isnan(meancurvesum)))) && all(all(all(isnan(meancurvesum_20240202))))
    fprintf('*** Both arrays are have every element with NaN value ***\n');
end    
for m = 1:nmeasures
    for d = 1:maxdays
        if ~isequaln(meancurvesum(1, d, m), meancurvesum_20240202(1, d, m))
           fprintf('%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', measures.Index(m), measures.DisplayName{m}, d, meancurvesum_20240202(1, d, m), meancurvesum(1, d, m));
        end
    end
    
end
fprintf('\n');

fprintf('Checking for differences in meancurvesumsq\n');
fprintf('------------------------------------------\n');
if all(all(all(isnan(meancurvesumsq)))) && all(all(all(isnan(meancurvesumsq_20240202))))
    fprintf('*** Both arrays are have every element with NaN value ***\n');
end    
for m = 1:nmeasures
    for d = 1:maxdays
        if ~isequaln(meancurvesumsq(1, d, m), meancurvesumsq_20240202(1, d, m))
           fprintf('%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', measures.Index(m), measures.DisplayName{m}, d, meancurvesumsq_20240202(1, d, m), meancurvesumsq(1, d, m));
        end
    end
    
end
fprintf('\n');

fprintf('Checking for differences in meancurvecount\n');
fprintf('------------------------------------------\n');
if all(all(all(isnan(meancurvecount)))) && all(all(all(isnan(meancurvecount_20240202))))
    fprintf('*** Both arrays are have every element with NaN value ***\n');
end    
for m = 1:nmeasures
    for d = 1:maxdays
        if ~isequaln(meancurvecount(1, d, m), meancurvecount_20240202(1, d, m))
           fprintf('%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', measures.Index(m), measures.DisplayName{m}, d, meancurvecount_20240202(1, d, m), meancurvecount(1, d, m));
        end
    end
    
end
fprintf('\n');

fprintf('Checking for differences in meancurvemean\n');
fprintf('-----------------------------------------\n');
if all(all(all(isnan(meancurvemean)))) && all(all(all(isnan(meancurvemean_20240202))))
    fprintf('*** Both arrays are have every element with NaN value ***\n');
end    
for m = 1:nmeasures
    for d = 1:maxdays
        if ~isequaln(meancurvemean(1, d, m), meancurvemean_20240202(1, d, m))
           fprintf('%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', measures.Index(m), measures.DisplayName{m}, d, meancurvemean_20240202(1, d, m), meancurvemean(1, d, m));
        end
    end
    
end
fprintf('\n');


fprintf('Checking for differences in meancurvestd\n');
fprintf('----------------------------------------\n');
if all(all(all(isnan(meancurvestd)))) && all(all(all(isnan(meancurvestd_20240202))))
    fprintf('*** Both arrays are have every element with NaN value ***\n');
end    
for m = 1:nmeasures
    for d = 1:maxdays
        if ~isequaln(meancurvestd(1, d, m), meancurvestd_20240202(1, d, m))
           fprintf('%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', measures.Index(m), measures.DisplayName{m}, d, meancurvestd_20240202(1, d, m), meancurvestd(1, d, m));
        end
    end
    
end
fprintf('\n');

fprintf('Checking for differences in unaligned_profile\n');
fprintf('---------------------------------------------\n');
if all(all(all(isnan(unaligned_profile)))) && all(all(all(isnan(unaligned_profile_20240202))))
    fprintf('*** Both arrays are have every element with NaN value ***\n');
end    
for m = 1:nmeasures
    for d = 1:maxdays
        if ~isequaln(unaligned_profile(1, d, m), unaligned_profile_20240202(1, d, m))
           fprintf('%2d(%12s):%3d: **** Diff **** Feb: %.4f, Apr: %.4f\n', measures.Index(m), measures.DisplayName{m}, d, unaligned_profile_20240202(1, d, m), unaligned_profile(1, d, m));
        end
    end
    
end
fprintf('\n');
