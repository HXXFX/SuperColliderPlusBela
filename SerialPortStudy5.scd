Server.default.boot;
SerialPort.listDevices;
p = ArduinoSMS("COM7", 9600);
//p.action = { | ... msg | msg[0].postln; };
p.action = { | ... msg |  ~distance = msg[0] };
~distance.postln();
SerialPort.closeAll;
//----------------------------------------------
Server.default = s = Server("belaServer", NetAddr("192.168.6.2", 57110));
s.initTree;
s.startAliveThread;
s.freeAll;

//----------------------------------------------
{SinOsc.ar}.play;

//----------------------------------------------
~testSin = {SinOsc.ar(700, 0, 0.125, 0)}.play;
~testSin.free;

//----------------------------------------------
(
~testSin2 = {
	arg a1 = 700, a2 = 0, a3 = 0.125, a4 = 0;
	var sig;
	sig = SinOsc.ar(a1, a2, a3, a4);
}.play;
)

//----------------------------------------------
(
~testSin3={
	arg noiseHz = 8;
	var freq, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	sig = SinOsc.ar(freq, mul: 0.125);
}.play;
)
~testSin3.set(\noiseHz, ~distance);
~distance.postln();

//-----------------------------------------------
(
SynthDef.new(\mySynth1,{
	arg noiseHz = 8;
	var freq, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	sig = SinOsc.ar(freq, mul: 0.125);
	Out.ar(0, sig);
	Out.ar(1, sig);
}).add;
)
~testSin4 = Synth.new(\mySynth1, [\noiseHZ, 64]);
~testSin4.set(\noiseHz, ~distance);

//-----------------------------------------------
(
SynthDef.new(\mySynth2,{
	arg ampHz = 4, fund = 40, maxPartial = 4, width = 0.5;
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0.5, 0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq2 = freq2 * LFPulse.kr(6, add:1);
	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)
~testPulse5 = Synth.new(\mySynth2);
~testPulse5.set(\width, 0.25);
~testPulse5.set(\fund, 30);
~testPulse5.set(\maxPartial, 20);
~testPulse5.set(\ampHz, 0.25);
~testPulse5 = Synth.new(\mySynth2, [\ampHz, 4, \fund, ~distance, \maxPartial, 4, \width, 0.16]);
~testPulse5.free;

//-----------------------------------------------
(
SynthDef(\mySynth3,{
	arg freq = 50, mod = 2, offset = 10;
	var sig;
	sig = SinOsc.ar(freq * SinOsc.ar(mod) + offset);
	sig = FreeVerb.ar(sig, 0.7, 0.8, 0.25);
	Out.ar(0, sig);
	Out.ar(1, sig);
}).add;
)
~testSin6 = Synth.new(\mySynth3);
~testSin6.set(\freq, 100);
~testSin6.set(\mod, 9);
~testSin6.set(\offset, 30);
~testSin6 = Synth.new(\mySynth3, [\freq, ~distance, \mod, 30, \offset, 15]);
~myTask6 = Task({ { ~testSin6.set(\freq, ~distance.pow(2)); 1.wait;}.loop });
~myTask6.start;
~myTask6.stop;
~testSin6.free;

//-----------------------------------------------
Server.local.plotTree;
(
~testPulse7 = {
	var sig, env;
	env = Line.kr(1, 0, 1, doneAction: 2); //envelope from 1 to 0 in 1s, after finish free it Line
	sig = Pulse.ar(48, mul: 0.125) * env;
}.play;
)

//-----------------------------------------------
Server.local.plotTree;
(
~testPulse8 = {
	var sig, freq, env;
	env = XLine.kr(1, 0.01, 5, doneAction: 2); //Xline finish number > 0
	freq = XLine.kr(880, 110, 1, doneAction:0);
	sig = Pulse.ar(freq, mul: 0.125) * env;
}.play;
)

//-----------------------------------------------
Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -3, 0]).plot;
(
~testPulse9 = {
	arg t_gate = 0;
	var sig, env;
	env = EnvGen.kr(Env.new([0, 1, 0.2, 0], [0.5, 1, 2], [3, -3, 0]), t_gate, doneAction:2);
	sig = Pulse.ar(48, mul: 0.125) * env;
}.play;
)
~testPulse9.set(\t_gate, 1);

//-----------------------------------------------
(
~testSaw10 = {
	arg gate = 0;
	var sig, env, freq;
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = VarSaw.ar(SinOsc.kr(freq).range(500, 1000))*env;
}.play;
)
~testSaw10.set(\gate, 1);
~testSaw10.set(\gate, 0);

//-----------------------------------------------
s.meter;
rrand(50, 500).dup(4); //rrand, rand in a range
{rrand(50, 500)}.dup(4);
~testSin11 = {[SinOsc.ar(50), SinOsc.ar(500)]}.play;
~testSin11 = {SinOsc.ar([50, 120])}.play;
(
SynthDef.new(\mySynth4, {
	var sig, amp, env;
	env = EnvGen.kr(
		Env.new([0, 1, 0], [10, 10], [1, -1]), doneAction:2
	);
	amp = SinOsc.kr({ExpRand(0.2, 12)}.dup(8)).range(0, 1);
	sig = SinOsc.ar({ExpRand(50, 600)}.dup(8));
	sig = sig * amp * env;
	//Mix.new(sig).dup(2) * 0.25;
	sig = Splay.ar(sig) * 0.25;
	Out.ar(0, sig);
}).add;
)
~testSin11 = Synth.new(\mySynth4);

//-----------------------------------------------
~testNoise12 = {PinkNoise.ar(0.5.dup(2))}.play;
~testNoise12.free;

//-----------------------------------------------
(
~myArray13 = Array.newClear(5);
[6, 4, 0.5, 10, 7].do{
	arg item, count;
	~myArray[count] = item.squared;
}
)
~myArray13;
5.do{arg item; item.postln};

//-----------------------------------------------
(
~myCollect14 = [1, 2.2, 44, 4].collect{
	arg item;
	item.squared;
}
)

//-----------------------------------------------
(
SynthDef.new(\iter, {
	arg freq = 40;
	var temp, sum, env;
	env = EnvGen.kr(Env.perc(0.01, 5, 1, -2), doneAction:2);
	sum = 0;
	10.do{
		temp = VarSaw.ar(40 * {Rand(0.99, 1.02)}!2, {Rand(0.0, 1.0)}!2, {ExpRand(0.005, 0.05)}!2);
		sum = sum + temp;
	};
	sum = sum* 0.05;
	Out.ar(0, sum);
}).add;
)
~mySynth15 = Synth.new(\iter, [\freq, 500]);
(
~mySynth15 = [50, 53, 69, 78].do{
	arg midinote;
	Synth.new(\iter, [midinote.midicps]);
}
)

//-----------------------------------------------
(
SynthDef.new(\iter2, {
	arg freq = 200, dev = 1.02;
	var temp, sum;
	sum = 0;
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count + 1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).exprange(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.1;
	Out.ar(0, sum);
}).add;
)
~mySynth16 = Synth.new(\iter2);
~mySynth16.set(\freq, 30);
~mySynth16.set(\dev, 1.2);

//-----------------------------------------------
s.plotTree;
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels;
s.reboot;
s.meter;
(
SynthDef.new(\blip, {
	arg out, fund = 300, dens = 2, decay = 0.2;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(fund, fund * 4).round(fund);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(dens);
	sig = sig * EnvGen.kr(Env.perc(0.01, decay), trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out, sig);
}).add;
)
(
SynthDef.new(\reverb, {
	arg in, out = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
	Out.ar(out, sig);
}).add;
)
~reverbBus = Bus.audio(s, 1);
~reverbBus.index;
~sourceGrp = Group.new;
~fxGrp = Group.after(~sourceGrp);
~mySynth17 = Synth.new(\reverb, [\in, ~reverbBus.index], ~fxGrp);
~mySynth18 = Synth.new(\blip, [\out, ~reverbBus.index], ~sourceGrp);

//-----------------------------------------------
~b0 = Buffer.read(s,"D:/Downloads/GesaffelsteinHATEORGLORY.wav");
~b0.play;
~b0.zero;
~b0.free;
~b0.numFrames;
~b0.numChannels;
~b0.duration;
~b0.bufnum;
~b0.sampleRate;
~b0.query;
~b0_part1 = Buffer.read(s,"D:/Downloads/GesaffelsteinHATEORGLORY.wav", 3434, ~b0.numFrames - 3434);
~b0_part1.play;
~b0_part1.query;

(
SynthDef.new(\bufrd_noise, {
	arg amp = 1, out =0, buf, start, end, freq = 1;
	var sig, ptr;
	ptr = LFNoise1.ar(freq).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)
~mySynth19 = Synth.new(\bufrd_noise, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 0.5]);
(
SynthDef.new(\bufrd_sine, {
	arg amp = 1, out =0, buf, start, end, freq = 1;
	var sig, ptr;
	ptr = SinOsc.ar(freq, 3pi/2).range(start, end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;
)
~mySynth20 = Synth.new(\bufrd_sine, [\buf, ~b0.bufnum, \start, 0, \end, ~b0.numFrames-1, \freq, 0.2]);

//-----------------------------------------------
(
SynthDef.new(\sine, {
	arg freq = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0, 1, 0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
Pdef(
	\sinepat,
	Pbind(
	\instrument, \sine,
	//\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\dur, Pwhite(0.05, 0.5, inf).trace,
	\freq, Pexprand(50, 4000, inf).round(55).trace,
	\atk, Pwhite(2.0, 3.0, inf),
	\rel, Pwhite(5.0, 10.0, inf),
	\amp, Pexprand(0.01, 0.2, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
	);
	).play;
)

//-----------------------------------------------
(
SynthDef.new(\pulse, {
	arg freq = 440, atk = 0.005, rel = 0.3, amp = 1, pan = 0;
	var sig, env;
	sig = LFNoise2.ar(freq);
	env = EnvGen.kr(Env.new([0, 1, 0], [atk, rel], [1, -1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)

(
Pdef(
	\pulsepat,
	Pbind(
	\instrument, \pulse,
	//\dur, Pseq([0.6, 0.15, 0.15], inf).trace,
	\dur, Pwhite(0.05, 0.5, inf).trace,
	\freq, Pexprand(50, 4000, inf).round(55).trace,
	\atk, Pwhite(1.0, 3.0, inf),
	\rel, Pwhite(5.0, 20.0, inf),
	\amp, Pexprand(0.01, 0.3, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
	);
	).play;
)
























































