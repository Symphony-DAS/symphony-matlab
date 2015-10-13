classdef Epoch < symphonyui.core.CoreObject
    
    properties
        waitForTrigger
        shouldBePersisted
    end
    
    properties (SetAccess = private)
        duration
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
        
        function addDirectCurrentStimulus(obj, device, measurement, duration, sampleRate)
            g = symphonyui.builtin.stimuli.DirectCurrentGenerator();
            g.offset = measurement.quantity;
            g.units = measurement.displayUnits;
            g.time = duration;
            g.sampleRate = sampleRate;
            obj.addStimulus(device, g.generate());
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
        
        function tf = get.waitForTrigger(obj)
            tf = obj.cobj.WaitForTrigger;
        end
        
        function set.waitForTrigger(obj, tf)
            obj.cobj.WaitForTrigger = tf;
        end
        
        function tf = get.shouldBePersisted(obj)
            tf = obj.cobj.ShouldBePersisted;
        end
        
        function set.shouldBePersisted(obj, tf)
            obj.cobj.ShouldBePersisted = tf;
        end
        
        function d = get.duration(obj)
            cdur = obj.cobj.Duration;
            if cdur.IsNone()
                d = seconds(inf);
            else
                d = obj.durationFromTimeSpan(cdur.Item2);
            end
        end
        
    end
    
end

