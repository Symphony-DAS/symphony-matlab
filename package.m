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
    
    % Update version number.
    version = config.getElementsByTagName('param.version').item(0);
    version.setTextContent(symphonyui.app.App.version);
    
    % Replace fullpaths with ${PROJECT_ROOT}.
    config.setAttribute('file', '${PROJECT_ROOT}\Symphony.prj');
    config.setAttribute('location', '${PROJECT_ROOT}');
    output = config.getElementsByTagName('param.output').item(0);
    output.setTextContent('${PROJECT_ROOT}\target');
    deliverable = config.getElementsByTagName('build-deliverables').item(0).getElementsByTagName('file').item(0);
    deliverable.setAttribute('location', '${PROJECT_ROOT}');
    deliverable.setTextContent('${PROJECT_ROOT}\target');
    
    % Remove unsetting the param.output.
    unsets = config.getElementsByTagName('unset').item(0);
    param = unsets.getElementsByTagName('param.output');
    if param.getLength() > 0
        unsets.removeChild(param.item(0));
    end
    
    % This adds a new line after each line in the XML
    %xmlwrite(projectFile, dom);
    
    domString = strrep(char(dom.saveXML(root)), 'encoding="UTF-16"', 'encoding="UTF-8"');
    fid = fopen(projectFile, 'w');
    fwrite(fid, domString);
    fclose(fid);
    
    matlab.apputil.package(projectFile);
end
