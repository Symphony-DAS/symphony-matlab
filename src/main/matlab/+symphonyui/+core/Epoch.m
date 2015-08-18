classdef Epoch < symphonyui.core.CoreObject
    
    properties (SetAccess = private)

    end
    
    methods
        
        function obj = Epoch(identifier)
            if isa(identifier, 'Symphony.Core.Epoch')
                cobj = identifier;
            else
                cobj = Symphony.Core.Epoch(identifier);
            end
            
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function setBackground(obj, device, background)
            obj.tryCore(@()obj.cobj.SetBackground(device.cobj, background.cobj, device.cobj.OutputSampleRate)); 
        end
        
    end
    
end

