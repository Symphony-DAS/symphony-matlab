classdef EpochSet < symphonyui.core.collections.TimelineEntitySet
    
    properties (SetAccess = private)
        protocolParameters
        stimulusMap
        responseMap
    end
    
    methods
        
        function obj = EpochSet(epochs)
            obj@symphonyui.core.collections.TimelineEntitySet(epochs);
        end
        
        function p = get.protocolParameters(obj)
            maps = cell(1, numel(obj.entities));
            for i = 1:numel(obj.entities)
                maps{i} = obj.entities{i}.protocolParameters;
            end
            p = obj.intersectMaps(maps);
        end
        
        function m = get.stimulusMap(obj)
            m = containers.Map();
            for i = 1:numel(obj.entities)
                epoch = obj.entities{i};
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
            for i = 1:numel(obj.entities)
                epoch = obj.entities{i};
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

