(
SynthDef(\waveshaper,
	{
		arg freq = 140, amp = 0.4, srcAmp = 0.3, att = 0.01, rel = 1.5;
		var src, shaped, out, playHead, env, tableSize = 1000, transTable, tableInput, tableFreq;

		transTable = LocalBuf.new(tableSize, 1).clear;
		tableFreq = SampleRate.ir/tableSize;
		//tableInput = LFTri.ar(tableFreq);
		tableInput = Mix(SinOsc.ar(tableFreq * (1 .. 6), Array.linrand(6, 0.0, 6.28), SinOsc.kr(Array.exprand(6, 0.1, 0.3), 0, 0.2)));
		BufWr.ar(tableInput, transTable, Phasor.ar(0, BufRateScale.kr(transTable), 0, tableSize));

		env = EnvGen.kr(Env.perc(att, rel), doneAction: 2);
		src = SinOsc.ar(freq, 0, srcAmp);
		playHead = LinLin.ar(src, -1.0, 1.0, 0, tableSize).wrap(0, tableSize);
		shaped = BufRd.ar(1, transTable, playHead);
		out = shaped*env;
		out = out*amp;
		out = LeakDC.ar(out);
		Out.ar(0, out!2);
	};
).add;
)

(Pdef(\lspat,
	Pbind(
		\instrument, \waveshaper,
		\freq, Prand([150, 195, 175, 220, 200, 230, 270, 300, 25, 50, 40, 60, 75], inf)*2,
		\srcAmp, Pwhite(0.1, 1.0, inf),
		\att, Pwhite(0, 0.5, inf),
		\rel, Pwhite(3, 4.5, inf),
		\amp, Pwhite(0.4, 0.8, inf),
		\dur, Prand([0.5, 0.25, 0.75], inf),
	)
).play)