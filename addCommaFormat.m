function [str] = addCommaFormat(num)
     str = arrayfun(@(x) addcommaformatscalar(x), num, 'UniformOutput', false);
end

function [str]= addcommaformatscalar(num)
     num = round(num);
     str = num2str(num);
     FIN = length(str);
     if FIN >= 4
        for i = FIN - 2: -3: 2
           str(i + 1 : end + 1) = str(i : end);
            str(i) = ',';
        end
     end
end
