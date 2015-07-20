classdef EpochSet < symphonyui.app.EntitySet
    
    properties (SetAccess = private)
        commonProtocolParameters
        stimulusMap
        responseMap
    end
    
    methods
        
        function obj = EpochSet(epochs)
            obj@symphonyui.app.EntitySet(epochs);
        end
        
        function p = get.commonProtocolParameters(obj)
            if isempty(obj.entities)
                p = containers.Map();
                return;
            end
            
            keys = obj.entities{1}.protocolParameters.keys;
            for i = 2:numel(obj.entities)
                keys = intersect(keys, obj.entities{i}.protocolParameters.keys);
            end
            
            values = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                v = cell(1, numel(obj.entities));
                for j = 1:numel(obj.entities)
                    v{j} = obj.entities{j}.protocolParameters(k);
                end
                values{i} = v; %unique(v);
            end
            
            if isempty(keys)
                p = containers.Map();
            else
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

