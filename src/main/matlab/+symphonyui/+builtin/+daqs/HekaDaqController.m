classdef HekaDaqController < symphonyui.core.DaqController
    
    methods
        
        function obj = HekaDaqController()
            NET.addAssembly(which('HekaDAQInterface.dll'));
            NET.addAssembly(which('HekaNativeInterop.dll'));
            
            cobj = Heka.HekaDAQController(double(Heka.NativeInterop.ITCMM.USB18_ID), 0);
            obj@symphonyui.core.DaqController(cobj);
            
            Heka.HekaDAQInputStream.RegisterConverters();
            Heka.HekaDAQOutputStream.RegisterConverters();
            
            obj.tryCore(@()obj.cobj.InitHardware());
        end
        
        function delete(obj)
            obj.tryCore(@()obj.cobj.Dispose());
        end
        
    end
    
end

