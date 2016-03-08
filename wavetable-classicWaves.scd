/*
// keep going with wavetables
*/
Server.default.waitForBoot{

	var tables = 8;
	var wavetableSize = 1024;
	s = Server.default;


	SynthDef(\vosc,{ |outbus=0, gate=1, amp=1.0, bufoffset=0, bufoffsetMod=8, freq=440, detune=1, freqMod=1, detuneMod=0,  mul=0, add=10, ffreq=10000, rq=0, mode=0, saturation=0.95, keyTrack=1|
		var env, sig, modulator;
		env = EnvGen.ar(Env.asr(0.01, 1, 0.01), gate, doneAction:2);
		modulator = VOsc.ar(bufoffsetMod, [freqMod, freqMod + detuneMod], 0, mul, add);
		sig =  VOsc.ar(bufoffset, [freq, freq + detune] + modulator);
		//sig = MoogLadder.ar(sig, ffreq+(freq*keyTrack), rq, saturation);
		sig = MoogVCF.ar(sig, ffreq+(freq*keyTrack), rq, saturation);
		//sig = (sig * env * amp).tanh;
		sig = (sig * env * amp);
		Out.ar(outbus, sig)
		}).add;


	s.sync;

	tables.do{|i|currentEnvironment.put(("buf"++i).asSymbol, Buffer.alloc(s, wavetableSize*2, bufnum:i);)};

	s.sync;

	~buf0.setn(0, Signal.sineFill(wavetableSize, [1.0]).asWavetable);//sine
	~buf1.setn(0, Env([0]++ [-1, 0, 1]++(0), [0.1, 0.1, 0.1, 0.1],\lin).asSignal(wavetableSize).asWavetable);//triangle
	~buf2.setn(0, Env([0]++ [-1, 1]++(0), [0.0, 0.1, 0.0],\lin).asSignal(wavetableSize).asWavetable);//ramp
	~buf3.setn(0, Signal.sineFill(wavetableSize, 1.0/(1..wavetableSize)).asWavetable);//saw tooth
	~buf4.setn(0, Env([0, -1, 1], [0.1, 0.1],\step).asSignal(wavetableSize).asWavetable);//square
	~buf5.setn(0, Env([0]++ Array.rand(10,-1,1.0)++(0), Array.rand(11,0.01,1.0),Array.fill(11,{[\lin, \sin, \wel].choose})).asSignal(wavetableSize).asWavetable);// random1
	~buf6.setn(0, Env([0]++ Array.rand(100,-1,1.0)++(0), Array.rand(101,0.01,1.0),Array.fill(101,{[\lin, \sin, \wel].choose})).asSignal(wavetableSize).asWavetable);//random2
	~buf7.setn(0, Env([0]++ Array.rand(510,-1,1.0)++(0), Array.rand(511,0.01,1.0),Array.fill(511,{[\lin, \sin, \wel].choose})).asSignal(wavetableSize).asWavetable);//random3



	"tables loaded".postln;
	s.sync;


	MIDIClient.init;
	MIDIIn.connectAll;
	//s.sendMsg(\s_new, "feedbackOsc", 1010, 1, 1);

	~detuneCC = 2;
	~bufoffsetCC = 4;
	~freqModCC = 3;
	~bufoffsetModCC = 5;
	~detuneMod = 9;
	~mulCC = 10;
	~addCC = 8;
	~ffreqCC = 11;
	~rqCC = 12;
	~modeCC = 13;
	~saturationCC = 1;
	~ampCC = 7;
	~keyTrackCC = 83;

	s.sync;
(
		s.sendMsg(\s_new, "vosc", 1010, 1, 1);
		MIDIFunc.noteOn({arg vel, note, ch, src;s.sendMsg(\n_set, 1010,\freq, note.midicps)});
		//MIDIFunc.noteOff({arg vel, note, ch, src;s.sendMsg(\n_set, 1010,\mFrq, note.midicps)});
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \bufoffset, val.linlin(0,127,0.0,tables-2))},~bufoffsetCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \bufoffsetMod, val.linlin(0,127,0.0,tables-2))},~bufoffsetModCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \detune, val.linlin(0,127,0,100))},~detuneCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \detuneMod, val.linlin(0,127,0,100))},~detuneModCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \freqMod, val.linexp(0,127,1,20000))},~freqModCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \mul, val.linlin(0,127,0,20000.0))},~mulCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \add, val.linlin(0,127,0,20000.0))},~addCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \ffreq, val.linexp(0,127,20,20000.0))},~ffreqCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \rq, val.linlin(0,127,0.0,2.0))},~rqCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \mode, val.linlin(0,127,0.0,4.0))},~modeCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \saturation, val.linlin(0,127,0.0,10.0))},~saturationCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \amp, val.linlin(0,127,0.0,1.0))},~ampCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \keyTrack, val.linlin(0,127,0,2.0))},~keytrackCC);

	);
}


