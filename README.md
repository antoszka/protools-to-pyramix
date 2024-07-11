# protools-to-pyramix
A simple Protools to Pyramix session media name converter.

For the script to be effective the recording session in Pro Tools™ has to be conducted in a certain way and there are certain limitations, at least in its current state reflecting my actual production needs.

1. bla bla

Which should end up with the following takes visible in Pyramix, given the `My-Song` name for the takes:

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

Where `<MAPFILE>` is the above mentions mapping-file, `<NO_OF_TAKES>` is the number of takes in the original PT session, `<SRC_DIR>` and `<DST_DIR>` are self-explanatory, `<NAME>` is the song/take name and the final optional `yes` argument is required to actually perform the action, without it the script will perform a dry-run and only print the actions it would do, so that you can visually inspect the 'mv' commands and see if everything looks legit.

For example:

```
./protools-to-pyramix.sh ../mapping 42 /mnt/d/pt-sessions/foo-bar "/mnt/e/Foo Bar/Media Files" yes
```
