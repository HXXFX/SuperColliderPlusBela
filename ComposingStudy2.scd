(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=50, detune=0.2, pan=0, cfhzmin=0.1, cfhzmax=0.3,
	cfmin=500, cfmax=2000, rqmin=0.1, rqmax=0.2,
	lsf=200, ldb=0, amp=1, out=0;
	var sig, env;
	env = EnvGen.kr(Env([0,1,1,0],[atk,sus,rel],[c1,0,c2]),doneAction:2);
	sig = Saw.ar(freq * {LFNoise1.kr(0.5,detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin,cfhzmax)
		).exprange(cfmin,cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin,rqmax)}!2);
	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;
)
(
~chords = Pbind (
	\instrument, \bpfsaw,
	\dur, Pwhite(4, 9, 7, 0, inf),
	\midinote, Pxrand([
		[22, 8, 14, 13, 14],
		[15, 52, 14, 49, 31, 34],
		[8, 40, 17, 56, 5, 4],
		[30, 5, 17, 6, 43],
	], inf),
	\detune, Pexprand(0.05, 0.08, inf),
	\cfmin, 90,
	\cfmax, 1550,
	\rqmin, Pexprand(1, 5, inf),
	\atk, Pwhite(2, 3, inf),
	\rel, Pwhite(6, 80, inf),
	\ldb, 5,
	\amp, 0.2,
	\out, 0,
).play;
)
~chords.free;
(
~beats = Pbind(
	\instrument, \bpfsaw,
	\dur, Pexprand(0.1, 0.7, inf),
	\freq, Pexprand(1, 3, inf),
	\detune, 0.1,
	\rqmin, 0.13,
	\rqmax, 0.15,
	\cfmin, Pexprand(20, 50, inf),
	\cfmax, Pkey(\cfmin),
	\amp, 0.8,
	\out, 0,
).play;
)
~beats.free;



























