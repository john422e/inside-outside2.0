// data.scd
// 1
// no dependencies

(
// global data, run this second
~sampleRate = 48000;
~numInputs = 4; // analog inputs (quartet mics)
~numOutputs = 6; // analog outputs (quartet speakers)
~numSines = 8; // how many sine waves to include in sinBank synth

// gain levels
/*
PREAMPS ON INTERFACE:
mics 1-3 at 10db
mic 4 (cello) at 8 db
*/
~inputOffset = 2; // if not starting with first input
~sineSynthGain = 0.03;
~liveMicInputGain = 0.9;
~liveMicLimiter = 0.03;
~liveMicAmp = 0.1;
~fieldPlaybackAmp = 0.1;
~pianoAmp = 0.05;

~currentData = Array.fill(~numInputs, {
	[
		Array.fill(~numSines, { 1.0/~numSines }),
		Array.fill(~numSines, { rrand(100.0, 200.0)})
	]
});

~pianoWaitTime = 4; // how long to wait before starting sample collection
~sampleDur=0.5;
~recBufTime=0.5;
~pingBufTime=0.5;
~cwd = PathName.new(thisProcess.nowExecutingPath).parentPath;
~temps = Array.fill( ~numInputs, { arg i; ~cwd ++ "temp" ++ i.asString ++ ".wav"});
~fastRelease = 0.1;

~synthSusTime = 20; // how long to hold the sinSynths before releasing

// use these with the ~filterList in functions.scd

// list of frequencies from salemCov analysis
//~salemCovFreqs = Array.rand(256, 60, 4000); // test version
// live generated list of freqs from mic signal
//~liveFreqs = Array.rand(256, 60, 4000); // test version

// get sound file names

// audio directory
~audioDir = PathName.new( PathName.new(thisProcess.nowExecutingPath).parentPath ++ "../audio");
// piano notes filenames;
//~pianoNotesLeftDir = ~audioDir +/+ PathName("piano/left");
//~pianoNotesRightDir = ~audioDir +/+ PathName("piano/right");
// FR directories
~fieldDir = ~audioDir +/+ PathName("fieldLayers/performance/");



)
