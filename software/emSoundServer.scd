// soundServer.scd

// server settings and synthDefs, run this ___

(
o = Server.default.options;
o.numInputBusChannels = 4;
o.numOutputBusChannels = 6; // four for the quartet (0, 1, 2, 3) and two for the house (4, 5)
o.sampleRate_(48000);

ServerOptions.devices;
// use this for testing

//o.inDevice_("BlackHole 64ch");
//o.inDevice_("Soundflower (64ch)");
//o.outDevice_("BlackHole 64ch");

//o.inDevice_("MacBook Pro Microphone");
//o.outDevice_("MacBook Pro Speakers");

// use this for performance with evo 16
o.inDevice_("Audient EVO16");
o.outDevice_("Audient EVO16");

// o.inDevice_("Ensemble");
// o.outDevice_("Ensemble");

// o.inDevice_("SQ - Audio");
// o.outDevice_("SQ - Audio");
)
s.boot;
// boot synth, go to synths.scd and add synths

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
// ~micSamplerBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });
// // 4 buses for sine synths
// ~sinesBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });
// // 4 buses for piano FR playback
// ~pianoBuses = Array.fill(~numInputs, { Bus.audio(s, 1) });

// build synths and assign to buses
~micLiveSynths = Array.fill(~numInputs, { arg i; Synth.new(\micLive, [\in, i, \inputGain, 0.0, \amp, 0, \out, i] )}); // these need to go to buses eventually
//~micSamplerSynths = Array.fill(~numInputs, { arg i; Synth.new(\micSampler, [\in, i, \out, i] )});
~sineSynths = Array.fill( ~numInputs, { arg i; Synth.new(\sinBank_x, [\out, i] )});

// direct outs I NEED TO FIGURE THIS OUT< WHY ARE THEY ALL DUPLICATING CHANNEL ONE TO ALL FOUR CHANNELS?
// adjust \amp here for ensemble speaker levels
//~micLiveDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~micLiveBuses[i], \amp, 1.0, \out, i], addAction: \addToTail )});
//~sinesDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~sinesBuses[i], \amp, 1.0, \out, i], addAction: \addToTail )});
//~pianoDOs = Array.fill(~numInputs, { arg i; Synth.new(\directOut, [\in, ~pianoBuses[i], \amp, 1.0, \out, i], addAction: \addToTail )});

// left here...........



// figure out the piano synths now
)
s.freeAll;

s.meter;

~sineSynths[0];

~sineSynths[0].set(\gate, 1);
~sineSynths[0].set(\gate, 0);
~sineSynths[0].set(\out, 1);

~sineSynths[3].set(\freqs, a);

~sinesDOs[0].set(\out, 0);

~sineSynths.do( {arg synth; synth.set(\freqs, a); synth.set(\gate, 1); });
~sineSynths.do( {arg synth; synth.set(\amp, 0.005, \gate, 1); });
~sineSynths.do( {arg synth; synth.set(\gate, 0); });
// mics 1-3 at 10db preamp gain, mic 4 (cello) at 8 db

~micLiveSynths.do( { arg synth; synth.set(\inputGain, 0.9, \limiter, 0.03, \amp, 0.1) });
~micSamplerSynths.do( { arg synth; synth.free; });

a = Array.fill(8, { 500.rand + 100 });

s.meter;



// sinBank synths to analog outputs

s.sync;
(
// build audio buffers
Buffer.freeAll; // free anything that's already allocated

~pianoLeftBufs = ~readInBufs.(~pianoNotesLeftDir); // this isn't fucking working
~pianoRightBufs = ~readInBufs.(~pianoNotesRightDir);
)
s.sync;

(

// this works for some dumb reason, the ~readInBufs function is broken i don't know why
Buffer.freeAll;

// a routine to read in all the audio files
~init = Routine.new( {
	~pianoLeftBufs = ~pianoNotesLeftDir.entries.collect( {
		arg filename;
		Buffer.read(s, filename.fullPath);
	});
	s.sync;

}).play;

~init = Routine.new( {
	~pianoRightBufs = ~pianoNotesRightDir.entries.collect( {
		arg filename;
		Buffer.read(s, filename.fullPath);
	});
	s.sync;

}).play;
)

b = ~pianoNotesLeftDir.entries.collect( { arg filename; filename });
b = Buffer.read(s, b[0].fullPath);

b = Buffer.read(s, b[0].filename.fullPath);
~readInBufs = {
	// read in sound files to buffers
	// sound server must be on first
	arg dir, numChannels;
	var bufs;
	Routine.new( {
		bufs = dir.entries.collect( {
			arg filename;
			Buffer.read(s, filename.fullPath);
		});
		s.sync;
	}).play;
	s.sync;
	bufs;
};
)












~gMajIndexes = [0, 1, 2, 3, 4, 5, 6, 13, 14, 15, 16, 17, 18, 19, 20, 21, 25, 26, 27, 34, 35, 36];
~gDomIndexes = [2, 3, 5, 6, 14, 15, 16, 17, 18, 19, 20, 21, 28, 29, 30, 28, 29, 30, 34, 35, 36];
~blendedIndexes = [4, 5, 6, 7, 8, 9, 14, 15, 16, 17, 18, 19, 20, 21, 28, 29, 30, 28, 29, 30, 28, 29, 30, 34, 35, 36];

~gMajLeft = Array.fill(~gMajIndexes.size, {
	arg i;
	~pianoLeftBufs[~gMajIndexes[i]]; // return the buffer at that index
});

~gMajRight = Array.fill(~gMajIndexes.size, {
	arg i;
	~pianoRightBufs[~gMajIndexes[i]]; // return the buffer at that index
});

~gDomLeft = Array.fill(~gDomIndexes.size, {
	arg i;
	~pianoLeftBufs[~gDomIndexes[i]]; // return the buffer at that index
});

~gDomRight = Array.fill(~gDomIndexes.size, {
	arg i;
	~pianoRightBufs[~gDomIndexes[i]]; // return the buffer at that index
});

~blendedLeft = Array.fill(~blendedIndexes.size, {
	arg i;
	~pianoLeftBufs[~blendedIndexes[i]]; // return the buffer at that index
});

~blendedRight = Array.fill(~blendedIndexes.size, {
	arg i;
	~pianoRightBufs[~blendedIndexes[i]]; // return the buffer at that index
});







~cemeteryBuf = ~readInBufs.(~cemeteryDir);
~salemCovBuf = ~readInBufs.(~salemCovDir);

~pianoLeftPlayers = Array.fill(2, { arg i; Synth.new(\bufPlay_mono, [\out, i]) } ); // this will get set to outputs 0 and 1
~pianoRightPlayers = Array.fill(2, { arg i; Synth.new(\bufPlay_mono, [\out, i+2]) } ); // this will get set to outputs 2 and 3 (i+2)
~cemeteryPlayer = Synth.new(\bufPlay_stereo, [\buf, ~cemeteryBuf[0], \out, 4]);
~salemCovPlayer = Synth.new(\bufPlay_stereo, [\buf, ~salemCovBuf[1], \amp, 3, \out, 4]);
/*Routine.new( {
~pianoLeftBufs = ~pianoNotesLeftDir.entries.collect( {
arg fn;
Buffer.read(s, fn.fullPath);
});
}).play;
*/

~pianoRoutines = Array.fill(4, {
	arg i;
	if( i < 2 ) {
		Routine.new( {

			var currentBuf;
			~pianoLeftPlayers[i].set(\buf, ~pianoLeftBufs.choose, \startPos, 0, \t_trig, 1, \gate, 1);
			fork{
				Task.new( {
					~pianoWaitTime.wait; // wait before starting recording
					~recs[i].record(~temps[i], ~micSamplerBuses[i], numChannels: 1); // start recording
					~sampleDur.wait; // wait for recording
					~recs[i].stopRecording; // stop recording
					~recBufTime.wait; // wait to make sure recording saves
					~localHost.sendMsg('/ping', i); // ping local server
					~pingBufTime.wait; // give ping some time for response



					~sinSynths[i].set(\gate, 0); // turn off
					["OFF"].postln;
					0.11.wait; // for release

					~sinSynths[i].set(\freqs, ~currentData[i][1]);
					~sinSynths[i].set(\amps, ~currentData[i][0]); // set
					~sinSynths[i].set(\gate, 1); // turn back on

					~synthSusTime.wait;
					~sinSynths[i].set(\release, 4, \gate, 0); // need to reset this elsewhere for hard cuts


				});
			};


		});
	} {
		Routine.new( {
			~pianoRightPlayers[i-2].set(\buf, ~pianoRightBufs.choose, \startPos, 0, \t_trig, 1, \gate, 1);
		});
	};
});

s.sync;

// test output
~pianoLeftPlayers[[0,1].choose].set(\buf, ~pianoLeftBufs.choose, \startPos, 0, \t_trig, 1, \amp, 0.05, \gate, 1);
~pianoRightPlayers[[0,1].choose].set(\buf, ~pianoRightBufs.choose, \startPos, 0, \t_trig, 1, \amp, 0.05, \gate, 1);
});

~pianoLeftPlayers[0].set(\buf, ~pianoLeftBufs.choose, \startPos, 0, \t_trig, 1, \amp, 0.05, \gate, 1); // check this

s.meter;

)

~pianoRoutines[0].reset;
~pianoRoutines[0].next;
~cemeteryPlayer.set(\gate, 0);
~salemCovPlayer.set(\gate, 0);




//~sinSynths[0].set(\gate, 0);
//~micLiveSynths[0].set(\inputGain, 1);
//~pianoLeftPlayers[[0,1].choose].set(\buf, ~pianoLeftBufs.choose, \startPos, 0, \t_trig, 1, \gate, 1);
//~pianoRightPlayers[[0,1].choose].set(\buf, ~pianoRightBufs.choose, \startPos, 0, \t_trig, 1, \gate, 1);

//x = Synth.new(\bufPlay_mono, ~pianoLeftBufs[0]);
//x.set(\buf, ~pianoLeftBufs.choose, \startPos, 0, \t_trig, 1, \gate, 1);
//x.set(\gate, 1);
//~pianoLeftBufs.choose;