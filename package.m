function package(skipTests)
    if nargin < 1
        skipTests = false;
    end
    
    if ~skipTests
        test();
    end
    root = fileparts(mfilename('fullpath'));
    matlab.apputil.package(fullfile(root, 'Symphony.prj'));
end
