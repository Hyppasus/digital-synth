(
SynthDef(\waveshaper,
	{
		arg freq = 140, amp = 0.4, srcAmp = 0.3, envDepth = 0.5, att = 0.01, rel = 1.5, cutoff = 4000, feedback = 0;
		var src, shaped, out, srcIndex, env, tableSize = 1000, transTable, tableInput, tableFreq, localLoop, tableIndex;

		localLoop = LocalIn.ar(1, 0);

		transTable = LocalBuf.new(tableSize, 1).clear;
		tableFreq = SampleRate.ir/tableSize;
		//tableInput = Saw.ar(tableFreq); //-->testfunction (shouldn't have an effect on src...)
		//tableInput = Mix.ar(SinOsc.ar(tableFreq* (1..4), 0, 4.reciprocal))+(localLoop*feedback).tanh;
		tableInput = SinOsc.ar(tableFreq*4, 0, SinOsc.ar(tableFreq*3,0,SinOsc.ar(tableFreq*2,0,SinOsc.ar(tableFreq))))+(localLoop*feedback);
		freq = freq/2;

		BufWr.ar(tableInput, transTable, Phasor.ar(0, BufRateScale.kr(transTable), 0, tableSize));

		env = EnvGen.kr(Env.perc(att, rel), 1, envDepth, doneAction: 2);

		src = SinOsc.ar(freq, 0, srcAmp)*env;
		srcIndex = LinLin.ar(src, -1.0, 1.0, 0, tableSize-1).wrap(0, tableSize-1);
		shaped = BufRd.ar(1, transTable, srcIndex, 1, 4);

		tableIndex = LinLin.ar(tableInput, -1.0, 1.0, 0, tableSize-1).wrap(0, tableSize-1);
		LocalOut.ar(BufRd.ar(1, transTable, tableIndex, 1, 4));

		out = shaped;
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
		\srcAmp, 0.8,
		\att, Pwhite(0.1, 0.5, inf),
		\rel, Pwhite(3, 4.5, inf),
		\envDepth, 0.3,
		\feedback, 0,
		\cutoff, 6000,
		\amp, Pwhite(0.4, 0.5, inf),
		\dur, Prand([0.5, 0.25, 0.75], inf),
	)
).play)

{SinOsc.kr(5, SinOsc.kr(4, 0, SinOsc.kr(3,0,SinOsc.kr(2,0,SinOsc.kr(1)))))}.plot(1);