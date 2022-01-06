# Windows 10 Home 20H2 (19042.1415)

Razer Blade 15" gaming laptop upgrades with 64GB of RAM. 

## Usage

We are going to run the script `../src/test_32GB_write_feather.R` in RStudio. Ideally this should be done via command line for any automated testing. 

## SessionInfo

```
> sessionInfo()
R version 4.1.2 (2021-11-01)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19042)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252 
[2] LC_CTYPE=English_United States.1252   
[3] LC_MONETARY=English_United States.1252
[4] LC_NUMERIC=C                          
[5] LC_TIME=English_United States.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

loaded via a namespace (and not attached):
 [1] tidyselect_1.1.1  bit_4.0.4         compiler_4.1.2    magrittr_2.0.1   
 [5] assertthat_0.2.1  R6_2.5.1          tools_4.1.2       glue_1.6.0       
 [9] rstudioapi_0.13   bit64_4.0.5       vctrs_0.3.8       data.table_1.14.2
[13] arrow_6.0.1       rlang_0.4.12      purrr_0.3.4      
```

## memory.limit()

```
> memory.limit()
[1] 65438
```

## Run 1

The first run starts with an empty tmp directory and was done after a reboot so RAM and PageFile are nice and clean. It's using the default windows Page File setting which allows windows to auto-configure it. Usually decent, but in this case it doesn't know how to handle the large desire for a ton of virtual memory. 

At this point I wasn't sure there was an issue with the PageFile so didn't check to see how big it was. However we ran into the scenario mentioned in the github issue. Eventually the RStudio app gets into the following state

1. No CPU usage
2. No Disk usage
3. RStudio "hangs" (doesn't error out)
4. When RStudio is terminated, the resulting file buffer flushed to disk is a "random" size 

PRE:     06GB RAM,  ??GB PF, ~00GB fakeFile.csv,  ~00GB fakeFile.feather
FWRITE:  64GB RAM,  ??GB PF, ~44GB fakeFile.csv,  ~00GB fakeFile.feather
FEATHER: 64GB RAM,  ??GB PF, ~44GB fakeFile.csv, ~100MB fakeFile.feather <--- hangs
POST:    64GB RAM,  ??GB PF, ~44GB fakeFile.csv,  ~10GB fakeFile.feather <--- flushes out ??? bytes

I was forced to kill RStudio, and after doing so, it appears that windows flushed out some amount of data from the process to disk. In this case ~10GB

## Run 2

The second run was done using the same setup above to see if there were any inconsistencies between runs. 

Again, a very similar scenario to what was reported in the github ticket:

1. No CPU usage
2. No Disk usage
3. RStudio "hangs" (doesn't error out)
4. When RStudio is terminated, the resulting file buffer flushed to disk is a "random" size (10GB for the first run 6GB for the second run)

PRE:     06GB RAM,  10GB PF, ~00GB fakeFile.csv, ~00GB fakeFile.feather
FWRITE:  64GB RAM,  10GB PF, ~44GB fakeFile.csv, ~00GB fakeFile.feather
FEATHER: 14GB RAM,  10GB PF, ~44GB fakeFile.csv, ~01GB fakeFile.feather <--- hangs
POST:    16GB RAM,  10GB PF, ~44GB fakeFile.csv, ~06GB fakeFile.feather <--- flushes out ??? bytes

In the scenario above windows had allocated ~10GB page file. I don't remember the tool to monitor the usage outside of generic disk monitoring but further investigation could be done to track down exact usage. 

The key takeaway is that once windows has exhausted all available RAM + PageFile configured for the virtual memory space... results are unknown. =*( Ran into a similar scenario when writing out HDF5 using python vs native C/C++, I required 92GB of Page File to complete writing out the options data for a couple hundred symbols once a second or something along those lines. Using the raw C/C++ implementation of HDF5 it took under 100MB of memory as the underlying memory was re-used and cleaned up as the data was streamed to disk. 

## run 3 

The third run was done after a reboot of the OS to clear out RAM and to update the windows PageFile to make use of 64GB of disk on the nVME device.

PRE:     06GB RAM,  64GB SWP, ~00GB fakeFile.csv, ~00GB fakeFile.feather
FWRITE:  64GB RAM,  64GB SWP, ~44GB fakeFile.csv, ~00GB fakeFile.feather
FEATHER: 64GB RAM,  64GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather
POST:    64GB RAM,  64GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather

These results are very much in line with what was shown on MacOSX 12.1 with 32GB of RAM + a dynamically allocated 32GB of SWP. It took a bit longer and showed a lot of disk activity, but a similarish-sized feather file is created and RStudio closes out cleanly. 

## run 4

The third run was done after a reboot of the OS to clear out RAM and make sure the PageFile is re-initialized.

PRE:     06GB RAM,  64GB SWP, ~00GB fakeFile.csv, ~00GB fakeFile.feather
FWRITE:  64GB RAM,  64GB SWP, ~44GB fakeFile.csv, ~00GB fakeFile.feather
FEATHER: 64GB RAM,  64GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather
POST:    64GB RAM,  64GB SWP, ~44GB fakeFile.csv, ~15GB fakeFile.feather

As per the two runs shown on MacOSX 12.1, both the fwrite and feather files are created without issues and they are the exact same size.

## file output size compare

You will notice that for all 3 runs, the files written with fwrite are the exact same size. While the feather files for the first two runs are "random" sizes due to the application hanging with no CPU or disk usage and RStudio having to be force killed.

The final 2 runs show the feather files are the exact same byte size ~14GB and were done with the windows PageFile set to 64GB to allow R/RStudio to access a larger segment of virtual memory.

```
rockhowse@LAPTOP-MNO4NC13:/mnt/c/Projects/vdl/testing_32GB_files$ ls -al -- | grep fakeFile
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  5 20:45 fakeFile.csv
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  3 21:39 fakeFile.csv.001
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  5 20:36 fakeFile.csv.002
-rwxrwxrwx 1 rockhowse rockhowse 46826002293 Jan  5 20:36 fakeFile.csv.003
-rwxrwxrwx 1 rockhowse rockhowse 15785280458 Jan  5 20:48 fakeFile.feather
-rwxrwxrwx 1 rockhowse rockhowse 10902065712 Jan  3 21:42 fakeFile.feather.001
-rwxrwxrwx 1 rockhowse rockhowse  6724271952 Jan  5 20:25 fakeFile.feather.002
-rwxrwxrwx 1 rockhowse rockhowse 15785280458 Jan  5 20:39 fakeFile.feather.003
```