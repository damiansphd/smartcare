

sumpdoffset = sum(overall_pdoffset(:, :, (min_offset+1:max_offset)), 3)';
sumpdoffset = [sumpdoffset; [1/3, 1/3, 1/3]];

projpts = zeros(size(sumpdoffset, 1), 2);

for i = 1:size(sumpdoffset, 1)
    projpts(i, 1) = (sumpdoffset(i, 2) - sumpdoffset(i, 1)) * cos(pi * (30/180));
    projpts(i, 2) = sumpdoffset(i, 3) - ((sumpdoffset(i, 1) + sumpdoffset(i, 2)) * sin(pi * (30/180)));
end

%[px, py, pz] = projection(1, 1, 1, 1, sumpdoffset(1:2, 1), sumpdoffset(1:2, 2), sumpdoffset(1:2, 3));


projpts2 = zeros(size(sumpdoffset, 1), 2);

yvect = [-1 * (2/3)^0.5, -1 * (2/3)^0.5, (2/3)^0.5];
xvect = [-1 * (1/2)^0.5, (1/2)^0.5, 0];


for i = 1:size(sumpdoffset, 1)
    projpts2(i, 1) = xvect * [sumpdoffset(i, 1) - 1/3; sumpdoffset(i, 2) - 1/3; sumpdoffset(i, 3) - 1/3];
    projpts2(i, 2) = yvect * [sumpdoffset(i, 1) - 1/3; sumpdoffset(i, 2) - 1/3; sumpdoffset(i, 3) - 1/3];
end
