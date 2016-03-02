//=========================================================================================================================
// MIDI

MIDIClient.init;
MIDIIn.connectAll;
/*
MIDIIn.connect; // 1 port midi interface
MIDIClient.destinations;

q=MIDIFunc.cc({arg ...args; args.postln});
q.free;
o=MIDIFunc.noteOn({arg vel, note, ch, src;[vel, note, ch, src].postln});
p=MIDIFunc.noteOff({arg ...args; args.postln});
q=MIDIFunc.cc({arg ...args; args.postln});
r=MIDIFunc.touch({arg ...args; args.postln}); // match any ch
m=MIDIFunc.bend({arg ...args; args.postln}); // match any ch
n=MIDIFunc.program({arg ...args; args.postln}); // match any ch
[o,p,q,r,m,n].free;
MIDIIn.sysex = { arg uid, packet; [uid,packet].postln };
MIDIIn.sysrt = { arg src, chan, val;  [src, chan, val].postln; };
MIDIIn.smpte = { arg src, chan, val;  [src, chan, val].postln; };
*/
(
//MIDIIn.connect();    // init for one port midi interface
// register functions:
~noteOff = { arg src, chan, num, vel;    ["noteOff: ", src,chan,num,vel / 127].postln; };
~noteOn = { arg src, chan, num, vel;    ["noteOff: ", src,chan,num,vel / 127].postln; };
~polytouch = { arg src, chan, num, vel;    ["polyTouch: ", src,chan,num,vel / 127].postln; };
~control = { arg src, chan, num, val;    ["control: ", src,chan,num,val].postln; };
~program = { arg src, chan, prog;        ["program: ", src,chan,prog].postln; };
~touch = { arg src, chan, pressure;    ["touch: ", src,chan,pressure].postln; };
~bend = { arg src, chan, bend;        ["bend: ", src,chan,bend - 8192].postln; };
~sysex = { arg src, sysex;        sysex.postln; };
~sysrt = { arg src, chan, val;        [src,chan,val].postln; };
~smpte = { arg src, chan, val;        [src,chan,val].postln; };
MIDIIn.addFuncTo(\noteOn, ~noteOn);
MIDIIn.addFuncTo(\noteOff, ~noteOff);
MIDIIn.addFuncTo(\polytouch, ~polytouch);
MIDIIn.addFuncTo(\control, ~control);
MIDIIn.addFuncTo(\program, ~program);
MIDIIn.addFuncTo(\touch, ~touch);
MIDIIn.addFuncTo(\bend, ~bend);
MIDIIn.addFuncTo(\sysex, ~sysex);
MIDIIn.addFuncTo(\sysrt, ~sysrt);
MIDIIn.addFuncTo(\smpte, ~smpte);
);
/*
(
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.removeFuncFrom(\polytouch, ~polytouch);
MIDIIn.removeFuncFrom(\control, ~control);
MIDIIn.removeFuncFrom(\program, ~program);
MIDIIn.removeFuncFrom(\touch, ~touch);
MIDIIn.removeFuncFrom(\bend, ~bend);
MIDIIn.removeFuncFrom(\sysex, ~sysex);
MIDIIn.removeFuncFrom(\sysrt, ~sysrt);
MIDIIn.removeFuncFrom(\smpte, ~smpte);
);
*/
/*
// kill all
16.do{|i|m.allNotesOff(i)};

*/