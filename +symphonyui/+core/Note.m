classdef Note < handle
    
    properties (SetAccess = private)
        text
        date
    end
    
    methods
        
        function obj = Note(text, date)
            if nargin < 2
                date = now;
            end
            
            obj.text = text;
            obj.date = date;
        end
        
    end
    
end

