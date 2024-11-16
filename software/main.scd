// main.scd
// 8
// dependencies: ______


// MAKE SURE SECONDS IS SET TO 0 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
~secondCount = 0; // set for rehearsal/sound checking;





































/*
check times:
FR and audio feedback: 40 seconds
// 2:00 (119)
harmonic feedback and piano: 2:30 (150)
525 (8:45) for bowed balance
*/



// SECONDS TO ZERO

~stop.();


~sampleIt.(3);
~silent = true;
~silent = false;

// this is working, but i need to make sustain longer and add to main loop


(
~pieceLength = 11 * 60; //seconds
~tempo = (60/60); // BPM =(x/60)


// get event times and save in own array for easy reference
~eventTimes = Array.fill(~events.size, {
	arg i;
	~events[i][0];
});

~eventCounter = 0;
s.meter;
~silent = false;

// 15 db on the preamps

// set house levels
~setSinesMains.(0.30); // 1.0 by default
~setPianoMains.(4.0); // 1.0 by default
~setMicMains.(1.5);

// tempo clock
t = TempoClock.new(~tempo, ~secondCount);

// EVENT TIMELINE
~main = Task.new( {
	// first start all the field recordings
	// startPos = time in samples (48k)


	// INITIALIZATION
	~seconds = ~secondCount; // can update this for rehearsal purposes to jump around


	// put these in a list dude
	~fieldPlayers.do{ arg buff; buff.set(\startPos, ~sampleRate * ~seconds, \t_trig, 1, \amp, ~fieldPlaybackAmp, \gate, 1) };
	~pianoPlayers.do{ arg buff; buff.set(\startPos, ~sampleRate * ~seconds, \t_trig, 1, \amp, ~pianoAmp, \gate, 1) };


	// MAIN LOOP
	~pieceLength.do( {
		var time, tUnit, minutes, seconds;
		time = t.beats.round;
		seconds = t.beats % 60;
		minutes = (t.beats / 60).asInteger;
		tUnit = t.beatDur;
		//[minutes, ":", seconds, time].postln;
		format("TIME:\t\t\t\t % minutes, % seconds", (t.beats/60).asInteger, (t.beats%60).asInteger).postln;

		// check for piano events
		~pianoEvents.do( {
			arg myList, i;
			//[myList, i].postln;
			if( myList.includesEqual(time), {
				["triggering recorder", i].postln;
				~eventCounter = ~eventCounter + 1;
				// fork the sampling process here
				["FORKING", i].postln;
				{~sampleIt.(i)}.fork;
			});
		});
		// check for silences
		if( ~silenceStarts.includesEqual(time), {
			["GOING SILENT"].postln;
			~silent = true;
			~eventCounter = ~eventCounter + 1;
			// go through all synths and silence them /gate 0
			// turn off
			~micLiveSynths.do( { arg synth; synth.set(\gate, 0) });
		});
		// check for FB starts
		if( ~fbStarts.includesEqual(time), {
			["STARTING FEEDBACK"].postln;
			~silent = false;
			~eventCounter = ~eventCounter + 1;
			// turn on FB synths
			// turn on
			~micLiveSynths.do( { arg synth; synth.set(\inputGain, ~liveMicInputGain, \limiter, ~liveMicLimiter, \gate, 1) });
		});

/*		if( ~eventTimes.includesEqual(t.beats), {
			var i;
			"EVENT".postln;
			i = ~eventTimes.indexOf(t.beats.asInteger);
			i.postln;
			// fork it
			~events[i][1].postln;
			fork{ ~parseEvents.(~events[i][1]) };
		});*/

		tUnit.wait;
	});

	// shutdown python server when finished
	~localHost.sendMsg('/shutdown');
	~eventCounter.postln;
}).start;

)
t.stop;
~main.stop;
~parseEvents.([0, 0, 0, 0, 0, 0, 0]); // all off

[0, 1, 2, 3].choose;
2.rand;

(
i = 0;
while { i < 5 } { i = i + 1; "boing".postln };
)

~fieldPlayers.do( { arg synth; synth.set(\gate, 1) });


// SET HOUSE LEVELS HERE
~houseMixer.set(\masterAmp, 0.0);
~houseMixer.set(\masterAmp, 0.8);
// these are set separately, not on the hosue mix
~fieldPlayers.do( { arg synth; synth.set(\amp, 0)}); // 0.1 by default
~setSinesMains.(0.30); // 1.0 by default
~setPianoMains.(4.0); // 1.0 by default
~setMicMains.(1.5);

~fieldPlayers.do( { arg synth; synth.set(\amp, 0.15)}); // 0.1 by default

~micLiveSynths.do( {arg synth; synth.set(\inputGain, ~liveMicInputGain, \limiter, ~liveMicLimiter, \amp, 1.0) });