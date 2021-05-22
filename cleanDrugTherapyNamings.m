function out = cleanDrugTherapyNamings(str_array)
% inputs: array, output: array with cleaned drugtherapy names
    fprintf('Clean drug therapy namings.\nInitial drug therapy list:\n')
    disp(categorical(unique(str_array)));
    out = replace(str_array,["symkevi","Symkevi Modulator"],"Symkevi");
    out = replace(out,["Modulator VX-445,tezacaftor,ivacaftor"...
        ,"Kaftrio + Kalydeco","VX115 Study Trikafta open label",...
        "triple therapy open label trial","Trikafta + Kalydeco", ...
        "Triple therapy","Kaftrio","kaftrio","Trikaftor","Trikafta", ...
        ],"Triple Therapy");
    out = replace(out,"ivacaftor","Ivacaftor");
    fprintf('Cleaned drug therapy list:\n')
    Drug_therapy = categorical(unique(out)); Count = countcats(categorical(out));
    disp(table(Drug_therapy,Count))
end
