o = Server.local.options;
o.blockSize = 1;

///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////generating breakpointfunction////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\lsSynth,
	{
		arg freq = 50, amp = 0.3;
		var trigger, sig, out;
		trigger = Impulse.kr(freq);
		//sig = BufRd.ar(1, 0, Phasor.ar(0, freq, 0, 255));
		sig = Osc.ar(0, freq);
		out = sig*amp;
		Out.ar(0, sig!2);

		SendTrig.kr(trigger);
	};
).add;

~lSys = LSys("baaaaaaabaaaaaaa",
	[
		"a<a"->"d",
		"a<b"->"d",
		"a<c"->"a",
		"a<d"->"b",
		"b<a" -> "a",
		"b<b" -> "c",
		"b<c"->"a",
		"b<d"->"a",
	]
);

(~lSys.rules =
[
	"a<a"->"b",
	"a<b"->"a",
	"a<c"->"d",
	"a<d"->"c",
	"b<a" -> "d",
	"b<b" -> "d",
	"b<c"->"b",
	"b<d"->"a",
	"c<a" -> "a",
	"c<b" -> "d",
	"c<c"->"a",
	"c<d"->"b",
	"d<a" -> "a",
	"d<b" -> "d",
	"d<c"->"a",
	"d<d"->"b",
];)

~sampValues = IdentityDictionary[\a -> 1.0.rand, \b -> 1.0.rand, \c -> 1.0.rand.neg, \d -> 1.0.rand.neg];
~waveTable = Buffer.alloc(s, 256, bufnum: 0);

OSCFunc(
	{
		Routine.run{
			arg mes;
			var axiom, tempWavetable;
			axiom = ~lSys.applyRules(1);
			tempWavetable = Array.newClear(axiom.size);
			axiom.do({arg item, i; tempWavetable.put(i, ~ sampValues.at(item.asSymbol))});
			tempWavetable = tempWavetable.resamp1(~waveTable.numFrames);
			s.sync;
			~waveTable.sendCollection(tempWavetable);
		};
	}, 'tr';
);
)

Synth(\lsSynth, [\freq, 100]);


///////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////generating partials//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\lsSynth,
	{
		arg freq = 50, amp = 0.3;
		var trigger, sig, out;
		trigger = Impulse.kr(freq);
		//sig = BufRd.ar(1, 0, Phasor.ar(0, freq, 0, 255));
		sig = Osc.ar(0, freq);
		out = sig*amp;
		Out.ar(0, sig!2);

		SendTrig.kr(trigger);
	};
).add;

~lSys = LSys("baaaaaaabaaaaaaa",
	[
		"a<a"->"b",
		"a<b"->"a",
		"a<c"->"d",
		"a<d"->"c",
		"b<a" -> "d",
		"b<b" -> "d",
		"b<c"->"b",
		"b<d"->"a",
		"c<a" -> "a",
		"c<b" -> "d",
		"c<c"->"a",
		"c<d"->"b",
		"d<a" -> "a",
		"d<b" -> "d",
		"d<c"->"a",
		"d<d"->"b",
	]
);

~sampValues = IdentityDictionary[\a -> 1, \b -> 2, \c -> 3, \d -> 4];
~waveTable = Buffer.alloc(s, 256, bufnum: 0);

OSCFunc(
	{
		Routine.run{
			arg mes;
			var axiom, tempWavetable;
			axiom = ~lSys.applyRules(1);
			tempWavetable = Array.newClear(axiom.size);
			axiom.do({arg item, i; tempWavetable.put(i, ~ sampValues.at(item.asSymbol))});
			//tempWavetable = Wavetable.sineFill(~waveTable.numFrames, tempWavetable.reciprocal);
			s.sync;
			~waveTable.sine1(tempWavetable.reciprocal);
		};
	}, 'tr';
);
)

Synth(\lsSynth, [\freq, 50]);

(~lSys.rules =
[
	"a<a"->"a",
	"a<b"->"b",
	"a<c"->"b",
	"a<d"->"a",
	"b<a" -> "d",
	"b<b" -> "b",
	"b<c"->"d",
	"b<d"->"c",
	"c<a" -> "d",
	"c<b" -> "a",
	"c<c"->"d",
	"c<d"->"c",
	"d<a" -> "d",
	"d<b" -> "c",
	"d<c"->"d",
	"d<d"->"c",
];)

///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////generating partials: 2 rotating buffers////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\lsSynth,
	{
		arg freq = 100, amp = 0.3, index;
		var trigger, sig, out;
		trigger = Impulse.kr(freq);
		sig = VOsc.ar(index, freq);///////////VOsc cannot interpolate/modulate fast enough?
		out = sig*amp;
		Out.ar(0, sig!2);

		SendTrig.kr(trigger);
	};
).add;

~lSys = LSys("baaaaaaabaaaaaaa",
	[
		"a<a"->"b",
		"a<b"->"a",
		"a<c"->"d",
		"a<d"->"c",
		"b<a" -> "d",
		"b<b" -> "d",
		"b<c"->"b",
		"b<d"->"a",
		"c<a" -> "a",
		"c<b" -> "d",
		"c<c"->"a",
		"c<d"->"b",
		"d<a" -> "a",
		"d<b" -> "d",
		"d<c"->"a",
		"d<d"->"b",
	]
);


~sampValues = IdentityDictionary[\a -> 1, \b -> 2, \c -> 3, \d -> 4];
~waveTable0 = Buffer.alloc(s, 256, bufnum: 0);
~waveTable1 = Buffer.alloc(s, 256, bufnum: 1);
~switch = 0;

~lsVoice = Synth(\lsSynth);

OSCFunc(
	{
		Routine.run{
			arg mes;
			var axiom, tempWavetable;
			~switch = (~switch+1)%2;
			axiom = ~lSys.applyRules(1);
			tempWavetable = Array.newClear(axiom.size);
			axiom.do({arg item, i; tempWavetable.put(i, ~ sampValues.at(item.asSymbol))});
			s.sync;
			if(~switch == 0)
			{
				~waveTable0.sine1(tempWavetable.reciprocal);
				~lsVoice.set(\index, 1);
			}
			{
				~waveTable1.sine1(tempWavetable.reciprocal);
				~lsVoice.set(\index, 0);
			};
		};
	}, 'tr';
);
)


///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////wavetable segmentation/////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\lsSynth,
	{
		arg freq = 100, amp = 0.3, att = 1, rel = 3;
		var trigger, sig, env, out;
		env = EnvGen.kr(Env.perc(att, rel), 1, doneAction:2);
		trigger = Impulse.kr(freq);
		sig = Osc.ar(0, freq);
		out = (sig*env)*amp;
		//out = sig*amp;
		Out.ar(0, out!2);

		SendTrig.kr(trigger);
	};
).add;

~lSys = LSys("badc",
	[
		"a<a"->"a",
		"a<b"->"d",
		"a<c"->"a",
		"a<d"->"b",
		"b<a"->"a",
		"b<b"->"c",
		"b<c"->"a",
		"b<d"->"a",
	]
);

~sine = Signal.sineFill(256, [1]);
~waveTable = Buffer.alloc(s, 256, bufnum: 0);
~waveTable.sine1([1]);
~sampValues = IdentityDictionary[\a -> ~sine.copyRange(0, 63), \b -> ~sine.copyRange(64, 127), \c -> ~sine.copyRange(128, 191), \d -> ~sine.copyRange(192, 256)];


OSCFunc(
	{
		Routine.run{
			arg mes;
			var axiom, tempWavetable;
			axiom = ~lSys.applyRules(1);
			tempWavetable = Array.new(axiom.size);
			axiom.do({arg item, i; tempWavetable = tempWavetable.addAll(~sampValues.at(item.asSymbol))});
			//tempWavetable.flat;
			s.sync;
			~waveTable.loadCollection(tempWavetable);
		};
	}, 'tr';
);
)


(Pdef(\lspat,
	Pbind(
		\instrument, \lsSynth,
		\freq, Prand([150, 195, 175, 220, 200, 230, 25, 50, 40, 60], inf),
		\att, Pwhite(0, 2.5, inf),
		\rel, Pwhite(3, 4.5, inf),
		\amp, Pwhite(0.1, 0.3, inf)*0.5,
		\dur, Prand([0.5, 0.25, 0.75], inf),
	)
).play)




///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////waveshaping/////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
(
SynthDef(\lsShaper,
	{
		arg freq = 100, amp = 0.3, srcAmp = 0.1, att = 1, rel = 3, envMod = 0.1, sub = 0.3;
		var src, shaped, out, trigger, playHead, env;
		trigger = Impulse.kr(freq);
		env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		src = SinOsc.ar(freq, 0, srcAmp+((env*envMod).linlin(0,1,1,0)));
		playHead = LinLin.ar(src, -1.0,1.0, 0, BufFrames.kr(0)).wrap(0, BufFrames.kr(0));
		shaped = (BufRd.ar(1, 0, playHead)+(src*sub))*amp;
		out = shaped*env;
		out = LeakDC.ar(out).tanh;
		Out.ar(0, out!2);

		SendTrig.kr(trigger);
	};
).add;

~lSys = LSys("badc",
	[
		"a<a"->"a",
		"a<b"->"b",
		"a<c"->"d",
		"a<d"->"d",
		"b<a" -> "c",
		"b<b" -> "a",
		"b<c"->"d",
		"b<d"->"c",
		"c<a" -> "d",
		"c<b" -> "a",
		"c<c"->"d",
		"c<d"->"a",
		"d<a" -> "a",
		"d<b" -> "d",
		"d<c"->"d",
		"d<d"->"d",
	]
);

~sampValues = IdentityDictionary[\a -> 1, \b -> 2, \c -> 3, \d -> 4];
~waveTable = Buffer.alloc(s, 256/2, bufnum: 0);

OSCFunc(
	{
		Routine.run{
			arg mes;
			var axiom, tempWavetable;
			axiom = ~lSys.applyRules(1);
			tempWavetable = Array.newClear(axiom.size);
			axiom.do({arg item, i; tempWavetable.put(i, ~sampValues.at(item.asSymbol))});
			//tempWavetable = Wavetable.sineFill(~waveTable.numFrames, tempWavetable.reciprocal);
			1.wait;
			~waveTable.sine1(tempWavetable.reciprocal);
		};
	}, 'tr';
);
)

Synth(\lsShaper);
s.sendMsg(\n_set, 1000, \srcAmp, 0.7);

(Pdef(\lspat,
	Pbind(
		\instrument, \lsShaper,
		\freq, Prand([150, 195, 175, 220, 200, 230, 270, 300, 25, 50, 40, 60, 75], inf)*2,
		\srcAmp, Pwhite(0.1, 0.4, inf),
		\sub, Pwhite(0.0, 0.1, inf),
		\att, Pwhite(0, 2.5, inf),
		\rel, Pwhite(3, 4.5, inf),
		\envMod, Pwhite(0.2, 0.4, inf),
		\amp, Pwhite(0.4, 0.8, inf),
		\dur, Prand([0.5, 0.25, 0.75], inf),
	)
).play)

(~lSys = LSys("baaaaaaabaaaaaaa",
	[
		"a<a"->"a",
		"a<b"->"c",
		"a<c"->"a",
		"a<d"->"b",
		"b<a" -> "b",
		"b<b" -> "a",
		"b<c"->"d",
		"b<d"->"b",
		"c<a" -> "d",
		"c<b" -> "a",
		"c<c"->"d",
		"c<d"->"a",
		"d<a" -> "d",
		"d<b" -> "b",
		"d<c"->"c",
		"d<d"->"a",
	]
))