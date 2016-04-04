
Server.default.waitForBoot{

    s = Server.default;

(
SynthDef(\freqMod, {|out=0, carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, index=1, offset=10, release=0.1, ffreq = 10000, rq = 1, morphing = 0,amp=1, pan=0, vol=0.5|
    //var sin = SinOsc.kr(modFreq,0,index,offset);
    //var carrier= SinOsc.ar(carFreq+sin);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	var carrier = PMOsc.ar(carFreq, modFreq, index);
	var filter1 = DFM1.ar(carrier, ffreq, rq);
    var filter2 = BMoog.ar(carrier, ffreq, rq, offset, 0.5);
	//var filter1 = LPF.ar(carrier, ffreq, rq);
	//var filter2 = HPF.ar(carrier, ffreq, rq);
	var output = XFade2.ar (filter1, filter2, morphing,);
	Out.ar(out,Pan2.ar(output,pan,env*amp*vol));
}).add;
);

    s.sync;

    s.sendMsg(\g_new, 2000, 1, 1);
    MIDIClient.init;
    MIDIIn.connectAll;


    ~modFreqCC = 9;
    ~indexCC = 10;
    ~offsetCC = 7;
    ~ffreqCC = 11;
    ~rqCC = 12;
    ~morphCC = 13;
    ~attackCC = 16;
    ~decayCC = 17;
    ~sustainCC = 18;
    ~releaseCC = 19;

    ~rqPot = 1;
    ~morphPot = 0;
    ~attackPot = 0.1;
    ~decayPot = 1;
    ~sustainPot = 1;
    ~releasePot = 2;
    ~modFreqPot =1;
    ~indexPot = 0;
    ~offsetPot = 1;
    ~ffreqPot = 440;

    s.sync;
(

        MIDIFunc.noteOn({arg vel, note, ch, src;s.sendMsg(\s_new, "freqMod", s.nextNodeID, 1, 2000,\carFreq, note.midicps, \rq, ~rqPot, \morph, ~morphPot, \modFreq, ~modFreqPot, \index, ~indexPot, \offset, ~offsetPot, \ffreq, ~ffreqPot, \attack, ~attackPot, \decay, ~decayPot, \susatin, ~sustainPot, \release, ~releasePot,\amp, vel.linlin(0,127,0,1))});
        MIDIFunc.noteOff({arg vel, note, ch, src;s.sendMsg(\n_set,2000 ,\gate, 0)});
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,5,1000.0); ~modFreqPot = store; s.sendMsg(\n_set, 2000, \modFreq, store)},~modFreqCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0,2*pi);~indexPot=store; s.sendMsg(\n_set, 2000, \index, store)},~indexCC);
        MIDIFunc.cc({|val,num,ch,src|var store = val.linlin(0,127,0,1000); ~offsetPot=store; s.sendMsg(\n_set, 2000, \offset, store )},~offsetCC);
        MIDIFunc.cc({|val,num,ch,src|var store = val.linlin(0,127,30,3000.0);~ffreqPot = store; s.sendMsg(\n_set, 2000, \ffreq,store )},~ffreqCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0,1); ~rqPot = store; s.sendMsg(\n_set, 2000, \rq, store)},~rqCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,-1,1);~morphPot = store;  s.sendMsg(\n_set, 2000, \morphing,store )},~morphCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0.01,3);~attackPot = store; s.sendMsg(\n_set, 2000, \attack,store )},~attackCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0.1,1);~decayPot =store; s.sendMsg(\n_set, 2000, \decay,store )},~decayCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0,10);~sustainPot =store; s.sendMsg(\n_set, 2000, \sustain,store )},~sustainCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0.1,10);~releasePot =store; s.sendMsg(\n_set, 2000, \release,store )},~releaseCC);
);
}