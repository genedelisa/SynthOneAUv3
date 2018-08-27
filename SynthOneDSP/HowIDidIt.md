# How I did it
## Victor Frankenstein

### The AUv3 Frob

The goal is to have the App work just like it does now. So it needs access to the existing code.
(Which is has right now)

There needs to be an audio unit app extension. This extension needs access to the existing code. Extensions do not automatically get access.

So, an embedded framework needs to be created that is used by the containing app and the extension. Actually, two frameworks would be the right thing: an iOS UI framework and a DSP framework. In the future, a macOS version can reuse the DSP framework.

Step 1 is to create the DSP framework and have the iOS code stay in place and have the app run just like it does.
(I tried doing both frameworks right away, but there is a special kind of linkage hell trying to do everything at once)


#### project creation


23403  2018-07-08 06:41:09    git clone https://github.com/aure/AudioKitSynthOne.git
23405  2018-07-08 06:41:32    cd AudioKitSynthOne/
23408  2018-07-08 06:41:51    git pull origin develop
23409  2018-07-08 06:47:35    git log --oneline --decorate
23410  2018-07-08 06:53:10    git log --oneline --decorate --graph --all
23415  2018-07-09 07:36:10    git checkout -b auv3
23416  2018-07-09 07:36:13    git branch -a
23417  2018-07-09 07:36:21    git status
23418  2018-07-09 08:01:48    pod install
23420  2018-07-09 08:03:14    open AudioKitSynthOne.xcworkspace/



#### framework creation


* created objective-c embedded framework

* moved DSP contents except conductor

* moved audio unit, kernel, note state, rate, taae

* changed target for each file

* made headers public

* added imports to SynthOneDSP.h

* imported bridging header since OneSignal compilation fails

``
 <unknown>:0: error: using bridging headers with framework targets is unsupported
``

 moved bridging header out of dsp
 
 framework has no bridging header now since that is not allowed


Now this:

<pre>
/Users/gene/Development/Apple/AK1/AudioKitSynthOne/SynthOneDSP/SynthOneDSP.h:60:9: note: in file included from /Users/gene/Development/Apple/AK1/AudioKitSynthOne/    SynthOneDSP/SynthOneDSP.h:60:

#import <SynthOneDSP/S1AudioUnit.h>
>         ^
/Users/gene/Development/Apple/AK1/AudioKitSynthOne/SynthOneDSP/Audio Unit/S1AudioUnit.h:11:9: error: 'AudioKit/AKAudioUnit.h' file not found

#import <AudioKit/AKAudioUnit.h>
         ^
<unknown>:0: error: could not build Objective-C module 'SynthOneDSP'
</pre>

So, I guess the framework needs AudioKit set as a dependency via cocoapods.
(I could just set the search paths instead)

created pod target for the framework

``
 target 'SynthOneDSP' do
 etc
``

Now linkage gripes for TAAE

<pre>
Undefined symbols for architecture arm64:
"_AEArrayGetToken", referenced from:
S1DSPKernel::process(unsigned int, unsigned int) in S1DSPKernel+process.o
S1DSPKernel::heldNotesDidChange() in S1DSPKernel+didChanges.o
S1DSPKernel::turnOffKey(int) in S1DSPKernel+toggleKeys.o
"_OBJC_CLASS_$_AEArray", referenced from:
objc-class-ref in S1DSPKernel.o
"_AEArrayGetCount", referenced from:
S1DSPKernel::process(unsigned int, unsigned int) in S1DSPKernel+process.o
S1DSPKernel::heldNotesDidChange() in S1DSPKernel+didChanges.o
"_AEArrayGetItem", referenced from:
S1DSPKernel::process(unsigned int, unsigned int) in S1DSPKernel+process.o
</pre>

D'oh. Didn't add it to the proper target.



* added appropriate import SynthOneDSP statements to containing project classes
* Made SDSustainer a public class

It builds!

It crashes!

There are a bunch of these statements:

<pre>
ABMultiStreamBuffer is implemented in both /private/var/containers/Bundle/Application/E2A12262-EA89-4FE2-94C3-D40F1327A22C/AudioKitSynthOne.app/Frameworks/SynthOneDSP.framework/SynthOneDSP (0x1023fd0d8) and /var/containers/Bundle/Application/E2A12262-EA89-4FE2-94C3-D40F1327A22C/AudioKitSynthOne.app/AudioKitSynthOne (0x101154e80). One of the two will be used. Which one is undefined.
</pre>


which might be the cause of this:


<pre>
Conductor.swift:start():117:Logging is ON
libc++abi.dylib: terminating with uncaught exception of type NSException
(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = signal SIGABRT
frame #0: 0x00000001816752ec libsystem_kernel.dylib`__pthread_kill + 8
frame #1: 0x0000000181816288 libsystem_pthread.dylib`pthread_kill$VARIANT$mp + 376
frame #2: 0x00000001815e3d0c libsystem_c.dylib`abort + 140
frame #3: 0x0000000180d7e2c8 libc++abi.dylib`abort_message + 132
frame #4: 0x0000000180d7e470 libc++abi.dylib`default_terminate_handler() + 304
frame #5: 0x0000000180da88d4 libobjc.A.dylib`_objc_terminate() + 124
frame #6: 0x0000000180d9837c libc++abi.dylib`std::__terminate(void (*)()) + 16
frame #7: 0x0000000180d98400 libc++abi.dylib`std::terminate() + 84
frame #8: 0x0000000180da8830 libobjc.A.dylib`objc_terminate + 12
frame #9: 0x000000010334d1b0 libdispatch.dylib`_dispatch_client_callout + 36
frame #10: 0x00000001033597cc libdispatch.dylib`_dispatch_block_invoke_direct + 232
frame #11: 0x0000000184423878 FrontBoardServices`__FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 36
frame #12: 0x000000018442351c FrontBoardServices`-[FBSSerialQueue _performNext] + 404
frame #13: 0x0000000184423ab8 FrontBoardServices`-[FBSSerialQueue _performNextFromRunLoopSource] + 56
frame #14: 0x0000000181b97404 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
frame #15: 0x0000000181b96c2c CoreFoundation`__CFRunLoopDoSources0 + 276
frame #16: 0x0000000181b9479c CoreFoundation`__CFRunLoopRun + 1204
frame #17: 0x0000000181ab4da8 CoreFoundation`CFRunLoopRunSpecific + 552
frame #18: 0x0000000183a99020 GraphicsServices`GSEventRunModal + 100
frame #19: 0x000000018bad1758 UIKit`UIApplicationMain + 236
* frame #20: 0x0000000100b784e8 AudioKitSynthOne`main at AppDelegate.swift:13
frame #21: 0x0000000181545fc0 libdyld.dylib`start + 4
(lldb) 
</pre>


Updated Framework build settings for
C Language Dialect and C++ Language Dialect to match container app

crash

set a breakpoint at Conductor: 138 

crashes on

``
AudioKit.output = synth
``

About that duplicate thing: I tried various frobs to the Podfile

e.g. The DSP target requiring AudioKit and AudioBus but not the containing app
No change even with deleting derived data and cleaning



