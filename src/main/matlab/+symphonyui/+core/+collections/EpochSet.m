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
            p = containers.Map();
            if isempty(obj.entities)
                return;
            end
            
            keys = obj.entities{1}.protocolParameters.keys;
            for i = 2:numel(obj.entities)
                keys = intersect(keys, obj.entities{i}.protocolParameters.keys);
            end
            
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                v = {};
                for j = 1:numel(obj.entities)
                    p = obj.entities{j}.protocolParameters(k);
                    if ~any(cellfun(@(c)isequal(c, p), v))
                        v{end + 1} = p; %#ok<AGROW>
                    end
                end
                if numel(v) == 1
                    values{i} = v{1};
                else
                    values{i} = v;
                end
            end
            
            if ~isempty(keys)
                p = containers.Map(keys, values);
            end
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

