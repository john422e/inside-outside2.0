
recs[chan].record(temps[chan], ~micBusses[chan], numChannels: 1);
temps = Array.fill( ~numSources, { arg i; cwd ++ "temp" ++ i.asString ++ ".wav"});


// start recording
~recs[0].record(~temps[0], ~micSamplerBuses[0], numChannels: 1);
// wait a bit
// stop recording
~recs[0].stopRecording;
// wait a tiny bit
// ping analysis server
~localHost.sendMsg('/ping', 0); // supply channel number
// turn synths off
~sineSynths[0].set(\gate, 0);
0.11.wait; // for release
~sineSynths[0].set(\freqs, ~currentData[0][1]);
~sineSynths[0].set(\freqs, ~currentData[0][1]);
~sineSynths[0].set(\amps, ~currentData[0][0]); // set
~sineSynths[0].set(\gate, 1); // turn back on


(
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


// buses

/*
5 buses per instrument:
1. feedback
2. sine synth
3. piano
4. FR? FR2?
*/

// // 4 live mic buses for feedback
// ~micLiveBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });
// // 4 buses for sample recordings
~micSamplerBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });
// // 4 buses for sine synths
// ~sinesBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });
// // 4 buses for piano FR playback
// ~pianoBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });

// build synths and assign to buses
~micSamplerSynths = Array.fill(~numInputs, { arg i; Synth.new(\micSampler, [\in, i + ~inputOffset, \out, ~micSamplerBuses[i]] )});
~micLiveSynths = Array.fill(~numInputs, { arg i; Synth.new(\micLive, [\in, i + ~inputOffset, \inputGain, 0.0, \amp, 0, \out, i] )}); // these need to go to buses eventually

~sineSynths = Array.fill( ~numInputs, { arg i; Synth.new(\sinBank_x, [\amp, 0, \out, i] )});

// direct outs I NEED TO FIGURE THIS OUT< WHY ARE THEY ALL DUPLICATING CHANNEL ONE TO ALL FOUR CHANNELS?
// adjust \amp here for ensemble speaker levels
//~micLiveDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~micLiveBuses[i], \amp, 1.0, \out, i], addAction: \addToTail )});
//~sinesDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~sinesBuses[i], \amp, 1.0, \out, i], addAction: \addToTail )});
//~pianoDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~pianoBuses[i], \amp, 1.0, \out, i], addAction: \addToTail )});

// left here...........

~wavs = ~fieldDir.entries;
~wavsFNs = ~fieldDir.entries.collect( { arg fn; fn.fileName });
~cemeteryIndex = 0;
~salemCovIndex = 1;
~vcIndex = 2;
~vlaIndex = 3;
~vln1Index = 4;
~vln2Index = 5;

Task{
	~vln1Buf = Buffer.read(s, ~wavs[~vln1Index].fullPath);
	~vln2Buf = Buffer.read(s, ~wavs[~vln2Index].fullPath);
	~vcBuf = Buffer.read(s, ~wavs[~vcIndex].fullPath);
	~vlaBuf = Buffer.read(s, ~wavs[~vlaIndex].fullPath);
	~cemeteryBuf = Buffer.read(s, ~wavs[~cemeteryIndex].fullPath);
	~salemCovBuf = Buffer.read(s, ~wavs[~salemCovIndex].fullPath);
	2.wait;
	~vln1Player = Synth.new(\bufPlay_mono, [\buf, ~vln1Buf, \out, 0]);
	~vln2Player = Synth.new(\bufPlay_mono, [\buf, ~vln2Buf, \out, 1]);
	~vlaPlayer = Synth.new(\bufPlay_mono, [\buf, ~vlaBuf, \out, 2]);
	~vcPlayer = Synth.new(\bufPlay_mono, [\buf, ~vcBuf, \out, 3]);
	~cemeteryPlayer = Synth.new(\bufPlay_stereo, [\buf, ~cemeteryBuf, \out, 4]);
	~salemCovPlayer = Synth.new(\bufPlay_stereo, [\buf, ~salemCovBuf, \amp, 3, \out, 4]);

	"DONE".postln;
	~fieldBuffers = [~cemeteryPlayer, ~salemCovPlayer];
	~pianoiBuffers = [~vln1Player, ~vln2Player, ~vlaPlayer, ~vcPlayer];
}.start;

)


s.freeAll;

s.meter;
s.plotTree;

// turn on
~sineSynths.do( {arg synth; synth.set(\freqs, a, \amp, ~sineSynthGain, \gate, 1); });
// turn off
~sineSynths.do( {arg synth; synth.set(\gate, 0); });



//a = Array.fill(8, { 500.rand + 100 });

s.meter;



s.sync;


s.meter;

)

~pianoRoutines[0].reset;
~pianoRoutines[0].next;
~cemeteryPlayer.set(\gate, 0);
~salemCovPlayer.set(\gate, 0);

