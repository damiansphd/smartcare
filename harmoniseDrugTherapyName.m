function [harmname] = harmoniseDrugTherapyName(rawname)

% Utility function to harmonise from the various free-form versions to a
% standardised name for each of the modulator drug therapies

% until we are live on REDCap, we need to harmonise all the variants of the
% free form text
nonlist = {'None', 'none'};
ivalist = {'Ivacaftor', 'ivacaftor'};
symlist = {'Symkevi', 'Symkevi Modulator', 'symkevi'};
orklist = {'Orkambi'};
trplist = {'Triple Therapy', 'Kaftrio', 'Kaftrio + Kalydeco', 'Modulator VX-445,tezacaftor,ivacaftor', 'Trikafta', 'Trikaftor', ...
            'Triple therapy', 'VX115 Study Trikafta open label', 'kaftrio', 'triple therapy open label trial', 'Kaftrio/Trikafta/TripleTherapy'};
        
if ismember(rawname, nonlist)
    harmname = nonlist(1);
elseif ismember(rawname, ivalist)
    harmname = ivalist(1);
elseif ismember(rawname, symlist)
    harmname = symlist(1);
elseif ismember(rawname, orklist)
    harmname = orklist(1);
elseif ismember(rawname, trplist)
    harmname = trplist(1);
else
    fprintf('**** Unknown drug therapy type ****\n');
    return
end 

end

