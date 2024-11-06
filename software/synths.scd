// synths.scd
/*
dependencies:
soundServer.scd
data.scd
*/

(
// ADD SYNTHS TO SERVER
s.freeAll;
/*
Loudness.kr();
K2A.ar;*/

// 1. sinOsc for testing
SynthDef.new( \sinOsc, {
	arg freq=440.0, amp=1.0, gate=0, out=0;
	var env, sig;

	env = EnvGen.kr(Env.asr(0.1, 1.0, 0.1), gate);

	sig = SinOsc.ar(freq) * env * amp;

	Out.ar(out, sig);
}).add;

// 2. synth for direct output
SynthDef.new( \directOut, {
	arg bus, amp=1.0, out;
	var sig;

	sig = In.ar(bus, 1) * amp;
	Out.ar(out, sig);
}).add;

// 3. synth for mixing buses going to house mix
SynthDef.new( \houseMixer, {
	arg bus1, bus1pan=1.0, bus1amp=0.5, out;
	var sig;

	sig = In.ar(bus1, 1);
	sig = Pan2.ar(sig, bus1pan, bus1amp);

	Out.ar(out, sig);
}).add;

// 4. live mic input
SynthDef.new( \micLive, {
	arg in=0, inputGain=0.6, limiter = 0.3, amp = 1, out=0; // 0.6 is a good max for now
	var sig;
	sig = SoundIn.ar(in, inputGain);
	// add EQ
	sig = LPF.ar(sig, 1500.0, 0.7);
	sig = HPF.ar(sig, 50.0, 0.7);
	// add limiter
	sig = Limiter.ar(sig, limiter, 0.01) * amp; // this works but need to finesse?
	out = Out.ar(out, sig);
}).add;

// 5. mic sampler
SynthDef.new( \micSampler, {
	arg in=0, inputGain=1.0, out=0;
	var sig;
	sig = SoundIn.ar(in, inputGain);
	out = Out.ar(out, sig); // this will be specified as a Bus when it's in use
}).add;

// 6. sine bank
SynthDef.new( \sinBank_x, {
	arg out=0, release=0.1, amp=0.1, gate=0;
	var size=~numSines, env, sig, freqs, amps, phases;

	// initialize freq, amp, phase data
	freqs = Array.fill(size, {440} );
	amps = Array.fill(size, { 1/size } );
	phases = Array.fill(size, { arg i; i.mod(2pi) } );

	// amp envelope = attack, sustain, release
	env = EnvGen.kr(Env.asr(0.5, 1.0, release ), gate );

	// signal
	sig = DynKlang.ar ( `[ \freqs.kr(freqs).lag(0.01), \amps.kr(amps), \phases.kr(phases) ] );
	sig = sig * env * amp;
	sig = Mix.ar(sig);
	Out.ar(out, sig);
}).add;

// 7. FR playback mono

SynthDef.new(\bufPlay_mono, {
	// playback synth for single channel
	arg buf=0, rate=1, startPos=0, t_trig=1, loop=0, da=0, amp=0.7, pan=0, out=0, gate=0;
	var numChannels, env, sig;

	// mono
	numChannels = 1;

	// amp envelope = attack, sustain, release
	env = EnvGen.kr( Env.asr(0.01, 1.0, 0.01), gate );

	sig = PlayBuf.ar(1, buf, BufRateScale.ir(buf) * rate, t_trig, startPos, loop, da);
	sig = sig * amp * env;

	Out.ar(out, sig);
}).add;

// 8. FR plackback stereo

SynthDef.new(\bufPlay_stereo, {
	// playback synth for stereo
	arg buf=0, rate=1, startPos=0, t_trig=1, attack=0.01, loop=0, da=0, amp=1.0, pan=0, out=0, gate=0;
	var numChannels, env, sig;

	// stereo
	numChannels = 2;

	// amp envelope = attack, sustain, release
	env = EnvGen.kr( Env.asr(attack, 1.0, 0.01), gate );

	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, t_trig, startPos, loop, da);
	sig = sig * amp * env;

	Out.ar(out, sig);
}).add;
)





(

~instBus = Bus.audio(s, 1);

x = Synth.new(\sinOsc, [\out, ~instBus]);
y = Synth.new( \houseMixer, [\bus1, ~instBus, \bus1pan, 1.0, \bus1amp, 0.5, \out, 0], addAction: 'addToTail');
z = Synth.new( \directOut, [\bus, ~instBus, \out, 0], addAction: 'addToTail');

y.set(\bus1amp, 0.1);
x.set(\gate, 1);
x.free;
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