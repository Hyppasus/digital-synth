/*
// From RedFrick(Frederik Olafsson) code, Thanks Supercollider Forum!!
// Try this settings

Server.default.options.sampleRate = 96000;// or the higest in your system
Server.default.options.blockSize = 1;
*/
Server.default.waitForBoot{

	s = Server.default;


(
SynthDef(\feedbackOsc, {|out=0, mFrq= 313, mFB= 1, freq= 100, fB= 1, width= 0, mul= 500, ffreq=1000, rq=1, gate=1, attack=0.01, sustain=1, release=1|
	var w= [0, width*2pi];
	var buf= LocalBuf(1).clear;
	var buf2= LocalBuf(1, 2).clear;
	var osc= sin(LFSaw.ar(mFrq).range(0, 2pi)+(Dbufrd(buf)*mFB));
	var snd= Duty.ar(SampleDur.ir, 0, Dbufwr(osc, buf));
	var osc2= sin(LFSaw.ar(freq+(snd*mul)).range(0, 2pi)+(Dbufrd(buf2)*fB)+w);
	var snd2= Duty.ar(SampleDur.ir, 0, Dbufwr(osc2, buf2));
	//var filter= RLPF.ar(snd2, ffreq, rq);
	var filter = DFM1.ar(snd2, ffreq, rq);
	var env = EnvGen.ar(Env.asr(attack,sustain,release), gate, doneAction:2);
	Out.ar(out,filter*env);
}).add;
);

	s.sync;

	MIDIClient.init;
	MIDIIn.connectAll;
	//s.sendMsg(\s_new, "feedbackOsc", 1010, 1, 1);

	~mFbCC = 2;
	~freqCC = 4;
	~fbCC = 3;
	~widthCC = 10;
	~mulCC = 9;
	~ffreqCC = 11;
	~rqCC = 12;

	s.sync;
(
		s.sendMsg(\s_new, "feedbackOsc", 1010, 1, 1);
		MIDIFunc.noteOn({arg vel, note, ch, src;s.sendMsg(\n_set, 1010,\mFrq, note.midicps)});
		//MIDIFunc.noteOff({arg vel, note, ch, src;s.sendMsg(\n_set, 1010,\mFrq, note.midicps)});
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \mFB, val.linlin(0,127,0,2.0))},~mFbCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \freq, val.linlin(0,127,10,20000.0))},~freqCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \fB, val.linlin(0,127,0,2.0))},~fbCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \width, val.linlin(0,127,0,2.0))},~widthCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \mul, val.linlin(0,127,0,20000.0))},~mulCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \ffreq, val.linexp(0,127,20,20000.0))},~ffreqCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \rq, val.linlin(0,127,0.0,2.0))},~rqCC);
);
}

/*

	// With Voicer, requiere dependencies installed from Quarks

~voice = Voicer(8, "feedbackOsc");
~keyboard = VoicerMIDISocket([\all, \omni], ~voice);
~voice.free;~keyboard.free;
~voice.panic;

	(
		~keyboard.addControl(2, \mFB, 0, [0, 2.0, \linear] );
		~keyboard.addControl(4, \mFrq, 0, [10,10000,\exponential] );
		~keyboard.addControl(3, \fB, 0, [0,2.0,\linear]);
		~keyboard.addControl(10, \width, 0, [0.01,2.0,\exponential]);
		~keyboard.addControl(9, \mul, 0, [0, 20000, \exponential] );
		~keyboard.addControl(11, \ffreq, 0, [10, 20000, \exponential]);
		~keyboard.addControl(12, \rq, 0, [0.01,1.2,\exponential]);
	//	~keyboard.addControl(13, \rq, 0, [1,1000.0,\exponential]);
);

	*/