function [physdataout] = addCalculatedFEV1percentage(physdata,cdPatient)

% addCalculatedFEV1percentage - adds a column for the calculated FEV1
% percentage based on calculated Predicted FEV1 using sex/age/height and
% the ECSC formulae

tic
fprintf('Adding column for calculated FEV1 %%age\n');
fprintf('---------------------------------------\n');

% Handle patients with more than one predicted fev value across home
% measures differently
ppredfevvals = unique(physdata(~isnan(physdata.PredictedFEV), {'SmartCareID', 'PredictedFEV'}));
pfcount = varfun(@sum, ppredfevvals(:,{'SmartCareID'}), 'GroupingVariables', {'SmartCareID'});
ppredfevmulti = pfcount.SmartCareID(pfcount.GroupCount > 1);

ppredfevvals = innerjoin(ppredfevvals, cdPatient(:,{'ID','FEV1SetAs','CalcFEV1SetAs', 'PredictedFEV1', 'CalcPredictedFEV1'}), 'LeftKeys', {'SmartCareID'}, 'RightKeys', {'ID'});
ppredfevvals.ScalingRatio = ppredfevvals.PredictedFEV ./ ppredfevvals.CalcFEV1SetAs;

pmultivaluepredfev = ppredfevvals(ismember(ppredfevvals.SmartCareID, ppredfevmulti),:);
psinglevaluepredfev = ppredfevvals(~ismember(ppredfevvals.SmartCareID, ppredfevmulti),:);

% add dummy rows for the (3) patients that have mutli values of pred fev in
% the home measures
dummyrows = psinglevaluepredfev(1:size(unique(pmultivaluepredfev.SmartCareID),1),:);
dummyrows{:,:} = 0;
dummyrows.SmartCareID = unique(pmultivaluepredfev.SmartCareID);
psinglevaluepredfev = [ psinglevaluepredfev ; dummyrows ];

% add calc FEV1SetAs, scaling factor and calculated FEV1 % to physdata
physdata = innerjoin(physdata, psinglevaluepredfev(:,{'SmartCareID', 'CalcFEV1SetAs', 'ScalingRatio'}));

% clear values from inner join for non LungFunction recording types
physdata.CalcFEV1SetAs(~ismember(physdata.RecordingType,'LungFunctionRecording')) = nan;
physdata.ScalingRatio(~ismember(physdata.RecordingType,'LungFunctionRecording')) = nan;

% now handle 3 patients (141, 187, 198) that have multiple values for
% predicted FEV1 over the course of the study period
pmulti = unique(pmultivaluepredfev.SmartCareID);
for i = 1:size(pmulti,1)
    scid = pmulti(i);
    pvals = pmultivaluepredfev(pmultivaluepredfev.SmartCareID == scid,:);
    idx = find(physdata.SmartCareID == scid & ismember(physdata.RecordingType, 'LungFunctionRecording'));
    predfev = 0;
    calcfev1setas = 0;
    scalingratio = 0;
    for a = 1:size(idx,1)
        if ~isnan(physdata.PredictedFEV(idx(a)))
            predfev = physdata.PredictedFEV(idx(a));
            calcfev1setas = pvals.CalcFEV1SetAs(pvals.PredictedFEV == predfev);
            scalingratio = pvals.ScalingRatio(pvals.PredictedFEV == predfev);
        end
        physdata.CalcFEV1SetAs(idx(a)) = calcfev1setas;
        physdata.ScalingRatio(idx(a)) = scalingratio;
    end
end

% update Calculated FEV1 %age 
physdata.CalcFEV1_ = physdata.FEV1_ .* physdata.ScalingRatio;
physdata.CalcFEV1_ = round(physdata.CalcFEV1_);

fprintf('Done\n');

toc
fprintf('\n');

physdataout = physdata;


end

