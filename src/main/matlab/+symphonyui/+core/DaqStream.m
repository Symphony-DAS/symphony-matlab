classdef DaqStream < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        name
    end
    
    properties
        sampleRate
    end
    
    methods
        
        function obj = DaqStream(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function n = get.name(obj)
            n = char(obj.cobj.Name);
        end
        
        function m = get.sampleRate(obj)
            cm = obj.cobj.SampleRate;
            if isempty(cm)
                m = [];
            else
                m = symphonyui.core.Measurement(cm);
            end
        end
        
        function set.sampleRate(obj, measurement)
            obj.cobj.SampleRate = measurement.cobj;
        end
        
    end
    
end

