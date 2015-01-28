classdef Test < symphonyui.models.Protocol
    
    properties (Constant)
        displayName = 'Test'
    end
    
    properties
        string = 'Test Stringzz'
        integer = 12
        cellArray = {'one', 'two', 'three'}
        logical = true
        matrix = [1 2 3 4 5];
        unsigned = uint8(5);
    end
    
    properties (Hidden)
        hidden1 = 'I should be hidden';
        hidden2 = 'oh no';
    end
    
    methods
        
        function p = parameters(obj)
            p = parameters@symphonyui.models.Protocol(obj);
            p.string.description = 'banana';
            p.string.displayName = 'hello world';
            p.string.category = 'wow';
        end
        
    end
    
end

