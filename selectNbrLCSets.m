function nbrlc = selectNbrLCSets()

% selectNbrLCSets - enter the number of Latent Curve Sets

snbrlc = input('Enter number of latent curve sets to run for ? ', 's');
nbrlc = str2double(snbrlc);
if (isnan(nbrlc) || nbrlc < 1 || nbrlc > 5)
    fprintf('Invalid choice - defaulting to 1\n');
    nbrlc = 1;
end
    
end

