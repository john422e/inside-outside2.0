// score.scd
// 3
// no dependencies

(
// event times (in seconds) of all piano notes
~vln1PianoTimes = [160, 210, 240, 276, 315, 345, 380, 470, 558, 580, 592, 600, 610, 615]; // vln1
~vln2PianoTimes = [185, 225, 265, 300, 341, 378, 465, 489, 550, 575, 590, 595, 612, 625]; // vln2
~vlaPianoTimes = [170, 205, 245, 290, 332, 360, 441, 475, 548, 566, 575, 585, 600, 608, 622]; // vla
~vcPianoTimes = [186, 206, 260, 300, 330, 386, 420, 480, 546, 560, 580, 595, 610, 626]; // vc


~pianoEvents = [~vln1PianoTimes, ~vln2PianoTimes, ~vlaPianoTimes, ~vcPianoTimes];

// when to turn all synths off
~silenceStarts = [30, 60, 100, 400, 630];
// when to turn on audio feedback for all four instruments
~fbStarts = [40, 70, 120]; // it gets turned off by silence at 400, afterwhich normal FB never restarts and sampling is triggered by piano times
~fbSwitchingEnabled = true; // if this is true, the sampling synth will trigger audio fb after finishing; need to make sure this can't happen in a silence!!!!
// this needs to get set to false after 400 second timing

~totalEvents = 0;

~pianoEvents.do{ arg i; ~totalEvents = ~totalEvents + i.size };
~totalEvents = ~totalEvents + ~silenceStarts.size + ~fbStarts.size;

)

~totalEvents;

/*(
// event times (in seconds) of F notes
~vln1FTimes = [470, 600]; // vln1 4:50,  10:00
~vln2FTimes = [378, 575]; // vln2 6:18,  9:35
~vlaPianoTimes = [332, 608]; // vla 5:28,  10:08
~vcPianoTimes = [480, 580]; // vc 8:00, 9:40
)*/

/*(
// now add two seconds to each of these
~vln1BuffedTimes = Array.new(~vln1times.size);
~vln1times.do({ arg i; ~vln1BuffedTimes.add(i+2);});
~vln2BuffedTimes = Array.new(~vln1times.size);
~vln2times.do({ arg i; ~vln2BuffedTimes.add(i+2);});
~vlaBuffedTimes = Array.new(~vln1times.size);
~vlatimes.do({ arg i; ~vlaBuffedTimes.add(i+2);});
~vcBuffedTimes = Array.new(~vln1times.size);
~vctimes.do({ arg i; ~vcBuffedTimes.add(i+2);});
)*/

// // harmonic feedback mode turns on sampler mic, but doesn't trigger recording, (piano note does that and disables AF mode)
// // to monitor states
// ~synthStates = [0, 0, 0, 0, 0, 0, 0];
//
// ~events = [ // [time in seconds, [event array]]
// 	// event array = [vln1 mode, vln2 mode, vla mode, cello mode, piano scale, cemetery mode, salemCov mode]
// 	// string modes: 0 = all off, 1 = audio feedback mode, 2 = harmonic feedback mode (exclusive), 3 = switching mode (HF mode, but switching to AF mode when no piano notes)
// 	// piano scale: 0 = nothing, 1 = G major, 2 = adds F (with higher prob.), 3 =
// 	// cemetery mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
// 	// salemCov mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
//
// 	[0, [0, 0, 0, 0]], // 0:00, cemetery FR on
// 	[30, [0, 0, 0, 0]], // 0:30, tutti silence (cemetery FR off)
// 	[40, [1, 0, 0, 0]], // 0:40, vln1 AF mode, cemetery FR on
// 	[60, [0, 0, 0, 0]], // 1:00, tutti silence (vln1 off, cemetery FR off)
// 	[70, [1, 0, 1, 0]], // 1:10, vln1 + vla AF mode, cemetery FR on
// 	[100, [0, 0, 0, 0]], // 1:40, tutti silence (vln1 + vla off, cemetery FR off)
// 	[120, [0, 1, 0, 1]], // 2:00, vln2 + cello AF mode, cemetery FR on
// 	[150, [0, 1, 0, 1]], // 2:30, add salemCov FR on
// 	[155, [1, 1, 1, 1]], // 2:35, add vln1 + vla HF mode, piano scale 1
// 	[163, [2, 1, 1, 1]],
// 	[180, [3, 3, 3, 3]], // 3:00, all strings to switching mode
// 	[300, [3, 3, 3, 0]], // 5:00, cello mode off (playing)
// 	[330, [3, 3, 3, 0]], // 5:30, piano scale 2 (add F natural)
// 	[360, [0, 3, 3, 0]], // 6:00, vln1 mode off (playing)
// 	[400, [0, 0, 0, 0]], // 6:40, tutti silence
// 	[420, [0, 0, 0, 0]], // 7:00, cemetery FR and salemCov mode 2 (random off/on)
// 	[450, [0, 0, 0, 0]], // continue
// 	[465, [2, 2, 2, 2]], // 7:45, all strings on HF mode and playing, piano scale 2
// 	[495, [0, 0, 0, 0]], // electronics silence (strings playing)
// 	[515, [0, 0, 0, 0]], // salemCov FR fade in
// 	[525, [0, 0, 0, 0]], // cemetery FR fade in
// 	[545, [0, 0, 0, 0]], // continue
// 	[550, [0, 0, 0, 0]], // add piano scale 1
// 	[570, [2, 2, 2, 2]], // strings on HF mode and playing, piano scale 3 (more Bb notes)
// 	[630, [0, 0, 0, 0]], // tutti silence (make sure it hard cuts)
// 	[645, [0, 0, 0, 0]] // strings play, nothing else
// ];



// ~events = [ // [time in seconds, [event array]]
// 	// event array = [vln1 mode, vln2 mode, vla mode, cello mode, piano scale, cemetery mode, salemCov mode]
// 	// string modes: 0 = all off, 1 = audio feedback mode, 2 = harmonic feedback mode (exclusive), 3 = switching mode (HF mode, but switching to AF mode when no piano notes)
// 	// piano scale: 0 = nothing, 1 = G major, 2 = adds F (with higher prob.), 3 =
// 	// cemetery mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
// 	// salemCov mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
//
// 	[0, [0, 0, 0, 0, 0, 1, 0]], // 0:00, cemetery FR on
// 	[30, [0, 0, 0, 0, 0, 0, 0]], // 0:30, tutti silence (cemetery FR off)
// 	[40, [1, 0, 0, 0, 0, 1, 0]], // 0:40, vln1 AF mode, cemetery FR on
// 	[60, [0, 0, 0, 0, 0, 0, 0]], // 1:00, tutti silence (vln1 off, cemetery FR off)
// 	[70, [1, 0, 1, 0, 0, 1, 0]], // 1:10, vln1 + vla AF mode, cemetery FR on
// 	[100, [0, 0, 0, 0, 0, 0, 0]], // 1:40, tutti silence (vln1 + vla off, cemetery FR off)
// 	[120, [0, 1, 0, 1, 0, 1, 0]], // 2:00, vln2 + cello AF mode, cemetery FR on
// 	[150, [0, 1, 0, 1, 0, 1, 1]], // 2:30, add salemCov FR on
// 	[155, [2, 1, 2, 1, 1, 1, 1]], // 2:35, add vln1 + vla HF mode, piano scale 1
// 	[180, [3, 3, 3, 3, 1, 1, 1]], // 3:00, all strings to switching mode
// 	[300, [3, 3, 3, 0, 1, 1, 1]], // 5:00, cello mode off (playing)
// 	[330, [3, 3, 3, 0, 2, 1, 1]], // 5:30, piano scale 2 (add F natural)
// 	[360, [0, 3, 3, 0, 2, 1, 1]], // 6:00, vln1 mode off (playing)
// 	[400, [0, 0, 0, 0, 0, 0, 0]], // 6:40, tutti silence
// 	[420, [0, 0, 0, 0, 0, 2, 2]], // 7:00, cemetery FR and salemCov mode 2 (random off/on)
// 	[450, [0, 0, 0, 0, 0, 2, 2]], // continue
// 	[465, [2, 2, 2, 2, 2, 2, 2]], // 7:45, all strings on HF mode and playing, piano scale 2
// 	[495, [0, 0, 0, 0, 0, 0, 0]], // electronics silence (strings playing)
// 	[515, [0, 0, 0, 0, 0, 0, 10]], // salemCov FR fade in
// 	[525, [0, 0, 0, 0, 0, 10, 1]], // cemetery FR fade in
// 	[545, [0, 0, 0, 0, 0, 1, 1]], // continue
// 	[550, [0, 0, 0, 0, 1, 1, 1]], // add piano scale 1
// 	[570, [2, 2, 2, 2, 3, 3, 3]], // strings on HF mode and playing, piano scale 3 (more Bb notes)
// 	[630, [0, 0, 0, 0, 0, 0, 0]], // tutti silence (make sure it hard cuts)
// 	[645, [0, 0, 0, 0, 0, 0, 0]] // strings play, nothing else
// ];

// time = ~events[i][0]
//)