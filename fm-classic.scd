
Server.default.waitForBoot{

    s = Server.default;

(
SynthDef(\freqMod, {|out=0, mFrq= 313, sinFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, mul=100, add=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    var sin = SinOsc.kr(sinFreq,0,mul,add);
    var osc= SinOsc.ar(mFrq+sin);
    var filter1 = DFM1.ar(osc, ffreq, rq);
    var filter2 = BMoog.ar(osc, ffreq, rq, 2,0.5);
    var output = XFade2.ar (filter1, filter2, morphing,);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
    Out.ar(out,output*env*0.1*amp);
}).add;
);

    s.sync;

    s.sendMsg(\g_new, 2000, 1, 1);
    MIDIClient.init;
    MIDIIn.connectAll;


    ~sinFreqCC = 0;
    ~mulCC = 1;
    ~addCC =2;
    ~ffreqCC = 3;
    ~rqCC = 4;
    ~morphCC = 5;
    ~attackCC = 9;
    ~sustainCC = 10;
    ~decayCC = 11;
    ~releaseCC = 12;
    ~rqPot = 1;
    ~morphPot = 0;
    ~attackPot = 0.1;
    ~decayPot = 1;
    ~sustainPot = 1;
    ~releasePot = 2;
    ~sinFreqPot =1;
    ~mulPot = 0;
    ~addPot = 1;
    ~ffreqPot = 440;

    s.sync;
(

        MIDIFunc.noteOn({arg vel, note, ch, src;s.sendMsg(\s_new, "freqMod", s.nextNodeID, 1, 2000,\mFrq, note.midicps, \rq, ~rqPot, \morph, ~morphPot, \sinFreq, ~sinFreqPot, \mul, ~mulPot, \add, ~addPot, \ffreq, ~ffreqPot, \attack, ~attackPot, \decay, ~decayPot, \susatin, ~sustainPot, \release, ~releasePot,\amp, vel.linlin(0,127,0,1))});
        MIDIFunc.noteOff({arg vel, note, ch, src;s.sendMsg(\n_set,2000 ,\gate, 0)});
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,5,1000.0); ~sinFreqPot = store; s.sendMsg(\n_set, 2000, \sinFreq, store)},~sinFreqCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,3,1000);~mulPot=store; s.sendMsg(\n_set, 2000, \mul, store)},~mulCC);
        MIDIFunc.cc({|val,num,ch,src|var store = val.linlin(0,127,0,1000); ~addPot=store; s.sendMsg(\n_set, 2000, \add, store )},~addCC);
        MIDIFunc.cc({|val,num,ch,src|var store = val.linlin(0,127,30,3000.0);~ffreqPot = store; s.sendMsg(\n_set, 2000, \ffreq,store )},~ffreqCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0,1); ~rqPot = store; s.sendMsg(\n_set, 2000, \rq, store)},~rqCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,-1,1);~morphPot = store;  s.sendMsg(\n_set, 2000, \morphing,store )},~morphCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0.01,3);~attackPot = store; s.sendMsg(\n_set, 2000, \attack,store )},~attackCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0.1,1);~decayPot =store; s.sendMsg(\n_set, 2000, \decay,store )},~decayCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0,10);~sustainPot =store; s.sendMsg(\n_set, 2000, \sustain,store )},~sustainCC);
        MIDIFunc.cc({|val,num,ch,src|var store =val.linlin(0,127,0.1,10);~releasePot =store; s.sendMsg(\n_set, 2000, \release,store )},~releaseCC);
);
}