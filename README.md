# protools-to-pyramix
A simple Protools to Pyramix session media name converter

This is a rather trivial bash script that I decided to write when yet again confronted with migrating my ugly ProTools sessions into Pyramix.

As we well know naming takes in ProTools is shit, but as long as you keep some discipline this script will help you migrate your ProTools mess of wav files into neatly grouped takes in Pyramix.

There's a number of assumptions here that you'll see when I explain the working of the script, feel free to modify/pull request if you have better ideas how to handle different scenarios.

I'm assuming a trivial "rectangular" session structure, where we're dealing with a single "piece" and identical track structure for each take.

In such case, let's say we have the following WAV file structure in ProTools:

```
Cb_01.wav       Cb_02.wav       Cb_03.wav       Cb_04.wav
Piano-L_01.wav  Piano-L_02.wav  Piano-L_03.wav  Piano-L_04.wav
Piano-R_01.wav  Piano-R_02.wav  Piano-R_03.wav  Piano-R_04.wav
Vocal_01.wav    Vocal_02.wav    Vocal_03.wav    Vocal_04.wav
```

There are four takes (01 to 04) recorded across four tracks (Cb, Piano-L, Piano-R, Vocal)

To translate this into Pyramix, we need to add a "take name" for the takes and a mapping between Protools track names, to Pyramix track number in a multitrack take.

For this file I would create the following mapping file (tracks 1 & 2 for the piano, track 3 for Cb and track 4 for Vocal, or any other order we want):

```
Piano-L
Piano-R
Cb
Vocal
```

Which should end up with the following takes visible in Pyramix, given the "My-Song" name for the takes:

```
My-Song_001
My-Song_002
My-Song_003
My-Song_004
```

With the actual (hidden from Pyramix) multiple-mono-wav file structure being:

```
My-Song_001_##01##_.wav
My-Song_001_##02##_.wav
My-Song_001_##03##_.wav
My-Song_001_##04##_.wav
My-Song_002_##01##_.wav
My-Song_002_##02##_.wav
My-Song_002_##03##_.wav
My-Song_002_##04##_.wav
My-Song_003_##01##_.wav
My-Song_003_##02##_.wav
My-Song_003_##03##_.wav
My-Song_003_##04##_.wav
My-Song_004_##01##_.wav
My-Song_004_##02##_.wav
My-Song_004_##03##_.wav
My-Song_004_##04##_.wav
```

The script requires a unixy environment to run (WSL/WSL2/Linux/macOS) and bash and takes the following arguments:

```
Usage: ./protools-to-pyramix.sh <MAPFILE> <NO_OF_TAKES> <SRC_DIR> <DST_DIR> <NAME> [yes]
```

Where <MAPFILE> is the above mentions mapping-file, <NO_OF_TAKES> is the number of takes in the original PT session, <SRC_DIR> and <DST_DIR> are self-explanatory, the final "yes" argument is required to actually perform the action, without it the script will perform a dry-run and only print the actions it would do, so that you can visually inspect the 'mv' commands and see if everything looks legit.
