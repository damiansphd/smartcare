

boundwindow = 10;
datacomp    = 50;

for i = 1:size(amLabIntrNew, 1)
    
    ub1 = amLabIntrNew.UpperBound1(i);
    ub2 = amLabIntrNew.UpperBound2(i);
    lb1 = amLabIntrNew.LowerBound1(i);
    lb2 = amLabIntrNew.LowerBound2(i);
    
    fprintf('Intr %3d: Bound Width = %2d : Data Completeness %5.1f', i, ub1 - lb1 + ub2 - lb2, amLabIntrNew.DataWindowCompleteness(i));
    
    if ((amLabIntrNew.DataWindowCompleteness(i) >= datacomp) ...
            && (((ub1 - lb1) + (ub2 - lb2)) <= boundwindow))
        amLabIntrNew.IncludeInTestSet(i) = 'Y';
    else
        amLabIntrNew.IncludeInTestSet(i) = 'N';
        fprintf(' ***');
    end
    fprintf('\n');

end

