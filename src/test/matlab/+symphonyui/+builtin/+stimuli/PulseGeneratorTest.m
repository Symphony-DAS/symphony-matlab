classdef PulseGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = symphonyui.builtin.stimuli.PulseGenerator();
            gen.preTime = 50;
            gen.stimTime = 430.2;
            gen.tailTime = 70;
            gen.amplitude = 100;
            gen.mean = -60;
            gen.sampleRate = 100;
            gen.units = 'units';
            obj.generator = gen;
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
            
            timeToPts = @(t)(round(t / 1e3 * gen.sampleRate));
            
            prePts = timeToPts(gen.preTime);
            stimPts = timeToPts(gen.stimTime);
            tailPts = timeToPts(gen.tailTime);
            
            [q, u] = stim.getData();
            obj.verifyEqual(length(q), prePts + stimPts + tailPts);
            obj.verifyEveryDoubleElementEqualTo(q(1:prePts), gen.mean);
            obj.verifyEveryDoubleElementEqualTo(q(prePts+1:prePts+stimPts), gen.amplitude + gen.mean);
            obj.verifyEveryDoubleElementEqualTo(q(prePts+stimPts+1:end), gen.mean);
            obj.verifyEqual(u, gen.units);
        end
        
        function testRegenerate(obj)
            stim = obj.generator.generate();
            obj.verifyStimulusRegenerates(stim);
        end
        
    end
    
end

