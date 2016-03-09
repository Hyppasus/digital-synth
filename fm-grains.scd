/*
// keep going with wavetables
*/
Server.default.waitForBoot{


	s = Server.default;



SynthDef(\fmgrains, {arg gate = 1, amp = 1, envbuf= -1, freq=440, freqdevRate=1, trigger=1, dur=0.1, freqMod=0, index=0, pan=0, ffreq=1000, rq=1, saturation=0.9, keyTrack=0;
    var env, freqdev, sig;
    freqdev = WhiteNoise.kr(freqdevRate);
    env = EnvGen.kr(Env([0, 1, 0], [1, 1], \sin, 1),gate, levelScale: amp,doneAction: 2);
	sig = GrainFM.ar(2, Impulse.kr(trigger), dur, freq + freqdev, freqMod, index, pan, envbuf) * env;
		sig = RLPFD.ar(sig, ffreq*keyTrack, rq, saturation);
	Out.ar(0,sig);
    }).add;



	"synth loaded".postln;
	s.sync;


	MIDIClient.init;
	MIDIIn.connectAll;


	~freqdevRate = 2;
	~triggerCC = 4;
	~freqModCC = 3;
	~durCC = 5;
	~indexCC = 9;
	~panCC = 10;
	~ffreqCC = 11;
	~rqCC = 12;
	~modeCC = 13;
	~saturationCC = 1;
	~ampCC = 7;
	~keyTrackCC = 83;

	s.sync;
(
		s.sendMsg(\s_new, "fmgrains", 1010, 1, 1);
		MIDIFunc.noteOn({arg vel, note, ch, src;s.sendMsg(\n_set, 1010,\freq, note.midicps)});
		//MIDIFunc.noteOff({arg vel, note, ch, src;s.sendMsg(\n_set, 1010,\mFrq, note.midicps)});
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \freqdevRate, val.linlin(0,127,0.0,1000))},~freqdevRate);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \trigger, val.linlin(0,127,1.0,40))},~triggerCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \freqMod, val.linexp(0,127,1,20000))},~freqModCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \dur, val.linlin(0,127,0.01,0.5))},~durCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \index, val.linlin(0,127,0,20.0))},~indexCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \pan, val.linlin(0,127,-1,1.0))},~panCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \ffreq, val.linexp(0,127,20,20000.0))},~ffreqCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \rq, val.linlin(0,127,0.0,2.0))},~rqCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \mode, val.linlin(0,127,0.0,4.0))},~modeCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \saturation, val.linlin(0,127,0.0,10.0))},~saturationCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \amp, val.linlin(0,127,0.0,1.0))},~ampCC);
		MIDIFunc.cc({|val,num,ch,src|s.sendMsg(\n_set, 1010, \keyTrack, val.linlin(0,127,0,2.0))},~keytrackCC);
		MIDIFunc.bend({|val,num,ch,src|s.sendMsg(\n_set, 1010, \bend, val.linlin(0,16384,0,1200))});
	);
}




