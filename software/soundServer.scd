// soundServer.scd

// server settings and synthDefs, run this ___
s.quit;
(

o = Server.default.options;
o.numInputBusChannels = 4;
o.numOutputBusChannels = 6; // four for the quartet (0, 1, 2, 3) and two for the house (4, 5)
o.sampleRate_(~sampleRate);

ServerOptions.devices;
// use this for testing

//o.inDevice_("MixPre-10 II");
o.inDevice_("BlackHole 64ch");
o.outDevice_("BlackHole 64ch");

//o.inDevice_("MacBook Pro Microphone");
//o.outDevice_("MacBook Pro Speakers");

// use this for performance with evo 16
// o.inDevice_("Audient EVO16");
// o.outDevice_("Audient EVO16");

// o.inDevice_("Ensemble");
// o.outDevice_("Ensemble");

// o.inDevice_("SQ - Audio");
// o.outDevice_("SQ - Audio");
s.boot;
)
// boot synth, go to synths.scd and add synths