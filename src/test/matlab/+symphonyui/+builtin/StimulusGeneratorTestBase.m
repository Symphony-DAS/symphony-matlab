classdef StimulusGeneratorTestBase < symphonyui.TestBase
    
    properties
    end
    
    methods

        function verifyEveryDoubleElementEqualTo(obj, array, value)
            import matlab.unittest.constraints.*;
            obj.verifyThat(EveryElementOf(array), IsEqualTo(value, 'Within', AbsoluteTolerance(1e-12)));
        end
        
        function verifyStimulusRegenerates(obj, stim, dur)
            if nargin < 3
                dur = stim.duration;
            end
            
            construct = str2func(stim.stimulusId);
            
            gen = construct(stim.parameters);
            rstim = gen.generate();
            
            obj.verifyEqual(rstim.parameters, stim.parameters);
            obj.verifyEqual(rstim.getData(dur), stim.getData(dur));
            obj.verifyEqual(rstim.sampleRate, stim.sampleRate);
            obj.verifyEqual(rstim.units, stim.units);
        end
        
    end
    
end

