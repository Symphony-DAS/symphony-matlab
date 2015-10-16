classdef StimulusGeneratorTestBase < symphonyui.TestBase
    
    properties
    end
    
    methods

        function verifyEveryDoubleElementEqualTo(obj, array, value)
            import matlab.unittest.constraints.*;
            obj.verifyThat(EveryElementOf(array), IsEqualTo(value, 'Within', AbsoluteTolerance(1e-12)));
        end
        
    end
    
end

