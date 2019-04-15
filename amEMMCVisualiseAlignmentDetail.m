function [sorted_interventions, max_points] = amEMMCVisualiseAlignmentDetail(amIntrNormcube, amHeldBackcube, amInterventions, meancurvemean, ...
    meancurvecount, meancurvestd, overall_pdoffset, measures, min_offset, max_offset, align_wind, nmeasures, ninterventions, ...
    run_type, ex_start, curveaveragingmethod, plotname, plotsubfolder, nlatentcurves)

% amEMMCVisualiseAlignmentDetail - wrapper around the
% amEMVisualiseAlignmentDetail to plot for each set of latent curves

for n = 1:nlatentcurves
    tmp_meancurvemean    = reshape(meancurvemean(n, :, :),    [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvecount   = reshape(meancurvecount(n, :, :),   [max_offset + align_wind - 1, nmeasures]);
    tmp_meancurvestd     = reshape(meancurvestd(n, :, :),     [max_offset + align_wind - 1, nmeasures]);
    tmp_overall_pdoffset = reshape(overall_pdoffset(n, :, :), [ninterventions, max_offset]);
    tmp_ninterventions   = sum(amInterventions.LatentCurve == n);
    tmp_idx              = amInterventions.LatentCurve == n;
    
    tmp_plotname = sprintf('%s C%d', plotname, n);
    
    [sorted_interventions, max_points] = amEMVisualiseAlignmentDetail(amIntrNormcube(tmp_idx, :, :), ... 
        amHeldBackcube(tmp_idx, :, :), amInterventions(tmp_idx, :), ...
        tmp_meancurvemean, tmp_meancurvecount, tmp_meancurvestd, tmp_overall_pdoffset, ...
        measures, min_offset, max_offset, align_wind, nmeasures, tmp_ninterventions, ...
        run_type, ex_start, curveaveragingmethod, tmp_plotname, plotsubfolder);
end

end
