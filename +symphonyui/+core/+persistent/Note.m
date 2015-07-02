classdef Note < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        time
        text
    end
    
    methods
        
        function obj = Note(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function t = get.time(obj)
            t = obj.datetimeFromDateTimeOffset(obj.cobj.Time);
        end
        
        function t = get.text(obj)
            t = char(obj.cobj.Text);
        end
        
    end
    
end

