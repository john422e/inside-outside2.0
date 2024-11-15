s.boot;
s.quit;

a = 440;
c = a/3/3/3;
c = c*2*2; // c2

~one = c;
~two = ~one*2
{Splay.ar(LFTri.ar([c*6, c*7.5, c*9, c*10.5], 0, 0.04))}.play;
{Splay.ar(LFTri.ar([c*6, c*7.5, c*9, c*11], 0, 0.04))}.play;
{Splay.ar(LFTri.ar([c*6, c*7.5, c*9, c*11.25], 0, 0.04))}.play;

{Splay.ar(LFTri.ar([c*6, c*7, c*9, c*10.5], 0, 0.04))}.play;
{Splay.ar(LFTri.ar([c*6, c*7, c*9, c*11.0], 0, 0.04))}.play;
{Splay.ar(LFTri.ar([c*6, c*7, c*9, c*11.25], 0, 0.04))}.play;


{Splay.ar(LFTri.ar([c*6, c*7.5, c*9, c*10.5], 0, 0.04))}.play;
{Splay.ar(LFTri.ar([c*6, c*7, c*9, c*10.5], 0, 0.04))}.play;


{Splay.ar(LFTri.ar([c*6, c*7.5, c*9, c*11], 0, 0.25))}.play;
{Splay.ar(LFTri.ar([c*6, c*7, c*9, c*11.0], 0, 0.25))}.play;

{Splay.ar(LFTri.ar([c*6, c*7.5, c*9, c*11.25], 0, 0.25))}.play;
{Splay.ar(LFTri.ar([c*6, c*7, c*9, c*11.25], 0, 0.25))}.play;
