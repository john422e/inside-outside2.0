s.quit;

s.boot;
s.freeAll;


(
SynthDef.new( \sinOsc, {
	arg freq=440.0, amp=1.0, gate=0, out=0;
	var env, sig;

	env = EnvGen.kr(Env.asr(0.1, 1.0, 0.1), gate);

	sig = SinOsc.ar(freq) * env * amp;

	Out.ar(out, sig);
}).add;

SynthDef.new( \houseMixer, {
	arg bus1, bus1pan=1.0, bus1amp=0.5, out;
	var sig;

	sig = In.ar(bus1, 1);
	sig = Pan2.ar(sig, bus1pan, bus1amp);

	Out.ar(out, sig);
}).add;

SynthDef.new( \directOut, {
	arg bus, amp=1.0, out=0;
	var sig;

	sig = In.ar(bus, 1) * amp;
	Out.ar(out, sig);
}).add;

~instBus = Bus.audio(s, 1);
)

x = Synth.new(\sinOsc, [\out, ~instBus]);
y = Synth.new( \houseMixer, [\bus1, ~instBus, \bus1pan, 1.0, \bus1amp, 0.5, \out, 0], addAction: 'addToTail');
z = Synth.new( \directOut, [\bus, ~instBus, \out, 0], addAction: 'addToTail');

y.set(\bus1amp, 0.1);
x.set(\gate, 1);
s.quit;

/*
1. make source synth
2. output it to bus
3. make mix synth (add to tail)
4. make direct out synth (add to tail)
5. output source synth to both mix synth and direct out
*/


x.free;
y.free;
//x.set(\out, 0);
s.meter;