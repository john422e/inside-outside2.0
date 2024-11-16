// soundMix.scd
// 7

s.meter;
s.plotTree;
~stop.();
(
Task.new( {
	// build all the synth and bus objects

	// build arrays for filenames (in data.scd) and recorders

	// 4 recorders for 4 instrument mics
	~recs = Array.fill( ~numInputs, {
		arg recorder;
		recorder = Recorder(s);
		recorder.recHeaderFormat_('wav');
		recorder.recSampleFormat_("int16");
		recorder;
	});
	s.sync;

	// buses

	/*
	5 buses per instrument:
	1. feedback
	2. sine synth
	3. piano
	4. FR? FR2?
	*/


	/*
	1. Make bus
	2. make source synth and assign to bus
	3. make houseMixer and assign bus as input
	4. make DO and assign bus as input
	*/

	"ADDING BUSSES".postln;
	// // 4 live mic buses for feedback
	~micLiveBusses = Array.fill(~numInputs, { Bus.audio(s, 1) });
	// // 4 buses for sample recordings
	~micSamplerBusses = Array.fill(~numInputs, { Bus.audio(s, 1) });
	// // 4 buses for sine synths
	~sinesBusses = Array.fill(~numInputs, { Bus.audio(s, 1) });
	//1.wait;
	// // 4 buses for piano FR playback
	~pianoBusses = Array.fill(~numInputs, { Bus.audio(s, 1) });
	s.sync;
	1.wait;

	"ADDING SOURCE SYNTHS".postln;

	// I should really be putting these in groups..... Group.new()

	// build synths and assign to buses
	~micSamplerSynths = Array.fill(~numInputs, { arg i; Synth.new(\micSampler, [\in, i + ~inputOffset, \out, ~micSamplerBusses[i]] )});
	~micLiveSynths = Array.fill(~numInputs, { arg i; Synth.new(\micLive, [\in, i + ~inputOffset, \inputGain, ~liveMicInputGain, \limiter, ~liveMicLimiter, \amp, 1.0, \gate, 0, \out, ~micLiveBusses[i]] )});
	~sineSynths = Array.fill( ~numInputs, { arg i; Synth.new(\sinBank_x, [\amp, 0, \out, ~sinesBusses[i]] )});

	s.sync;
	1.wait;

	"ADDING DOs".postln;
	// direct outs I NEED TO FIGURE THIS OUT< WHY ARE THEY ALL DUPLICATING CHANNEL ONE TO ALL FOUR CHANNELS?
	// adjust \amp here for ensemble speaker levels
	~micLiveDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~micLiveBusses[i], \amp, ~liveMicAmp, \out, i], ~micLiveSynths[i], \addAfter )});
	~sinesDOs = Array.fill(~numInputs, { arg i; Synth.after(~sineSynths[i], \directOut, [\in, ~sinesBusses[i], \amp, ~sineSynthGain, \out, i] )});

	1.wait;


	s.sync;
	~wavs = ~fieldDir.entries;
	~wavsFNs = ~fieldDir.entries.collect( { arg fn; fn.fileName });
	~cemeteryIndex = 0;
	~salemCovIndex = 1;
	~vcIndex = 2;
	~vlaIndex = 3;
	~vln1Index = 4;
	~vln2Index = 5;
	~pianoIndexes = [~vln1Index, ~vln2Index, ~vlaIndex, ~vcIndex];

	"READING IN BUFFERS".postln;
	Task{
		~pianoBufs = Array.fill(~numInputs, { arg i; Buffer.read(s, ~wavs[~pianoIndexes[i]].fullPath) });
		//~vln1Buf = Buffer.read(s, ~wavs[~vln1Index].fullPath);
		//~vln2Buf = Buffer.read(s, ~wavs[~vln2Index].fullPath);
		//~vcBuf = Buffer.read(s, ~wavs[~vcIndex].fullPath);
		//~vlaBuf = Buffer.read(s, ~wavs[~vlaIndex].fullPath);
		~cemeteryBuf = Buffer.read(s, ~wavs[~cemeteryIndex].fullPath);
		~salemCovBuf = Buffer.read(s, ~wavs[~salemCovIndex].fullPath);
		2.wait;

		"ADDING BUFFER SYNTHS".postln;
		~pianoPlayers = Array.fill(~numInputs, { arg i; Synth.new(\bufPlay_mono, [\buf, ~pianoBufs[i], \out, ~pianoBusses[i]])});
		//~vln1Player = Synth.new(\bufPlay_mono, [\buf, ~vln1Buf, \out, ~pianoBusses[0]]);
		//~vln2Player = Synth.new(\bufPlay_mono, [\buf, ~vln2Buf, \out, ~pianoBusses[1]]);
		//~vlaPlayer = Synth.new(\bufPlay_mono, [\buf, ~vlaBuf, \out, ~pianoBusses[2]]);
		//~vcPlayer = Synth.new(\bufPlay_mono, [\buf, ~vcBuf, \out, ~pianoBusses[3]]);
		~cemeteryPlayer = Synth.new(\bufPlay_stereo, [\buf, ~cemeteryBuf, \out, 4]);
		~salemCovPlayer = Synth.new(\bufPlay_stereo, [\buf, ~salemCovBuf, \amp, 3, \out, 4]);

		"DONE".postln;
		~fieldPlayers = [~cemeteryPlayer, ~salemCovPlayer];
		//~pianoBuffers = [~vln1Player, ~vln2Player, ~vlaPlayer, ~vcPlayer];
	}.start;
	s.sync;

	3.wait; // need to wait a bit here
	"ADDING PIANO DOs".postln;
	//~pianoPlayers = [~vln1Player, ~vln2Player, ~vlaPlayer, ~vcPlayer];
	~pianoDOs = Array.fill(~numInputs, { arg i; Synth.after(~pianoPlayers[i], \directOut, [\in, ~pianoBusses[i], \amp, ~pianoAmp, \out, i] )});
	//~sinesDOs = Array.fill(~numInputs, { arg i; Synth.after(~sineSynths[i], \directOut, [\in, ~sinesBusses[i], \amp, 1.0, \out, i] )});

	1.wait;
	"ADDING HOUSE MIXER".postln;
	~houseMixer = Synth.tail(s, \houseMixer, [
		\in1, ~sinesBusses[0], \in2, ~sinesBusses[1], \in3, ~sinesBusses[2], \in4, ~sinesBusses[3],
		\in5, ~micLiveBusses[0], \in6, ~micLiveBusses[1], \in7, ~micLiveBusses[2], \in8, ~micLiveBusses[3],
		\in9, ~pianoBusses[0], \in10, ~pianoBusses[1], \in11, ~pianoBusses[2], \in12, ~pianoBusses[3],
		\pan1, -1, \pan2, -0.5, \pan3, 0.5, \pan4, 1, \pan5, -1, \pan6, -0.5, \pan7, 0.5, \pan8, 1, \pan9, -1, \pan10, -0.5, \pan11, 0.5, \pan12, 1,
		\amp1, 1.0, \amp2, 1.0, \amp3, 1.0, \amp4, 1.0, \amp5, 1.0, \amp6, 1.0, \amp7, 1.0, \amp8, 1.0, \amp9, 1.0, \amp10, 1.0, \amp11, 1.0, \amp12, 1.0,
		\masterAmp, 0.5, \out, 4]);
	"READY".postln;
}).start;


)



a = Array.fill(8, { 500.rand + 100 });



~houseMixer.set(\masterAmp, 0.75);


~micLiveSynths.do( { arg synth, i; synth.set(\inputGain, ~liveMicInputGain, \limiter, ~liveMicLimiter, \amp, ~liveMicAmp)});
~micLiveSynths.do( { arg synth, i; synth.set(\out, i) });

~micLiveSynths[0];
~micLiveSynths[3];
~sineSynths[1].set(\gate, 0);
~sineSynths[2].set(\gate, 0);
~sineSynths[0].set(\gate, 0);
~sineSynths[3].set(\gate, 0);

s.freeAll;
x = Synth.new(\micLive, [\in, 0 + ~inputOffset, \inputGain, 0.0, \amp, 0, \out, 0] );
x.set(\inputGain, 0.9, \limiter, 0.03, \amp, 0.1);
x.set(\out, 0);
s.plotTree;