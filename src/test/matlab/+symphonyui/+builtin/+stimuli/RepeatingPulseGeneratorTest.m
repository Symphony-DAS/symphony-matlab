classdef RepeatingPulseGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            p = symphonyui.builtin.stimuli.RepeatingPulseGenerator();
            p.preTime = 50;
            p.stimTime = 430.2;
            p.tailTime = 70;
            p.amplitude = 100;
            p.mean = -60;
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
            
            timeToPts = @(t)(round(t / 1e3 * gen.sampleRate));
            
            prePts = timeToPts(gen.preTime);
            stimPts = timeToPts(gen.stimTime);
            tailPts = timeToPts(gen.tailTime);
            
            [q, u] = stim.getData(seconds((gen.preTime + gen.stimTime + gen.tailTime) / 1000));
            obj.verifyEqual(length(q), prePts + stimPts + tailPts);
            obj.verifyEveryDoubleElementEqualTo(q(1:prePts), gen.mean);
            obj.verifyEveryDoubleElementEqualTo(q(prePts+1:prePts+stimPts), gen.amplitude + gen.mean);
            obj.verifyEveryDoubleElementEqualTo(q(prePts+stimPts+1:end), gen.mean);
            obj.verifyEqual(u, gen.units);
        end
        
        function testRegenerate(obj)
            gen = obj.generator;
            stim = gen.generate();
            obj.verifyStimulusRegenerates(stim, seconds((gen.preTime + gen.stimTime + gen.tailTime) / 1000));
        end
        
    end
    
end

