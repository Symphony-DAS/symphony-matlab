% Enables an entire class to be SetObservable without SetObservable properties. Only works with assignments performed 
% outside the class's own methods.

classdef SetObservable < handle
    
    events (NotifyAccess = private)
        SetProperty
    end
    
    methods
        
        function obj = subsasgn(obj, s, varargin)
            obj = builtin('subsasgn', obj, s, varargin{:});
            if any(arrayfun(@(i)strcmp(i.type, '.'), s))
                notify(obj, 'SetProperty');
            end
        end
        
    end
    
end

