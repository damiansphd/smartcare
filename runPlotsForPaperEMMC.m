clear; close all; clc;

% other models to potentially add
% sig4 version (although zero offset start is infinity
% vEM with bet random start from 3 or 4

fprintf('Run Plots For Paper\n');
fprintf('\n');
fprintf('Choose plot to run\n');
fprintf('----------------------\n');
fprintf(' 0: Paper Figure 0 - Heatmap\n');
fprintf(' 1: Paper Figure 1 - Clinical and Home Measures\n');
fprintf(' 2: Paper Figure 2 - Early and Late Exacerbations\n');
fprintf(' 3: Paper Figure 3 - Typical profile of an exacerbation\n');
fprintf(' 4: Paper Figure 4 - Sub-population decline curve profiles with examples\n');
fprintf(' 5: Paper Figure 5a - <n/a - done in illustrator>\n');
fprintf(' 6: Paper Figure 5b - p-Values of correlations\n');
fprintf(' 7: Paper Figure 5c - Interventions over time\n');
fprintf(' 8: Slides - histogram of variable time to treatment\n');
fprintf(' 9: Paper Figure 5c alt - Interventions over time no filtering\n');
fprintf('10: Paper Figure 1B - Number of interventions histogram\n');
fprintf('11: Modulator therapy - reduction in intervention frequency\n');
fprintf('12: Plot Variables vs Intr Signal\n');

fprintf('\n');
npaperplots = 12;
srunfunction = input(sprintf('Choose function (0-%d): ', npaperplots), 's');
runfunction = str2double(srunfunction);

if (isnan(runfunction) || runfunction < 0 || runfunction > npaperplots)
    fprintf('Invalid choice\n');
    runfunction = -1;
    return;
end

fprintf('\n');

basedir = setBaseDir();
subfolder = 'MatlabSavedVariables';
[studynbr, study, studyfullname] = selectStudy();
if runfunction == 0 || runfunction == 1 || runfunction == 2 || runfunction == 6 || runfunction == 10 || runfunction == 11
    fprintf('Loading raw data for study\n');
    chosentreatgap = selectTreatmentGap();
    tic
    [datamatfile, clinicalmatfile, demographicsmatfile] = getRawDataFilenamesForStudy(study);
    [physdata, offset, physdata_predateoutlierhandling] = loadAndHarmoniseMeasVars(datamatfile, subfolder, study);
    [cdPatient, cdDrugTherapy, cdMicrobiology, cdAntibiotics, cdAdmissions, cdPFT, cdCRP, ...
        cdClinicVisits, cdOtherVisits, cdEndStudy, cdHghtWght, cdMedications, cdNewMeds] = loadAndHarmoniseClinVars(clinicalmatfile, subfolder, study);
    alignmentmodelinputsfile = sprintf('%salignmentmodelinputs_gap%d.mat', study, chosentreatgap);
    fprintf('Loading alignment model inputs\n');
    load(fullfile(basedir, subfolder, alignmentmodelinputsfile), 'amInterventions','amDatacube', 'measures', 'npatients','ndays', 'nmeasures', 'ninterventions');
    ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, chosentreatgap);
    fprintf('Loading Treatment and Measures Prior info\n');
    load(fullfile(basedir, subfolder, ivandmeasuresfile), 'ivandmeasurestable');
    toc
    fprintf('\n');
end

if runfunction >= 3 && runfunction < 11
    [modelrun, modelidx, models] = amEMMCSelectModelRunFromDir(study, '',      '', 'IntrFilt', 'TGap',       '');
    tic
    fprintf('Loading output from model run\n');
    load(fullfile(basedir, subfolder, sprintf('%s.mat', modelrun)));
    predictivemodelinputsfile = sprintf('%spredictivemodelinputs.mat', study);
    if runfunction == 6 || runfunction == 7 || runfunction == 9
        fprintf('Loading Predictive Model Patient Measures Stats\n');
        load(fullfile(basedir, subfolder, predictivemodelinputsfile), 'pmPatients', 'pmPatientMeasStats', 'npatients', 'maxdays');
    end
    ivandmeasuresfile = sprintf('%sivandmeasures_gap%d.mat', study, treatgap);
    fprintf('Loading Treatment and Measures Prior info\n');
    load(fullfile(basedir, subfolder, ivandmeasuresfile), 'ivandmeasurestable');
    % default some variables for backward compatibility with prior versions
    if ~exist('animated_overall_pdoffset', 'var')
        animated_overall_pdoffset = 0;
    end
    if ~exist('isOutlier', 'var')
        isOutlier = zeros(nlatentcurves, ninterventions, align_wind, nmeasures, max_offset);
    end
    if (~exist('intrkeepidx','var'))
        intrkeepidx = true(ninterventions, 1);
    end
    if (~exist('vshift','var'))
        vshift = zeros(nlatentcurves, ninterventions, nmeasures, max_offset);
    end
    toc
    fprintf('\n');
end
    
if runfunction == 0
    fprintf('Creating sorted measures heatmap for study period\n');
    createMeasuresHeatmapSortedForPaper(physdata, offset, cdPatient, study);
elseif runfunction == 1
    fprintf('Plotting clinical and home measures\n');
    visualiseMeasuresForPaperFcn2(physdata, offset, amDatacube, cdPatient, cdAntibiotics, ...
        cdCRP, cdPFT, cdNewMeds, measures, nmeasures, ndays, study);
elseif runfunction == 2
    fprintf('Plotting measures around exacerbation\n');
    visualiseExacerbationForPaperFcn3(amDatacube, amInterventions, measures, nmeasures, npatients, study);
elseif runfunction == 3
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 4; % shift by 7d mean to left of ex_start
    examplemode = 0; % no examples
    lcexamples = [];
    pcountthresh = 6;
    amEMMCPlotSuperimposedAlignedCurvesForPaper(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, ...
        nlatentcurves, pcountthresh, shiftmode, study, examplemode, lcexamples);
elseif runfunction == 4
    run_type = 'Best Alignment';
    fprintf('Plotting superimposed alignment curves - mean shift - all on one page\n');
    compactplot = true;
    shiftmode = 4; % shift by 7d mean to left of ex_start
    if ismember(study, {'SC'})
        examplemode = 1; % include examples
        lcexamples = [41, 67, 6];
    else
        examplemode = 0;
        lcexamples = [];
    end
    pcountthresh = 6;
    amEMMCPlotSuperimposedAlignedCurvesForPaper3(meancurvemean, meancurvecount, amIntrNormcube, amInterventions, normmean, normstd, ...
        measures, min_offset, max_offset, align_wind, nmeasures, run_type, ex_start, plotname, plotsubfolder, ...
        nlatentcurves, pcountthresh, shiftmode, study, examplemode, lcexamples);
elseif runfunction == 5
    fprintf('Plot being generated from Adobe Illustrator\n');
elseif runfunction == 6
    fprintf('Plotting Variables vs latent curve allocation\n');
    [pvaltable] = amEMMCPlotVariablesVsLatentCurveSetForPaper(amInterventions, pmPatients, pmPatientMeasStats, ...
        ivandmeasurestable, cdMicrobiology, cdAntibiotics, cdAdmissions, cdCRP, measures, plotname, plotsubfolder, ...
        ninterventions, nlatentcurves, scenario, randomseed, study);
elseif runfunction == 7
    fprintf('Loading Predictive Model Patient info\n');
    fprintf('Plotting interventions over time by latent curve set\n');
    plotmode = 2; % plot using absolute dates
    studymarkermode = 2; % exclude study markers
    pfiltermode = 2; % exclude patients with zero interventions;
    amEMMCPlotInterventionsByLatentCurveSetForPaper(pmPatients, amInterventions, ivandmeasurestable, ...
        npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode, studymarkermode, pfiltermode);
elseif runfunction == 8
    run_type = 'Best Alignment';
    fprintf('Plotting histogram of variable time to treatment\n');
    amEMMCPlotHistogramOfTimeToTreatForPaper(amInterventions, plotname, plotsubfolder, nlatentcurves, study);
elseif runfunction == 9
    fprintf('Loading Predictive Model Patient info\n');
    fprintf('Plotting interventions over time by latent curve set\n');
    plotmode = 2; % plot using absolute dates
    studymarkermode = 2; % exclude study markers
    pfiltermode = 1; % exclude patients with zero interventions;
    amEMMCPlotInterventionsByLatentCurveSetForPaper(pmPatients, amInterventions, ivandmeasurestable, ...
        npatients, maxdays, plotname, plotsubfolder, nlatentcurves, plotmode, studymarkermode, pfiltermode);
elseif runfunction == 10
    fprintf('Plotting histogram of mnumber of interventions\n');
    plotNbrIntrByPatient(physdata, offset, ivandmeasurestable, cdPatient, amInterventions, study);
elseif runfunction == 11
    fprintf('Modulator Therapy - analysing reduction in frequency of exacerbations\n');
    [brDTExStats, sumtable, hospsumtable] = calcExFrequencyByDT(offset, ivandmeasurestable, cdPatient, cdDrugTherapy, amInterventions, study);
elseif runfunction == 12
    fprintf('Loading latest labelled test data file\n');
    load(fullfile(basedir, subfolder, labelledinterventionsfile));
    fprintf('Plotting Variables vs Intr signal\n');
    plotVariablesVsIntrSignal(amLabelledInterventions, sprintf('Plots/%s', study), study);
else
    fprintf('Should not get here....\n');
end
    

    