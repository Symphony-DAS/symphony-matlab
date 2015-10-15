classdef DirectCurrentGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            p = symphonyui.builtin.stimuli.DirectCurrentGenerator();
            p.time = 3.1;
            p.offset = -60;
            p.sampleRate = 100;
            p.units = 'units';
            obj.generator = p;
        end
        
    end
    
    methods (Test)
        
        function testGenerate(obj)
            import matlab.unittest.constraints.*;
            
            gen = obj.generator;
            stim = gen.generate();
            
            obj.verifyEqual(stim.sampleRate.quantityInBaseUnits, gen.sampleRate);
            obj.verifyEqual(stim.sampleRate.baseUnits, 'Hz');
            obj.verifyEqual(stim.units, gen.units);
            
            timeToPts = @(t)(round(t * gen.sampleRate));
            
            pts = timeToPts(gen.time);
            
            [q, u] = stim.getData();
            obj.verifyEqual(length(q), pts);
            obj.verifyEveryDoubleElementEqualTo(q, gen.offset);
            obj.verifyEqual(u, gen.units);
        end
        
        function testRegenerate(obj)
            stim = obj.generator.generate();
            obj.verifyStimulusRegenerates(stim);
        end
        
    end
    
end

