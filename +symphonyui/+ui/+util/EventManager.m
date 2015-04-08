classdef EventManager < handle
    
    properties
        listeners
    end
    
    methods
        
        function obj = EventManager()
            obj.listeners = {};
        end
        
        function l = addListener(obj, varargin)
            l = addlistener(varargin{:});
            obj.listeners{end + 1} = l;
        end
        
        function removeListener(obj, l)
            index = find(cellfun(@(c)c==l, obj.listeners));
            delete(obj.listeners{index});
            obj.listeners(index) = [];
        end
        
        function removeAllListeners(obj)
            while ~isempty(obj.listeners)
                delete(obj.listeners{1});
                obj.listeners(1) = [];
            end
        end
        
        function delete(obj)
            obj.removeAllListeners();
        end
        
    end
    
end

