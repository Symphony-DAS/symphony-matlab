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
        
        function g = get.responses(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Responses);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.Response(c{i});
            end
        end
        
        function g = get.stimuli(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Stimuli);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.Stimulus(c{i});
            end
        end
        
        function g = get.backgrounds(obj)
            c = obj.cellArrayFromEnumerable(obj.cobj.Backgrounds);
            g = cell(1, numel(c));
            for i = 1:numel(c)
                g{i} = symphonyui.core.persistent.Background(c{i});
            end
        end
        
    end
    
end

