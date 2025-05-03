# A trivial Protools to Pyramix session media name converter.

For the script to be effective the recording session in Pro Tools™ has to be conducted in a certain way and there are certain limitations, at least in its current state reflecting my current (mostly classical) production needs.

## Assumptions these scripts make

For a typical classical production I'm making the following assumptions:

* A recording take always includes the whole set of mics and is a contiguous fragment of music.
* The micing and track layout do not change across all of the takes in a piece (this means you need to rehearse and set your track layout in stone before you start making production takes.
* There are no overdubs, punch-ins, or any other "studio techniques", just plain multitrack takes of differing length.
* A recording may contain multiple pieces (say, movements of a quartet, choral pieces, a symphony and so on).
* All movements are numbered and marked accordingly in your scores. Say, as an example we'll record two violin concertos and during our recording sessions and we'll number the movements accordingly:
  * 01 — Concerto 1: mvt 1.
  * 02 — Concerto 1: mvt 2.
  * 03 — Concerto 1: mvt 3.
  * 04 — Concerto 2: mvt 1.
  * 05 — Concerto 2: mvt 2.
  * 06 — Concerto 2: mvt 3.

* A limitation of the current version of the script requires that all tracks in the recording session are either mono (multi-mono) or stereo (multi-stereo). Please do not mix mono and stereo tracks, pleae do not multi-channel tracks for now. The script has a few variants depending whether your source material is recorded in multi-mono, multi-stereo, of "PT fake stereo" files using the "L/R" naming convention. Currently you need to manually choose the proper version of the script.

## Pro Tools™ track naming

Keeping the above assumptions in mind, please name your tracks in a PT session the following way initially:

```
01-01
01-02
01-03
|   |
|   +-> track/mic number
+-----> piece/movement number
```

After you've named your tracks you'll make a new playlist for each take you
record, so after you've recorded a take, you need to make it a habit to press
the "new playlist" shortcut for each new take (typically `Ctrl-\`). If you
forget, you can still press the shortcut after you've already started recording
a take.

After you've created a playlist, you'll notice that the track names reflect the
current playlist/take number which is very useful when you need to glance in
the DAW while taking notes in your score, to make you're you know which take
you're currently recording.

The tracks headers (and files) will be named as such:

```
01-01.03
01-02.03
01-03.03
      |
      +-> current take number
```

When reviewing previous takes for reference of for the musicians during your
recording session it's super-easy to quickly jump/scroll across your recorded
takes by holding `shift-up` or `shift-down`.

## Running the script

The script requires a unixy environment to run (WSL/WSL2/Linux/macOS) and bash is used the following way:

For convenience cd to you Pro Tools™ project directory first and create a destination directory, say: 

```
$ mkdir /Volumes/foo/your/destination/directory/for/pyramix
```

Run the script from their location:

```
$ /path/to/CONVERT-TO-PYRAMIX.sh Audio\ Files /Volumes/foo/your/destination/directory/for/pyramix
```

The script does a dry-run first displaying the discovered pieces and tracks:

```
$ CONVERT-STEREO-TO-PYRAMIX.sh /Volumes/foo/2025-05-02-bar/Audio\ Files /tmp/Pyramix-Media
Found the following pieces:
01

Found the following tracks:
01
02
03
04
05

Changing directory to /Volumes/foo/2025-05-02-bar/Audio Files.
REAL SRC IS:  01-01.01_01.wav
WOULD MOVE L: /var/folders/tm/blyq9bw909z219k15wxkqll80000gn/T/tmp.ixvTmlSFct.wav /private/tmp/Pyramix-Media/01_take_01_01_##001##_.wav
WOULD MOVE R: /var/folders/tm/blyq9bw909z219k15wxkqll80000gn/T/tmp.EwmudfSPI6.wav /private/tmp/Pyramix-Media/01_take_01_01_##002##_.wav
REAL SRC IS:  01-01.02_02.wav
WOULD MOVE L: /var/folders/tm/blyq9bw909z219k15wxkqll80000gn/T/tmp.nQVQWUgNKv.wav /private/tmp/Pyramix-Media/01_take_02_02_##001##_.wav
WOULD MOVE R: /var/folders/tm/blyq9bw909z219k15wxkqll80000gn/T/tmp.btXks2hVbU.wav /private/tmp/Pyramix-Media/01_take_02_02_##002##_.wav
REAL SRC IS:  01-01.03_03.wav
WOULD MOVE L: /var/folders/tm/blyq9bw909z219k15wxkqll80000gn/T/tmp.MXYWC0pMO8.wav /private/tmp/Pyramix-Media/01_take_03_03_##001##_.wav
WOULD MOVE R: /var/folders/tm/blyq9bw909z219k15wxkqll80000gn/T/tmp.XX3jhBahLn.wav /private/tmp/Pyramix-Media/01_take_03_03_##002##_.wav
REAL SRC IS:  01-01.04_04.wav
```

If the output looks correct (double check the discovered "pieces" and "tracks"), please add the `doit` flag to the script invocation to actually do its job:

```
$ CONVERT-STEREO-TO-PYRAMIX.sh /Volumes/foo/2025-05-02-bar/Audio\ Files /tmp/Pyramix-Media doit
```

