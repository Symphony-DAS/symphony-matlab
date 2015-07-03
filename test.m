function test(package)
    if nargin < 1
        package = 'symphonyui';
    end
    addpath(genpath(fullfile('src', 'test')));
    suite = matlab.unittest.TestSuite.fromPackage(package, 'IncludingSubpackages', true);
    run(suite);
end

