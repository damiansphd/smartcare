


rng(2)

count = 0
for i = 1:10000
    x = rand;
    if x <= 0.01
        fprintf('%d: %f\n',i, x);
        count = count + 1;
    end
end
fprintf('Count is %d\n', count);



