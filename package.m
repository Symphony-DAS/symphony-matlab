function package()
    test();
    root = fileparts(mfilename('fullpath'));
    matlab.apputil.package(fullfile(root, 'symphony.prj'));
end

