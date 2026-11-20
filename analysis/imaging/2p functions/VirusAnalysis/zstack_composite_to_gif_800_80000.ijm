// zstack_composite_to_gif.ijm
// For every pair  <name>_1.tif (red) + <name>_2.tif (green)  in a folder:
//   1. merge as composite (red/green assignment set by file1IsRed below)
//   2. set display range 800-80000 on both channels
//   3. save composite as acq#_zstack_composite_300min_30000max.tif
//   4. convert to RGB color and save as .gif with the same name
// acq# = last underscore section of the base name (007 -> 7, 012 -> 12)

minVal = 800;
maxVal = 80000;

// Which file is red? Set to true if the _1 file should be red, false if the _2 file should be red.
file1IsRed = false;

dir = getDirectory("Choose folder containing the _1.tif / _2.tif files");
list = getFileList(dir);
setBatchMode(true);
count = 0;

for (i = 0; i < list.length; i++) {
    f1 = list[i];
    if (!endsWith(f1, "_1.tif")) continue;

    base = substring(f1, 0, lengthOf(f1) - 6);   // e.g. 100226_ASW150E24_000_007
    f2 = base + "_2.tif";
    if (!File.exists(dir + f2)) {
        print("Skipping " + f1 + " (no matching _2.tif)");
        continue;
    }

    parts = split(base, "_");
    acq = parseInt(parts[parts.length - 1]);      // parseInt drops leading zeros
    if (isNaN(acq)) {
        print("Skipping " + f1 + " (could not read acquisition number)");
        continue;
    }
    outName = "acq" + d2s(acq, 0) + "_zstack_composite_" + minVal + "min_" + maxVal + "max";

    open(dir + f1);
    open(dir + f2);

    // c1 = red, c2 = green
    if (file1IsRed)
        run("Merge Channels...", "c1=[" + f1 + "] c2=[" + f2 + "] create");
    else
        run("Merge Channels...", "c1=[" + f2 + "] c2=[" + f1 + "] create");

    // set min/max on each channel
    Stack.getDimensions(w, h, nCh, nSl, nFr);
    for (c = 1; c <= nCh; c++) {
        Stack.setChannel(c);
        setMinAndMax(minVal, maxVal);
    }

    // save composite
    saveAs("Tiff", dir + outName + ".tif");

    // convert to RGB (all slices) and save as GIF
    run("RGB Color", "slices");
    saveAs("Gif", dir + outName + ".gif");

    run("Close All");
    count++;
    print("Done: " + outName);
}

setBatchMode(false);
print("Finished. Processed " + count + " pair(s).");
