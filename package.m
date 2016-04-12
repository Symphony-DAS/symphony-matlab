function package(skipTests)
    if nargin < 1
        skipTests = false;
    end
    
    if ~skipTests
        test();
    end
    
    rootPath = fileparts(mfilename('fullpath'));
    targetPath = fullfile(rootPath, 'target');
    [~, ~] = mkdir(targetPath);
    
    addpath(genpath(fullfile(rootPath, 'lib')));
    addpath(genpath(fullfile(rootPath, 'src')));
    
    projectFile = fullfile(rootPath, 'Symphony.prj');
    
    dom = xmlread(projectFile);
    root = dom.getDocumentElement();
    config = root.getElementsByTagName('configuration').item(0);
    
    version = config.getElementsByTagName('param.version').item(0);
    version.setTextContent(symphonyui.app.App.version);
    
    % This adds a new line after each line in the XML
    %xmlwrite(projectFile, dom);
    
    domString = strrep(char(dom.saveXML(root)), 'encoding="UTF-16"', 'encoding="UTF-8"');
    fid = fopen(projectFile, 'w');
    fwrite(fid, domString);
    fclose(fid);
    
    matlab.apputil.package(projectFile);
end
