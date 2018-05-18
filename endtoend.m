physdata = readtable('mydata.csv');
patientid = readtable('patientid.xlsx');
physdata = sortrows(physdata,'UserName','ascend');
number = zeros(129841,1);
number = array2table(number);
physdata = [number physdata];
[a b] = size(physdata);

% manually changed Study_IDs since there was inconsistency
for i=1:a
    if isequal(physdata{i,'UserName'},cellstr('FPH0011'))
        physdata{i,'UserName'} = cellstr('FPH011');
    end
end

%make a table of dummies to be removed


dummies = {'EmemTest', 'PapBen' ,'PapworthSummer' ,'Ryan007', 'Texas', '010wessex', 'davetest', 'scguest'};

remove=zeros(a,1);
for i=a:-1:1
    ok = 0;
    for j=1:8
        if isequal(physdata{i,'UserName'},dummies(j))
            ok = 1;
        end
    end
    if ok == 1
        physdata(i,:) = [];
    end
end
%dummies removed.
[a b] = size(physdata); % new size = 129603

%matching further IDs of BRISTOL3, BRISTOL10 and leeds01253
patientid = sortrows(patientid,'Study_ID','ascend');
patientid.Patient_ID{3} = '-TKpptiCA5cASNKU0VSmx4';
patientid.Patient_ID{10} = '-Cujq-NEcld_Keu_W1-Nw5';
patientid.Patient_ID{107} = '-Q0Wf614z94DSTy6nXjyw7';

%sort both files by the ID
patientid = sortrows(patientid,'Patient_ID','ascend');
physdata = sortrows(physdata,'UserID','ascend');




pnt = 1;
for i=1:a-1
    if isequal(physdata.UserName(i),patientid.Study_ID(pnt))
        physdata.number(i) = patientid.Var3(pnt);
    end
    if isequal(physdata.UserName(i+1),patientid.Study_ID(pnt))
        i=i;
    else
       pnt = pnt + 1 ;
       if pnt == 146
            break;
       end
    end
end
physdata.number(129603) = 205;


% verify everyone got a number
for i=1:a
    if physdata.number(i) == 0
        disp(i);
        break;
    end
end
%everyone has their StudyNumber

% adding time
day = zeros(a,1);
day = table(day); 
physdata = [ day physdata ];

offset  = datetime(2015,8,5,0,0,0); % time offset
offset  = datenum(offset);
for i=1:a
    physdata.day(i) = datenum(datetime(physdata.Date_TimeRecorded(i)))-offset;
    physdata.day(i) = ceil(physdata.day(i));
end

%taking empty measurements into zeros
for i=1:a
    if isequal(physdata.RecordingType(i), cellstr('ActivityRecording'))
        if isnan(physdata.Activity_Steps(i))
            physdata.Activity_Steps(i) = 0;
        end
    elseif isequal(physdata.RecordingType(i), cellstr('CoughRecording'))
        if isnan(physdata.Rating(i))
            physdata.Rating(i) = 0;
        end
    elseif isequal(physdata.RecordingType(i), cellstr('WellnessRecording'))
        if isnan(physdata.Rating(i))
            physdata.Rating(i) = 0;
        end
    end
end
% empty measurements resolved.


%removing excess of information
physdata1 = physdata; % saving a copy just in case
physdata(:,'UserID') = [];
physdata(:,'FEV1') = [];
physdata(:,'FEV10') = [];
physdata(:,'PredictedFEV') = [];
physdata(:,'WeightInKg') = [];
physdata(:,'Calories') = [];
physdata(:,'Temp_degC_') = [];
physdata(:,'SputumSampleTaken_') = [];
physdata(:,'Activity_Points') = [];

%going after duplicates
% DUPLICATES, SCALE THE DAYS, GO 3D, LUNG FUNCTION THRESHOLD
% SPECIAL CARE FOR ACTIVITY DUPLICATES



[a b] = size(physdata) ; 
del = zeros(1,a);


physdata = sortrows(physdata,[2 4 1]);
%lungfunction duplicates
i = 1;
while i <= a-1
    pnt = 1;
    while isequal(physdata.day(i),physdata.day(i+pnt)) & isequal(physdata.number(i),physdata.number(i+pnt)) & isequal(physdata.RecordingType(i),physdata.RecordingType(i+pnt)) & isequal(physdata.RecordingType(i),cellstr('LungFunctionRecording'))
            physdata.FEV1_(i) = physdata.FEV1_(i)+physdata.FEV1_(i+pnt);
            del(i+pnt) = 1;
            pnt = pnt+1;
    end
    physdata.FEV1_(i) = physdata.FEV1_(i) / pnt;
    i=i+pnt;
end

%cough and wellness duplicates
i=1;
while i <= a-1
    pnt = 1;
    while isequal(physdata.day(i),physdata.day(i+pnt)) & isequal(physdata.number(i),physdata.number(i+pnt)) & isequal(physdata.RecordingType(i),physdata.RecordingType(i+pnt)) & ( isequal(physdata.RecordingType(i),cellstr('CoughRecording'))| isequal(physdata.RecordingType(i),cellstr('WellnessRecording')))
            physdata.Rating(i) = physdata.Rating(i)+physdata.Rating(i+pnt);
            del(i+pnt) = 1;
            pnt = pnt+1;
    end
    physdata.Rating(i) = physdata.Rating(i) / pnt;
    i=i+pnt;
end

%02Saturation
i=1;
while i <= a-1
    pnt = 1;
    while isequal(physdata.day(i),physdata.day(i+pnt)) & isequal(physdata.number(i),physdata.number(i+pnt)) & isequal(physdata.RecordingType(i),physdata.RecordingType(i+pnt))  & isequal(physdata.RecordingType(i),cellstr('O2SaturationRecording'))
            physdata.O2Saturation(i) = physdata.O2Saturation(i)+physdata.O2Saturation(i+pnt);
            del(i+pnt) = 1;
            pnt = pnt+1;
    end
    physdata.O2Saturation(i) = physdata.O2Saturation(i) / pnt;
    i=i+pnt;
end

%Pulse
i=1;
while i <= a-1
    pnt = 1;
    while isequal(physdata.day(i),physdata.day(i+pnt)) & isequal(physdata.number(i),physdata.number(i+pnt)) & isequal(physdata.RecordingType(i),physdata.RecordingType(i+pnt))  & isequal(physdata.RecordingType(i),cellstr('PulseRateRecording'))
            physdata.Pulse_BPM_(i) = physdata.Pulse_BPM_(i)+physdata.Pulse_BPM_(i+pnt);
            del(i+pnt) = 1;
            pnt = pnt+1;
    end
    physdata.Pulse_BPM_(i) = physdata.Pulse_BPM_(i) / pnt;
    i=i+pnt;
end


for i=a:-1:1
    if del(i) == 1
        physdata(i,:) = [];
    end
end

% all duplicates -Activity resolved
[a b] = size(physdata) ; 

%classify different Activity duplicates

for i=1:a
    if  isequal(physdata.RecordingType(i),cellstr('ActivityRecording'))
        x = hour(datetime(physdata.Date_TimeRecorded(i)));
        if x < 6
             physdata.day(i) = physdata.day(i)-1;
        end
    end
end % fixing times of Activity Recordings


physdata = sortrows(physdata,'FEV1_','ascend');
physdata(13297:13331,:) = []; % deleted everything bigger than 155 percent
physdata2 = physdata ; % making another save

physdata = sortrows(physdata,[2 4 1 5]);
i = 1;
cnt = 1;

%delete any measures with duplicate entries on a day
physdata = sortrows(physdata,[4 2 1]);
del = zeros(1,a);
for i=1:a-1
    pnt = 1;
    if isequal(physdata.day(i),physdata.day(i+pnt)) & isequal(physdata.number(i),physdata.number(i+pnt)) & isequal(physdata.RecordingType(i),physdata.RecordingType(i+pnt)) & isequal(physdata.RecordingType(i),cellstr('ActivityRecording'))
            del(i) = 1 ;
            del(i+1) = 1;
    end
end
for i=1:a
    if del(i) == 1
        physdata(i,:) = [];
    end
end

%looking at Activity upload times
[a b] = size(physdata);
gram = zeros(1,14369);
for i=1:14369
        x = hour(datetime(physdata.Date_TimeRecorded(i)));
        gram(i) = x ;
end
histogram(gram);

%scale the days accordingly
physdata = sortrows(physdata,[2 1]);
dayscale = zeros(1,300);
for i=1:300
    dayscale(i) = 1000;
end


for i=1:a
    day = physdata1.day(i);
    num = physdata1.number(i);
    if day < dayscale(num)
        dayscale(num) = day;
    end
end
for i=1:a
    physdata.day(i) = physdata.day(i) - dayscale(physdata.number(i))+1;
end
%the work ends here;

