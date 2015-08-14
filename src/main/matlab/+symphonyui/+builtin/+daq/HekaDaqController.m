classdef HekaDaqController < symphonyui.core.DaqController
    
    properties
        sampleRate
    end
    
    methods
        
        function obj = HekaDaqController()
            NET.addAssembly(which('HekaDAQInterface.dll'));
            NET.addAssembly(which('HekaNativeInterop.dll'));
            
            cobj = Heka.HekaDAQController(double(Heka.NativeInterop.ITCMM.USB18_ID), 0);
            obj@symphonyui.core.DaqController(cobj);
            
            Heka.HekaDAQInputStream.RegisterConverters();
            Heka.HekaDAQOutputStream.RegisterConverters();
            
            obj.beginSetup();
        end
        
        function delete(obj)
            obj.tryCore(@()obj.cobj.Dispose());
        end
        
        function initialize(obj)
            obj.tryCore(@()obj.cobj.InitHardware());
        end
        
        function close(obj)
            obj.tryCore(@()obj.cobj.CloseHardware());
        end
        
        function m = get.sampleRate(obj)
            cm = obj.cobj.SampleRate;
            if isempty(cm)
                m = [];
            else
                m = symphonyui.core.Measurement(cm);
            end
        end
        
        function set.sampleRate(obj, measurement)
            obj.cobj.SampleRate = measurement.cobj;
        end
        
    end
    
end

