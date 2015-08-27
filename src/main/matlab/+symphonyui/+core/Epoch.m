classdef Epoch < symphonyui.core.CoreObject
    
    properties (SetAccess = private)

    end
    
    methods
        
        function obj = Epoch(identifier)
            if isa(identifier, 'Symphony.Core.Epoch')
                cobj = identifier;
            else
                cobj = Symphony.Core.Epoch(identifier);
            end
            
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function addStimulus(obj, device, stimulus)
            obj.tryCore(@()obj.cobj.Stimuli.Add(device.cobj, stimulus.cobj));
        end
        
        function addResponse(obj, device)
            obj.tryCore(@()obj.cobj.Responses.Add(device.cobj, Symphony.Core.Response()));
        end
        
        function r = getResponse(obj, device)
            cres = obj.tryCoreWithReturn(@()obj.cobj.Responses.Item(device.cobj));
            r = symphonyui.core.Response(cres);
        end
        
        function tf = hasResponse(obj, device)
            tf = obj.tryCoreWithReturn(@()obj.cobj.Responses.ContainsKey(device.cobj));
        end
        
        function addParameter(obj, name, value)
            obj.tryCore(@()obj.cobj.ProtocolParameters.Add(name, value));
        end
        
        function addKeyword(obj, keyword)
            obj.tryCore(@()obj.cobj.Keywords.Add(keyword));
        end
        
        function setBackground(obj, device, background)
            obj.tryCore(@()obj.cobj.SetBackground(device.cobj, background.cobj, device.cobj.OutputSampleRate)); 
        end
        
    end
    
end

