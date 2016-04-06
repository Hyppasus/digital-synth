(
Ndef(\synth).play;
Ndef(\synth).fadeTime=4;
)

Ndef(\synth).pause;
Ndef(\synth).resume;
Ndef(\synth).clear;
Ndef(\synth).source=~synth1;
Ndef(\synth).source=~synth2;
Ndef(\synth).source=~synth3;
Ndef(\synth).source=~synth4;
Ndef(\synth).gui;
(
MIDIClient.init;
MIDIIn.connectAll;
);

(//controler mapping
~cc1 = 1;
~cc2 = 2;
~cc3 = 3;
~cc4 = 4;
~cc5 = 5;
~cc6 = 6;
~cc7 = 7;
~cc8 = 8;
~cc9 = 9;
~cc10 = 10;

~cc11 = 11;
~cc12 = 12;
~cc13 = 13;
~cc14 = 14;

~cc15 = 15;
~cc16 = 16;
~cc17 = 17;
~cc18 = 18;
~cc19 = 19;
~cc20 = 20;
~cc21 = 21;
~cc22 = 22;
~cc23 = 23;
~cc24 = 24;

);

// print them out
25.do{|i|currentEnvironment.at(("cc"++i).asSymbol).postln};

//assign them to the synth
(
25.do{|i|var env = currentEnvironment.at(("cc"++i).asSymbol);
	MIDIFunc.cc({|val,num,ch,src|Ndef(\synth).set(("cc"++i).asSymbol, val);
		//[num,val].postln;
		},env);
};
// assign note on messages
MIDIFunc.noteOn({arg vel, note, ch, src;Ndef(\synth).set(\note, note, \tgate, 1);
	//note.postln
	});
MIDIFunc.noteOff({arg vel, note, ch, src;Ndef(\synth).set(\tgate, 0)});

);


(
~synth1=
{
	arg note=60, vol= 1, tgate=1, cc1=30, cc2=0, cc3=10, cc4=100, cc5=110, cc6=120, cc7=127, cc8=60, cc9=120, cc10=0, cc11=0, cc12=127, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30;

	var freq, amp, srcAmp, envMod, att = 0.01, rel = 1.5, feedback = 0;
	var src, shaped, out, srcIndex, env, tableSize = 1000, transTable, tableInput, tableFreq, localLoop, tableIndex, feedbackAmps;

	//mapping cc-input//
	freq = note.midicps;
	srcAmp = cc1.linexp(0, 127, 0.0001, 1);
	feedback = cc2.linexp(0, 127, 0.0001, 1);
	envMod = cc3.linexp(0, 127, 0.0001, 1);
	att = cc4.linexp(0, 127, 0.0001, 4);
	rel = cc5.linexp(0, 127, 0.0001, 4);
	amp = cc8.linexp(0, 127, 0.0001, 1);

	//synth//
	localLoop = LocalIn.ar(1, 0);
	feedbackAmps = [1, feedback].normalizeSum;

	transTable = LocalBuf.new(tableSize, 1).clear;
	tableFreq = SampleRate.ir/tableSize;
	//tableInput = Saw.ar(tableFreq); //-->testfunction (shouldn't have an effect on src...)
	//tableInput = Mix.ar(SinOsc.ar(tableFreq* (1..4), 0, 4.reciprocal))+(localLoop*feedbackAmps[1]).softclip;
	tableInput = (SinOsc.ar(tableFreq*4, 0, SinOsc.ar(tableFreq*3,0,SinOsc.ar(tableFreq*2,0,SinOsc.ar(tableFreq))))*feedbackAmps[0])+(localLoop*feedbackAmps[1]).softclip;

	BufWr.ar(tableInput, transTable, Phasor.ar(0, BufRateScale.kr(transTable), 0, tableSize));

	env = EnvGen.ar(Env.perc(att, rel), tgate, doneAction: 2);
	envMod = LinLin.kr(envMod, 0, 1, -1, 1);

	src = SinOsc.ar(freq, 0, srcAmp)*LinXFade2.ar(DC.ar(1.0), env, envMod);
	srcIndex = LinLin.ar(src, -1.0, 1.0, 0, tableSize-1).wrap(0, tableSize-1);
	shaped = BufRd.ar(1, transTable, srcIndex, 1, 4);

	tableIndex = LinLin.ar(tableInput, -1.0, 1.0, 0, tableSize-1).wrap(0, tableSize-1);
	LocalOut.ar(BufRd.ar(1, transTable, tableIndex, 1, 4));

	out = shaped;
	out = (out*env)*amp;
	out = LeakDC.ar(out);

	out;
};
)



/*(
SynthDef(\waveshaper,
	{
		arg freq = 140, amp = 0.4, srcAmp = 0.3, envMod = 0.5, att = 0.01, rel = 1.5, feedback = 0;
		var src, shaped, out, srcIndex, env, tableSize = 1000, transTable, tableInput, tableFreq, localLoop, tableIndex, feedbackAmps;

		localLoop = LocalIn.ar(1, 0);
		feedbackAmps = [1, feedback].normalizeSum;

		transTable = LocalBuf.new(tableSize, 1).clear;
		tableFreq = SampleRate.ir/tableSize;
		//tableInput = Saw.ar(tableFreq); //-->testfunction (shouldn't have an effect on src...)
		//tableInput = Mix.ar(SinOsc.ar(tableFreq* (1..4), 0, 4.reciprocal))+(localLoop*feedbackAmps[1]).softclip;
		tableInput = (SinOsc.ar(tableFreq*4, 0, SinOsc.ar(tableFreq*3,0,SinOsc.ar(tableFreq*2,0,SinOsc.ar(tableFreq))))*feedbackAmps[0])+(localLoop*feedbackAmps[1]).softclip;

		BufWr.ar(tableInput, transTable, Phasor.ar(0, BufRateScale.kr(transTable), 0, tableSize));

		env = EnvGen.ar(Env.perc(att, rel), doneAction: 2);
		envMod = LinLin.kr(envMod, 0, 1, -1, 1);

		src = SinOsc.ar(freq, 0, srcAmp)*LinXFade2.ar(DC.ar(1.0), env, envMod);
		srcIndex = LinLin.ar(src, -1.0, 1.0, 0, tableSize-1).wrap(0, tableSize-1);
		shaped = BufRd.ar(1, transTable, srcIndex, 1, 4);

		tableIndex = LinLin.ar(tableInput, -1.0, 1.0, 0, tableSize-1).wrap(0, tableSize-1);
		LocalOut.ar(BufRd.ar(1, transTable, tableIndex, 1, 4));

		out = shaped;
		out = (out*env)*amp;
		out = LeakDC.ar(out);
		Out.ar(0, out!2);
	};
).add;
)

(Pdef(\lspat,
	Pbind(
		\instrument, \waveshaper,
		\freq, Prand([150, 195, 175, 220, 200, 230, 270, 300, 25, 50, 40, 60, 75], inf),
		\srcAmp, 0.2,
		\att, Pwhite(0.1, 0.5, inf),
		\rel, Pwhite(3, 4.5, inf),
		\envMod, 0.1,
		\feedback, 0,
		\amp, Pwhite(0.4, 0.5, inf),
		\dur, Prand([0.5, 0.25, 0.75], inf),
	)
).play)*/