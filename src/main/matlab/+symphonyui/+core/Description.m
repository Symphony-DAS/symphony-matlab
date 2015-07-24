classdef Description < handle
    
    properties
    end
    
    methods
        
        function n = getDisplayName(obj)
            split = strsplit(class(obj), '.');
            n = symphonyui.ui.util.humanize(split{end});
        end
        
    end
    
end

