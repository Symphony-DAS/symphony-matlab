classdef Note < handle
    
    properties (SetAccess = private)
        date
        text
    end
    
    methods
        
        function obj = Note(date, text)
            obj.date = date;
            obj.text = text;
        end
        
    end
    
end

