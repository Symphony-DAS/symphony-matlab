classdef StimulusGenerator < handle
    
    properties
    end
    
    methods
        
        function p = propertyMap(obj)
            p = containers.Map();
            meta = metaclass(obj);
            for i = 1:numel(meta.Properties)
                mpo = meta.Properties{i};
                if mpo.Abstract || mpo.Hidden || ~strcmp(mpo.GetAccess, 'public');
                    continue;
                end
                p(mpo.Name) = obj.(mpo.Name);
            end
        end
        
        function s = generate(obj)
            s = obj.generateStimulus();
        end
        
    end
    
    methods (Access = protected)
        
        function d = dictionaryFromMap(obj, map) %#ok<INUSL>
            d = NET.createGeneric('System.Collections.Generic.Dictionary', {'System.String', 'System.Object'});
            keys = map.keys;
            for i=1:numel(keys)
                k = keys{i};
                d.Add(k, map(k));
            end
        end
        
    end
    
    methods (Abstract, Access = protected)
        s = generateStimulus(obj); 
    end
    
end

