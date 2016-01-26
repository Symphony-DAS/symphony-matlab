classdef EpochSet < symphonyui.core.persistent.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolParameters
        stimulusMap
        responseMap
    end
    
    methods
        
        function obj = EpochSet(epochs)
            obj@symphonyui.core.persistent.collections.TimelineEntitySet(epochs);
        end
        
        function m = get.protocolParameters(obj)
            if isempty(obj.objects)
                m = containers.Map();
                return;
            end
            m = obj.objects{1}.protocolParameters;
            for i = 2:numel(obj.objects)
                m = obj.intersectMaps(m, obj.objects{i}.protocolParameters);
            end
        end
        
        function m = get.stimulusMap(obj)
            m = containers.Map();
            for i = 1:numel(obj.objects)
                epoch = obj.objects{i};
                stimuli = epoch.stimuli;
                for k = 1:numel(stimuli)
                    device = stimuli{k}.device.name;
                    if ~m.isKey(device)
                        m(device) = [];
                    end
                    
                    m(device) = [m(device) stimuli(k)];
                end
            end
        end
        
        function m = get.responseMap(obj)
            m = containers.Map();
            for i = 1:numel(obj.objects)
                epoch = obj.objects{i};
                responses = epoch.responses;
                for k = 1:numel(responses)
                    device = responses{k}.device.name;
                    if ~m.isKey(device)
                        m(device) = [];
                    end
                    
                    m(device) = [m(device) responses(k)];
                end
            end
        end
        
    end
    
end

