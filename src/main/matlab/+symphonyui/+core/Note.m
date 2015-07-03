classdef Note < handle
    
    properties (SetAccess = private)
        id
        text
        date % the date
    end
    
    methods
        
        function obj = Note(text, date)
            if nargin < 2
                date = now;
            end
            obj.id = char(java.util.UUID.randomUUID);
            obj.text = text;
            obj.date = date;
        end
        
        function c = char(obj)
            if isempty(obj)
                c = '';
                return;
            end
            c = sprintf('%s, ', obj.text);
            c = c(1:end-2);
        end
        
    end
    
end
