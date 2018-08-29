
amIntrCube = amIntrNormcube;
temp_qual = 0;

temp_meancurvedata  = meancurvedata;
temp_meancurvesum   = meancurvesum;
temp_meancurvecount = meancurvecount;
temp_meancurvemean  = meancurvemean;
temp_meancurvestd   = meancurvestd;

temp_meancurvedata2  = meancurvedata;
temp_meancurvesum2   = meancurvesum;
temp_meancurvecount2 = meancurvecount;
temp_meancurvemean2  = meancurvemean;
temp_meancurvestd2   = meancurvestd;

for i=1:ninterventions
    [temp_meancurvedata, temp_meancurvesum, temp_meancurvecount, temp_meancurvemean, temp_meancurvestd] = amEMRemoveFromMean(temp_meancurvedata, temp_meancurvesum, ...
        temp_meancurvecount, temp_meancurvemean, temp_meancurvestd, overall_pdoffset, amIntrCube, amInterventions.Offset(i), i, ...
        max_offset, align_wind, nmeasures);
    
    temp_qual = temp_qual + amEMCalcObjFcn(temp_meancurvemean, temp_meancurvestd, amIntrCube, measures.Mask, normstd, ...
        hstg, i, amInterventions.Offset(i), max_offset, align_wind, nmeasures, 0, sigmamethod, smoothingmethod);
    
    fprintf('Intervention %d, qual = %.4f\n', i, temp_qual);
    
    [temp_meancurvedata, temp_meancurvesum, temp_meancurvecount, temp_meancurvemean, temp_meancurvestd] = amEMAddToMean(temp_meancurvedata, temp_meancurvesum, ...
        temp_meancurvecount, temp_meancurvemean, temp_meancurvestd, overall_pdoffset, amIntrCube, amInterventions.Offset(i), i, ...
        max_offset, align_wind, nmeasures);
end
