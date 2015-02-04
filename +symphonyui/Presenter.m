classdef Presenter < handle
    
    properties (SetAccess = private)
        view
    end
    
    properties (Access = private)
        listeners
    end
    
    methods
        
        function obj = Presenter(view)
            obj.view = view;
            obj.addListener(view, 'Shown', @obj.onViewShown);
            obj.addListener(view, 'Closing', @obj.onViewClosing);
        end
        
    end
    
    methods (Access = protected)
        
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
        
        function onViewShown(obj, ~, ~)
            
        end
        
        function onViewClosing(obj, ~, ~)
            obj.removeAllListeners();
        end
        
    end
    
end

