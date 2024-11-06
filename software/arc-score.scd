// score.scd
// no dependencies

(
// harmonic feedback mode turns on sampler mic, but doesn't trigger recording, (piano note does that and disables AF mode)
// to monitor states
~synthStates = [0, 0, 0, 0, 0, 0, 0];

~events = [ // [time in seconds, [event array]]
	// event array = [vln1 mode, vln2 mode, vla mode, cello mode, piano scale, cemetery mode, salemCov mode]
	// string modes: 0 = all off, 1 = audio feedback mode, 2 = harmonic feedback mode (exclusive), 3 = switching mode (HF mode, but switching to AF mode when no piano notes)
	// piano scale: 0 = nothing, 1 = G major, 2 = adds F (with higher prob.), 3 =
	// cemetery mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in
	// salemCov mode: 0 = off, 1 = on, 2 = random off/on, 10 = 10 second fade in

	[0, [0, 0, 0, 0, 0, 1, 0]], // 0:00, cemetery FR on
	[30, [0, 0, 0, 0, 0, 0, 0]], // 0:30, tutti silence (cemetery FR off)
	[40, [1, 0, 0, 0, 0, 1, 0]], // 0:40, vln1 AF mode, cemetery FR on
	[60, [0, 0, 0, 0, 0, 0, 0]], // 1:00, tutti silence (vln1 off, cemetery FR off)
	[70, [1, 0, 1, 0, 0, 1, 0]], // 1:10, vln1 + vla AF mode, cemetery FR on
	[100, [0, 0, 0, 0, 0, 0, 0]], // 1:40, tutti silence (vln1 + vla off, cemetery FR off)
	[120, [0, 1, 0, 1, 0, 1, 0]], // 2:00, vln2 + cello AF mode, cemetery FR on
	[150, [0, 1, 0, 1, 0, 1, 1]], // 2:30, add salemCov FR on
	[155, [2, 1, 2, 1, 1, 1, 1]], // 2:35, add vln1 + vla HF mode, piano scale 1
	[180, [3, 3, 3, 3, 1, 1, 1]], // 3:00, all strings to switching mode
	[300, [3, 3, 3, 0, 1, 1, 1]], // 5:00, cello mode off (playing)
	[330, [3, 3, 3, 0, 2, 1, 1]], // 5:30, piano scale 2 (add F natural)
	[360, [0, 3, 3, 0, 2, 1, 1]], // 6:00, vln1 mode off (playing)
	[400, [0, 0, 0, 0, 0, 0, 0]], // 6:40, tutti silence
	[420, [0, 0, 0, 0, 0, 2, 2]], // 7:00, cemetery FR and salemCov mode 2 (random off/on)
	[450, [0, 0, 0, 0, 0, 2, 2]], // continue
	[465, [2, 2, 2, 2, 2, 2, 2]], // 7:45, all strings on HF mode and playing, piano scale 2
	[495, [0, 0, 0, 0, 0, 0, 0]], // electronics silence (strings playing)
	[515, [0, 0, 0, 0, 0, 0, 10]], // salemCov FR fade in
	[525, [0, 0, 0, 0, 0, 10, 1]], // cemetery FR fade in
	[545, [0, 0, 0, 0, 0, 1, 1]], // continue
	[550, [0, 0, 0, 0, 1, 1, 1]], // add piano scale 1
	[570, [2, 2, 2, 2, 3, 3, 3]], // strings on HF mode and playing, piano scale 3 (more Bb notes)
	[630, [0, 0, 0, 0, 0, 0, 0]], // tutti silence (make sure it hard cuts)
	[645, [0, 0, 0, 0, 0, 0, 0]] // strings play, nothing else
];

// time = ~events[i][0]
)