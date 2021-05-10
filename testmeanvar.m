
test =  [-5:0.1:5]

testsum = sum(test);
testsum2 = sum(test .^ 2);
testcount = size(test, 2);

testmean = testsum / testcount
testvar  = testsum2/testcount - (testmean * testmean)
%testvar = (testmean * testmean) - testsum2/testcount
teststd  = testvar ^ 0.5

mean(test)
var(test, 1)
std(test, 1)

