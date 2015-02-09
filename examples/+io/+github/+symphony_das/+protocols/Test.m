classdef Test < symphonyui.models.Protocol
    
    properties (Constant)
        displayName = 'Test'
    end
    
    properties
        % This is pretime
        preTime
        
        %% Helllo
        
        stimTime % This is stimTime
        string = 'Test Stringzz'
        string2 = 'This should be the rig name'
        integer = 12
        cellArray = {'one', 'two', 'three'}
        logical = true
        logical2 = false
        matrix = [1 2 3 4 5]
        twodMatrix = [1 2 3; 4 5 6]
        unsigned = uint8(5)
        logicalArray = [true false true]
    end
    
    properties (Hidden)
        hidden1 = 'I should be hidden';
        hidden2 = 'oh no';
    end
    
    methods
        
        function p = getParameters(obj)
            import symphonyui.models.*;
            
            p = getParameters@symphonyui.models.Protocol(obj);
            
            p.findByName('string').displayName = ['dname ' num2str(obj.integer)];
%             p.string.displayName = ['dname ' num2str(obj.integer)];
%             p.string.description = ['descr ' num2str(obj.integer)];
%             p.string2.value = obj.rig.displayName;
%             p.integer.isValid = obj.integer < 100;
%             p.logicalArray.type = ParameterType('logical', 'row', {'A','B','C'});
            %p.string.category = ['categ ' num2str(obj.integer)];
        end
        
    end
    
end

