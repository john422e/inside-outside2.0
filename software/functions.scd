// functions.scd
// no dependencies

// global functions, run this first (should not reference anything in data.scd or elsewhere)

(
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
		//if( i == 4 ) { ~pianoScale.(mode, i); [mode, i].postln; };

		// FR updates
		//if( (i == 5) or:{i==6} ) {~updateBufSynth.(mode, i); [mode, i].postln; };
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


// MAKE SINGLE HOST
~makeHost = {
	arg hostname = "127.0.0.1", port=10000;
	var host;
	host = NetAddr.new( hostname, port);
	host;
};
// MAKE HOST ARRAY
~makeHosts = {
	arg hostnames, port=10000;
	var hosts;
	hosts = Array.fill( hostnames.size, { arg i; NetAddr.new( hostnames[i], port)});
	hosts;
};

~sampleIt = {
	arg channel;
	var sampleStream;
	sampleStream = Task.new( {
		// wait after trigger
		~pianoWaitTime.wait;
		// start recording
		~recs[channel].record(~temps[channel], ~micSamplerBuses[channel], numChannels: 1);
		// wait
		~sampleDur.wait;
		// stop recording
		~recs[channel].stopRecording;
		// wait again to make sure file gets written to disk
		~recBufTime.wait;
		// ping analysis server
		~localHost.sendMsg('/ping', 0); // supply channel number
		// wait a bit to make sure analysis server responds
		~pingBufTime.wait;
		// turn synth off (just in case it's on)
		~sineSynths[channel].set(\release, ~fastRelease, \gate, 0);
		~fastRelease.wait; // for release
		~sineSynths[channel].set(\freqs, ~currentData[channel][1]);
		~sineSynths[channel].set(\freqs, ~currentData[channel][1]);
		~sineSynths[channel].set(\amps, ~currentData[channel][0]); // set
		~sineSynths[channel].set(\amp, ~sineSynthGain, \gate, 1); // turn back on
		~synthSusTime * 0.65.wait;
		// turn off (need to finesse this with a fade)
		~sineSynths[channel].set(\release, (~synthSusTime * 0.5), \gate, 0);
		~synthSusTime * 0.35.wait;
		// turn on audio feedback if it's not in a silent section
		if(~silent == false) { ~micLiveSynths[channel].set(\inputGain, ~liveMicInputGain, \limiter, ~liveMicLimiter, \amp, ~liveMicAmp) };
	});
	sampleStream.start;
};

// master stop (without quitting server) -- will this work without defining ~main first?
~stop = {
	"STOPPING THE PIECE".postln;
	// stop main loop
	~main.stop;
	// stop tempoClock
	t.stop;
	// stop buffers
	~fieldBuffers.do{ arg buff; buff.set(\gate, 0) };
	~pianoBuffers.do{ arg buff; buff.set(\gate, 0) };
};


// exits remote chuck server
~shutdownRemoteServer = {
	arg hosts;
	hosts.do( {
		arg host;
		host.sendMsg( '/endProgram');
	});
};
)
