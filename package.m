function package()
    root = fileparts(mfilename('fullpath'));
    matlab.apputil.package(fullfile(root, 'symphony.prj'));
end

