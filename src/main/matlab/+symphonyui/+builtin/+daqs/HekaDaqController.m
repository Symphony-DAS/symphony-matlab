classdef HekaDaqController < symphonyui.core.DaqController
    
    methods
        
        function obj = HekaDaqController()
            NET.addAssembly(which('HekaDAQInterface.dll'));
            NET.addAssembly(which('HekaNativeInterop.dll'));
            
            cobj = Heka.HekaDAQController(double(Heka.NativeInterop.ITCMM.USB18_ID), 0);
            obj@symphonyui.core.DaqController(cobj);
            
            Heka.HekaDAQInputStream.RegisterConverters();
            Heka.HekaDAQOutputStream.RegisterConverters();
            
            obj.sampleRate = symphonyui.core.Measurement(10000, 'Hz');
            obj.sampleRateType = symphonyui.core.PropertyType('denserealdouble', 'scalar', {10000, 20000, 50000});
            
            obj.tryCore(@()obj.cobj.InitHardware());
        end
        
        function delete(obj)
            obj.close();
        end
        
        function close(obj)
            obj.tryCore(@()obj.cobj.Dispose());
        end
        
        function s = getStream(obj, name)
            s = getStream@symphonyui.core.DaqController(obj, name);
            if strncmp(name, 'DIGITAL', 7)
                s = symphonyui.builtin.daqs.HekaDigitalDaqStream(s.cobj);
            end
        end
        
    end
    
end

