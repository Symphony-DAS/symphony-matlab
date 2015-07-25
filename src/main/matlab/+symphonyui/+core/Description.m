classdef Description < handle
    
    properties
        displayName
    end
    
    methods
        
        function obj = Description()
            split = strsplit(class(obj), '.');
            obj.displayName = symphonyui.ui.util.humanize(split{end});
        end
        
    end
    
end

