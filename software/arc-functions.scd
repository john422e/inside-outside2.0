// functions.scd
// no dependencies

// global functions, run this first (should not reference anything in data.scd or elsewhere)

(
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
	bufs;
};
// ~init = Routine.new( {
// 	~buffers = ~pianoNotesLeftDir.entries.collect( {
// 		arg filename;
// 		Buffer.read(s, filename.fullPath);
// 	});
// 	s.sync;
//
// }).play;



~updateStringMicSynth = {
	arg mode, inst; // inst 0-3 (vln1, vln2, vla, cello)
	//
	// 0 = all off, 1 = audio feedback mode, 2 = harmonic feedback mode, 3 =
	["SETTING STRING SYNTH", mode, inst].postln;
	if( mode == 0 ) { // OFF
		// set reference state
		~synthStates[inst] = 0;
		// set synths
		~micLiveSynths[inst].set(\amp, 0);
		~micSamplerSynths[inst].set(\inputGain, 0.0);
	};
	if( mode == 1 ) { // AUDIO FEEDBACK MODE
		// set reference state
		~synthStates[inst] = 1;
		// set synth
		~micLiveSynths[inst].set(\amp, 1);
	};
	if( mode == 2 ) { // HARMONIC FEEDBACK MODE
		// set reference state
		~synthStates[inst] = 2;
		// set synths
		~micLiveSynths[inst].set(\amp, 0); // turn off AF
		~micSamplerSynths[inst].set(\inputGain, 1.0); // turn on HF
	};
	if( mode == 3) { // SWITCHING (AF and HF)
		// set reference state
		~synthStates[inst] = 3;
		// set synths
		~micLiveSynths[inst].set(\amp, 1); // turn off AF
		~micSamplerSynths[inst].set(\inputGain, 1.0); // turn on HF
	};
};

~updateBufSynth = {
	arg mode, inst; // cemetery index = 5, salemCov index = 6
	// cemetery mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
	// salemCov mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
	["SETTING FR SYNTH", mode, inst].postln;
	if( mode == 0 ) { // OFF
		// set reference state
		~synthStates[inst] = 0;
		// set synth
		if( inst == 5 ) { ~cemeteryPlayer.set(\gate, 0) };
		if( inst == 6 ) { ~salemCovPlayer.set(\gate, 0) };
	};
	if( mode == 1 ) { // STEADY ON
		// set reference state
		~synthStates[inst] = 1;
		// set synth
		if( inst == 5 ) { ~cemeteryPlayer.set(\attack, 0.01, \gate, 1) };
		if( inst == 6 ) { ~salemCovPlayer.set(\attack, 0.01, \gate, 1) };
	};
	if( mode == 2 ) { // RANDOM OFF/ON
		// set reference state
		~synthStates[inst] = 2;
		// set synth // NEED TO PROGRAM BEHAVIOR FOR THIS
		if( inst == 5 ) { ~cemeteryPlayer.set(\gate, 1) };
		if( inst == 6 ) { ~salemCovPlayer.set(\gate, 1) };
	};
	if( mode == 10) { // 10 SECOND FADE IN
		// set reference state
		~synthStates[inst] = 10;
		// set synth
		if( inst == 5 ) { ~cemeteryPlayer.set(\attack, 10, \gate, 1) };
		if( inst == 6 ) { ~salemCovPlayer.set(\attack, 10, \gate, 1) };
	};
};


~pianoScale = {
 	arg mode, inst; // inst = 4
 	// piano scale: 0 = nothing, 1 = G major, 2 = adds F (with higher prob.), 3 =
 	["SETTING PIANO SYNTHS", mode, inst].postln;
 	if( mode == 0 ) { // OFF
 		// set reference state
 		~synthStates[inst] = 0;
 		// set synths
 		~pianoLeftPlayers.do{ arg synth; synth.set(\gate, 0) }; // make sure they're off
 		~pianoRightPlayers.do{ arg synth; synth.set(\gate, 0) }; // make sure they're off
 	};

 	if( mode == 1 ) { // G MAJOR NOTES
 		// set reference state
 		~synthStates[inst] = 1;
 		// set synths
 		// read in G major bufs and start randomly picking
		4.do({
			arg string;
			var play;
			fork{
				4.do{ // figure out a way to set this number dynamically
					play = 0.5.coin;
					if( play == true ) {
						~pianoRoutines[string].reset;
						~pianoRoutines[string].next;
					};
					7.wait;
				};
			};
		});
 	};

 	if( mode == 2 ) { // ADDS F
 		// set reference state
 		~synthStates[inst] = 2;
 		// set synths
 		// read in some G major notes and Fs and start randomly picking
 	};

 	if( mode == 3 ) { // ADDS MORE Fs
 		// set reference state
 		~synthStates[inst] = 3;
 		// set synths
 		// read in some G major notes and more Fs and Bb major notes and start randomly picking
 	};
};

~parseEvents = {
	arg event;
	// read event array [0, 1, 2, 3, 4, 5, 6]
	// event array = [vln1 mode, vln2 mode, vla mode, cello mode, piano scale, cemetery mode, salemCov mode]
	// string modes: 0 = all off, 1 = audio feedback mode, 2 = harmonic feedback mode (exclusive), 3 = switching mode (HF mode, but switching to AF mode when no piano notes)
	// piano scale: 0 = nothing, 1 = G major, 2 = adds F (with higher prob.), 3 =
	// cemetery mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
	// salemCov mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
	event.do{
		arg mode, i;
		// read through array

		// string updates
		if( i < 4 ) { ~updateStringMicSynth.(mode, i); [mode, i].postln; };

		// piano scale
		if( i == 4 ) { ~pianoScale.(mode, i); [mode, i].postln; };

		// FR updates
		if( (i == 5) or:{i==6} ) {~updateBufSynth.(mode, i); [mode, i].postln; };
	};
};



// add frequencies from ~liveFreqs to filtered list if they are found in ~salemCovFreqs
~filterList = {
	// returns all elements of list2 which are in list1
	arg list1, list2;
	var filteredList;
	filteredList = List.newClear;
	list2.do{
		arg i;
		if( list1.includes(i) ) { filteredList.add(i)};
	};
	filteredList;
};
)
