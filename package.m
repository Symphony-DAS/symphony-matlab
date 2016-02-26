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
    
    % Not sure why Matlab is including the runtime core requirement.
    products = config.getElementsByTagName('param.products.name').item(0);
    items = products.getElementsByTagName('item');
    commentItems = {};
    for i = 1:items.getLength()
        item = items.item(i-1);
        if strcmp(item.getTextContent(), 'MATLAB Runtime - Core')
            commentItems{end + 1} = item; %#ok<AGROW>
        end
    end
    
    for i = 1:numel(commentItems)
        item = commentItems{i};
        comment = item.getOwnerDocument().createComment(item.getTextContent());
        products.replaceChild(comment, item);
    end
    
    % This adds a new line after each line in the XML
    %xmlwrite(projectFile, dom);
    
    domString = strrep(char(dom.saveXML(root)), 'encoding="UTF-16"', 'encoding="UTF-8"');
    fid = fopen(projectFile, 'w');
    fwrite(fid, domString);
    fclose(fid);
    
    matlab.apputil.package(projectFile);
end
