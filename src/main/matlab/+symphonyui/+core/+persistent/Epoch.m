classdef Epoch < symphonyui.core.persistent.TimelineEntity
    
    properties (SetAccess = private)
        protocolParameters
        responses
        stimuli
        backgrounds
    end
    
    methods
        
        function obj = Epoch(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end
        
        function p = get.protocolParameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters);
        end
        
        function r = get.responses(obj)
            r = obj.cellArrayFromEnumerable(obj.cobj.Responses, @symphonyui.core.persistent.Response);
        end
        
        function s = get.stimuli(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Stimuli, @symphonyui.core.persistent.Stimulus);
        end
        
        function b = get.backgrounds(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.Backgrounds, @symphonyui.core.persistent.Background);
        end
        
    end
    
end

