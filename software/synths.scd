// synths.scd
/*
6
dependencies:
soundServer.scd
data.scd
*/

(

s.waitForBoot({
// ADD SYNTHS TO SERVER
	//s.freeAll;
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
		arg in, amp=1.0, out;
		var sig;

		sig = In.ar(in, 1) * amp;
		Out.ar(out, sig);
	}).add;

	// 3. synth for mixing buses going to house mix
	SynthDef.new( \houseMixer, { // 12 i/o mixer
		arg in1, in2, in3, in4, in5, in6, in7, in8, in9, in10, in11, in12, pan1, pan2, pan3, pan4, pan5, pan6, pan7, pan8, pan9, pan10, pan11, pan12, amp1, amp2, amp3, amp4, amp5, amp6, amp7, amp8, amp9, amp10, amp11, amp12, masterAmp=0, out=0;
		var master, sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8, sig9, sig10, sig11, sig12;

		sig1 = Pan2.ar(In.ar(in1, 1), pan1, amp1);
		sig2 = Pan2.ar(In.ar(in2, 1), pan2, amp2);
		sig3 = Pan2.ar(In.ar(in3, 1), pan3, amp3);
		sig4 = Pan2.ar(In.ar(in4, 1), pan4, amp4);
		sig5 = Pan2.ar(In.ar(in5, 1), pan5, amp5);
		sig6 = Pan2.ar(In.ar(in6, 1), pan6, amp6);
		sig7 = Pan2.ar(In.ar(in7, 1), pan7, amp7);
		sig8 = Pan2.ar(In.ar(in8, 1), pan8, amp8);
		sig9 = Pan2.ar(In.ar(in9, 1), pan9, amp9);
		sig10 = Pan2.ar(In.ar(in10, 1), pan10, amp10);
		sig11 = Pan2.ar(In.ar(in11, 1), pan11, amp11);
		sig12 = Pan2.ar(In.ar(in12, 1), pan12, amp12);

		master = Mix.ar([sig1, sig2, sig3, sig4, sig5, sig6, sig7, sig8, sig9, sig10, sig11, sig12]) * masterAmp;

		Out.ar(out, master);
	}).add;


	// 4. live mic input
	SynthDef.new( \micLive, {
		arg in=0, inputGain=0.6, limiter = 0.3, release=0.5, gate=0, amp = 1, out=0; // 0.6 is a good max for now
		var env, sig;
		// amp envelope = attack, sustain, release
		env = EnvGen.kr(Env.asr(0.5, 1.0, release ), gate );

		sig = SoundIn.ar(in, inputGain) * env;
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
		arg buf=0, rate=1, startPos=0, t_trig=1, loop=0, da=0, amp=1.0, pan=0, out=0, gate=0;
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
});
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