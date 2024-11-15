/*
run each block once at a time:
set variables in top block and start sound server

second block make a synth

third block start a loop to go through each speaker and make white noise
*/

(
~sampleRate = 48000;
~numInputs = 4;
~numOutputs = 6;

~outputAmp = 0.05;
~susTime = 1;
~gapTime = 0.25;
~audioDevice = "Audient EVO16";

ServerOptions.devices;
o = Server.default.options;
o.numInputBusChannels = ~numInputs;
o.numOutputBusChannels = ~numOutputs;
o.sampleRate_(~sampleRate);

o.inDevice_(~audioDevice);
o.outDevice_(~audioDevice);

s.boot;
)


(
// synth for white noise
SynthDef.new( \noiseBurst, {
	arg gate=0, amp=1.0, out=0;
	var env, sig;

	env = EnvGen.kr( Env.new(levels: [0, 1, 1, 0], times: [0.1, ~susTime - 0.2, 0.1], curve: [2, 2, 2]), gate);
	sig = WhiteNoise.ar(amp) * env;
	Out.ar(out, sig);
}).add;

s.meter;
)



(
x = Synth.new(\noiseBurst);

~testing = true;

y = Task.new( {
	inf.do( {
		0.1.wait;
		if( ~testing == true ) {
			~numOutputs.do( {
				arg out;
				["output", out].postln;
				x.set(\amp, 0.01, \out, out, \gate, 1);
				~susTime.wait;
				x.set(\gate, 0);
				0.25.wait;
			});
		};
		//y.reset;
	});
});
y.start;
)

~testing;
y.pause;
y.free;
~testing = false;
~testing = true;