function test(package)
    if nargin < 1
        package = 'symphonyui';
    end
    
    rootPath = fileparts(mfilename('fullpath'));
    
    addpath(genpath(fullfile(rootPath, 'lib')));
    addpath(genpath(fullfile(rootPath, 'src')));
    
    suite = matlab.unittest.TestSuite.fromPackage(package, 'IncludingSubpackages', true);
    results = run(suite);
    
    failed = sum([results.Failed]);
    if failed > 0
        error([num2str(failed) ' test(s) failed!']);
    end
end

