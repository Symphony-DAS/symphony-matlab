classdef Presenter < handle
    
    properties
        view
    end
    
    methods
        
        function obj = Presenter()
        end
        
        function viewDidLoad(obj)
%             % Restore figure position.
%             pref = [strrep(class(obj), '.', '_') '_Position'];
%             if ispref('SymphonyUI', pref)
%                 set(obj.figureHandle, 'Position', getpref('SymphonyUI', pref));
%             end
        end
        
        function onSelectedClose(obj, ~, ~)
%             % Save figure position.
%             pref = [strrep(class(obj), '.', '_') '_Position'];
%             setpref('SymphonyUI', pref, get(obj.figureHandle, 'Position'));
            
            obj.view.close();
        end
        
    end
    
end

