function package(skipTests)
    if nargin < 1
        skipTests = false;
    end
    
    if ~skipTests
        test();
    end
    addpath(genpath(fullfile('src', 'main')));
    projectFile = fullfile(fileparts(mfilename('fullpath')), 'Symphony.prj');
    
    dom = xmlread(projectFile);
    root = dom.getDocumentElement();
    config = root.getElementsByTagName('configuration').item(0);
    
    version = config.getElementsByTagName('param.version').item(0);
    version.setTextContent(symphonyui.app.App.version);
    
    % FIXME: Not sure why Matlab is including the runtime core requirement.
    products = config.getElementsByTagName('param.products.name').item(0);
    items = products.getElementsByTagName('item');
    for i = 1:items.getLength()
        item = items.item(i-1);
        if strcmp(item.getTextContent(), 'MATLAB Runtime - Core')
            products.removeChild(item);
        end
    end
    
    xmlwrite(projectFile, dom);
    
    matlab.apputil.package(projectFile);
end
