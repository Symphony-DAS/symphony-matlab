function install()
    package();
    root = fileparts(mfilename('fullpath'));
    matlab.apputil.install(fullfile(root, 'target', 'Symphony.mlappinstall'));
end

