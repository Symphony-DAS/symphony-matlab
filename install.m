function install(skipTests)
    if nargin < 1
        skipTests = false;
    end

    package(skipTests);
    root = fileparts(mfilename('fullpath'));
    matlab.apputil.install(fullfile(root, 'target', 'Symphony.mlappinstall'));
end

