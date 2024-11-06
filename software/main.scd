// main.scd
// dependencies: ______

(
~pieceLength = 11 * 60; //seconds
~tempo = (60/60); // BPM =(x/60)
~secondCount = 65; // change this for rehearsal


// get event times and save in own array for easy reference
~eventTimes = Array.fill(~events.size, {
	arg i;
	~events[i][0];
});

// tempo clock
t= TempoClock.new(~tempo, ~secondCount);

// main event loop
~main = Task.new( {
	~pieceLength.do( {
		var time, tUnit;
		time = t.beats;
		tUnit = t.beatDur;
		time.postln;

		// check for event
		if( ~eventTimes.includesEqual(t.beats), {
			var i;
			"EVENT".postln;
			i = ~eventTimes.indexOf(t.beats.asInteger);
			i.postln;
			// fork it
			~events[i][1].postln;
			fork{ ~parseEvents.(~events[i][1]) };
		});

		tUnit.wait;
	});

	// shutdown python server when finished
	~localHost.sendMsg('/shutdown');
}).start;

)
~main.stop;
~parseEvents.([0, 0, 0, 0, 0, 0, 0]); // all off

[0, 1, 2, 3].choose;
2.rand;

(
i = 0;
while { i < 5 } { i = i + 1; "boing".postln };
)