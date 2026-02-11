---
geometry: margin=4cm
title: Image analysis
date: \today
author: Jun Ishigohoka
colorlinks: true
linkcolor: blue
urlcolor: blue
numbersections: true
fontsize: 11pt
linestretch: 1
linkReferences: true
nameInLink: true
header-includes:
  - |
    \usepackage{xcolor}
    \usepackage{framed}
    \definecolor{shadecolor}{gray}{0.95}
    \renewenvironment{Shaded}{\begin{shaded}}{\end{shaded}}
    \usepackage{float}
    \floatplacement{figure}{H}

figPrefix:
  - "Fig. "
  - "Figs. "

tblPrefix:
  - "Table "
  - "Tables "

---






\pagenumbering{arabic}
\setcounter{page}{1}


# Introduction

We use [`FIJI`](https://imagej.net/software/fiji/) to detect pupae, and a custom `FIJI` macro to measure pixel intensity inside the pupae over time.
Before eclosion, flies in pupal cases are (or more acurately, they become) pigmented.
After eclosion the pupal case is empty and becomes semi-transparent.
Eclosion events will be detected based on the change in pixel intensity between time points.
Here, I describe how to use `FIJI` and custom macros to analyse images.


# Overview

1. Pre-process images
1. Identify pupae in one image ("reference") and save the position and shape of them as ROIs (Regions Of Interest).
1. Measure pixel intensity in ROIs over all time points.




# Pre-requisites

- Install `FIJI` and `EclosionMonitorJ` macros on your computer (`fiji.pdf`).
- Have time-lapse images taken by the recording box in one folder (`eclosion_monitor.pdf`).

# Pre-process images

We will apply a macro (`PrepJpg`) to pre-process all images.
`FIJI` sometimes crashes while doing this if we have too many images with large size.
To avoid this, we first resize all images.


## Resize images

1. In a `UNIX`-based system (e.g. MPI Bio server using `PuTTY` from a `Windows` machine), navigate to your directory where you have a folder containing the raw images using `cd` command.

    ```bash
    cd ~/projects/eclosion/rec_016_plate
    ls
    ```
    ```
    rec_016_2025-11-10-15-29-30
    ```
In this example, I am in directory `~/projects/eclosion/rec_016_plate`, within which there is a subdirectory `rec_016_2025-11-10-15-29-30`, where raw images are stored.

1. Make a folder for resized images.

    ```bash
    mkdir resized
    ```

1. Run `convert` command to resize the image for each of all jpeg files in the directory.

    ```bash

    for file in rec_016_2025-11-10-15-29-30/*jpeg
    do
        echo $file
        prefix=`echo $file | sed 's@rec_016_2025-11-10-15-29-30/@@;s@.jpeg@@'`
        echo $prefix
        convert $file -resize 50% resized/${prefix}_resized.jpg
    done

    ```

1. Once done, resized images are in the `resized` folder.


## Run `PrepJpeg`

1. Make a new folder "for_analysis" to put pre-processed images.

    ```bash
    mkdir for_analysis

    ```

1. Open `FIJI`.
1. In the search bar (or `Ctrl`+`L`) search "PrepJpg" ([@fig:prepjpg1]). Click "Run".

    ![`PrepJpg`](images/PrepJpg_1.png){#fig:prepjpg1 width=75%}


1. A window "Choose Input Directory" will pop up.
Select the `resized` folder and click "Select".
1. A new window asking you to specify the index of first JPG file will pop up. 
    - If you want to pre-process all images in the `resized` folder, type 0.
    - If you want to pre-process images taken in a specific time period, identify the 0-based index of the first JPG (based on the dictionary order) and type this index in the box.

    Click "OK".

1. A new window asking you to specify the index of the last JPG file will pop up.
    - If you want to pre-process all images in the `resized` folder, type the number of JPG files - 1 (99 if there are 100 files).
    - If you want to pre-process images taken in a specific time period, identify the 0-based index of the last JPG and type this index in the box.

    Click "OK".

1. A new window "Choose Output Directory" will pop up.
Select the `for_analysis` folder and click "Select".
1. `PrepJpg` will start running.
It will make each image into 8-bit (i.e. 256 shades of gray), invert it (dark background with white pupae), and perform background subtraction (does not matter much for 96-well plates).
1. Once complete, a message window will pop up ("PrepJpg is completed")
Pre-processed images are in the `for_analysis` folder.



## Remove dark images

The recording box has two LED strips: white and red.
White light is for "day" and is on 7:20 - 19:20 (UTC + 1).
Red light for "night" and is on 19:20 - 7:20 (UTC + 1).
These two LEDs are controlled by two separate analog timer switches, and the transition between the day and night is not perfect.
In some boxes, there are periods of a few minutes when both lights are off, and when an image is taken during this period, completely dark image is recorded.
This will affect later analysis.

To resolve this, manually remove dark images.
In the `for_analysis` folder, check all images taken at 07:20 and 19:20, and if they are black, delete them.


# Prepare reference

1. Make a new directory `ref`.

    ```bash
    mkdir ref
    ```

1. In the `for_analysis` folder, select one image before the first eclosion as a reference.
Night time shortly before the first eclosion is recommended.
1. Copy this image to the `ref` folder.

    ```bash
    cp for_analysis/2025_11_10_15_30_resized.jpg ref/
    ```

1. Open this image in `FIJI`. (`Ctrl`+`O`).
1. To adjust threshold, press `Ctrl`+`Shift`+`T` (or Image > Adjust > Threshold...).
Drag the top slider (low threshold) so that pupae are recognisable ([@fig:thre]).

    ![Threshold.](images/threshold.png){#fig:thre width=75%}

1. Click "Apply"
1. Save the thresholded image in `ref`. Click File > Save as, then save it as e.g. `2025_11_10_15_30_resized_threshold.jpg`


# Detect pupae

1. In `FIJI`, open the threshold-adjusted reference image.
1. To detect particles, Click Analyse > Analyze Particles...
Set the values as in [@fig:particles], then click "OK".

    ![Analyze Particles.](images/analyse_particles.png){#fig:particles width=50%}

1. ROI manager window will pop up and detected particles will be indicated as ROIs on the image ([@fig:rois0]).
They do not have to be perfect but have to be good enough.
    - If there are too many small errors, close ROI manager (without saving), and run "Analyze Particles" again with a larger minimum value of the size parameter.
    - If there are too many pupae undetected, eclose ROI manager (without saving), and run "Analyze Particles" again with a smaller minimum value of the size parameter.

    ![Pupae detected by the particle analyzer.](images/rois_ori.png){#fig:rois0 width=75%}

1. Save ROIs from the ROI Manager window by clicking More > Save As.
1. Close ROI Manager and the threshold-adjusted image.
1. Still in `FIJI`, open non-threshold-adjusted reference image and the ROI set.
    - In ROI Manager, make sure that both "Show All" and "Labels" are ticked.
1. Maually add and delete ROIs.
    - To add a ROI, use the freehand selection tool ([@fig:freehand]), then press `T`.
    - To delete a ROI, click on the label of the ROI, and press `del` .

    ![Freehand selection tool.](images/freehand.png){#fig:freehand}
1. Save manually corrected ROIs from ROI Manager window by clicking More > Save As.
1. Close ROI Manager and image.


# Measure pupae

1. In `FIJI`, search for the `MeasurePupae` macro in the search bar, and click "Run".

    ![`MeasurePupae` macro.](images/measure_pupae_1.png){#fig:measurepupae1}

1. A new window "Choose folder" will pop up.
Choose the `for_analysis` folder where all processed images are stored, and click "Select".
1. A new window "Select ROI set" will pop up.
Choose the manually corrected ROI set, and click "Open".
1. Analysis will start, with a new "Results" window open ([@fig:measurepupae2]). Wait until it is done.

    ![`MeasurePupae` running.](images/measure_pupae_2.png){#fig:measurepupae2}

1. Once completed, a new window saying "Measuring Pupae completed" will pop up.
1. Confirm that results.csv has been created in `for_analysis` folder ([@fig:resultscsv]).

    ![results.csv](images/results_csv.png){#fig:resultscsv width=75%}



# Prepare the position information of pupae

We will need to match the ROIs representing pupae to the well of the plate.

## Plate

1. In `FIJI`, open the reference image.
1. Using the multi-point tool, mark the centre of each well following A1, B1, C1, ..., H11, H12 ([@fig:multipoint]).

    ![Multi-point tool to mark wells.](images/well_points.png){#fig:multipoint width=75%}

1. To save the points 
    1. Click Analayze > Tools > ROI Manager
    1. Click Add in ROI manager. The added ROI contains all points you added.
    1. Click in ROI Manager, More > Save... and save the points.
1. To measure the coordinate of these 96 points,
    1. Click Analyze > Set Measurements...
    1. Tick "centroid" and "Display label" ([@fig:setmeasurement]), and click OK.

    ![Set Measurements...](images/set_measurements.png){#fig:setmeasurement width=75%}

    1. Measure the coordinates by clicking Analyze > Measure.
    1. A Results window will open ([@fig:wellsresults])

    ![Results window](images/wells_results.png){#fig:wellsresults width=75%}

    1. Click File > Save As... then save it as a csv.



## Pupae

1. In `FIJI`, open the reference image and the ROI set for pupae.
1. To measure the coordinate of pupae
    1. Click Analyze > Set Measurements...
    1. Tick "centroid" and "Display label", and click OK.
    1. Measure the coordinates by clicking Analyze > Measure.
    1. A Results window will open 
    1. Click File > Save As... then save it as a csv.



# What's next?

- `eclosion_detection.pdf`


