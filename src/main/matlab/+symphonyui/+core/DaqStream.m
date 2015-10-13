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
            if isempty(measurement)
                cm = [];
            else
                cm = measurement.cobj;
            end
            obj.cobj.SampleRate = cm;
        end
        
    end
    
end

