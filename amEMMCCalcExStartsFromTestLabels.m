function ex_start = amEMMCCalcExStartsFromTestLabels(amLabelledInterventions, amInterventions, overall_pdoffset, ...
    max_offset, plotsubfolder, plotname, ninterventions, nlatentcurves)

% amEMMCCalcExStartsFromTestLabels - wrapper around
% calcExStartsFromTestLabels to derive the ex_start point for each set of
% latent curves

ex_start = zeros(1, nlatentcurves);

for n = 1:nlatentcurves
    tmp_overall_pdoffset = reshape(overall_pdoffset(n,:,:), [ninterventions, max_offset]);

    tmp_plotname = sprintf('%s C%d', plotname, n);
    
    ex_start(n) = calcExStartFromTestLabels(amLabelledInterventions, amInterventions, ...
        tmp_overall_pdoffset, max_offset, plotsubfolder, tmp_plotname);
end

end
