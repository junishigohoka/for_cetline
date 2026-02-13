---
geometry: margin=4cm
title: Eclosion recording
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

We have camera-based recording boxes to record eclosion behaviour.







# Materials

- Pupae sample (films or 96-well plates)
- A red marker
- Transparent tape


# Introduction to the recording box

The recording box consists of

1. a sealed black box
1. white and red LED strips
1. a camera
1. a horizontal plate on which sample is set

We now have 8 recording boxes (`box1` through `box8`) monitored by 4 Raspberry Pi computers (`rpi1` through `rpi4`) ([@tbl:comps]).
Each box has a camera on the bottom (facing up).
The cameras are controlled by the Raspberry Pi computers.
The 4 Raspberry Pi are controlled by another Raspberry Pi (`rpi0`. i.e. You start and stop recording from `rpi0` by accessing `rpi1-4`).
LED lights are controlled by analog timer switches, not computers.


| Computer      | Function |
| ----------- | ----------- |
| `rpi0`| Controls `rpi1`, `rpi2`, `rpi3`, `rpi4`|
| `rpi1`| Controls cameras of `box1`, and `box2` |
| `rpi2`| Controls cameras of `box3`, and `box4` |
| `rpi3`| Controls cameras of `box5`, and `box6` |
| `rpi4`| Controls cameras of `box7`, and `box8` |

: Computers {#tbl:comps}




Each box holds a semi-opaque or transparent rectangular plate ("recording plate").
You can place 96-well plates with fly pupae on top of the transparent plate or overhead films with pupae on the bottom of the semi-opaque plate.

[TODO: Images]



# Methods



## Set up box

1. Take the recording plate from the recording box to the fly room (0.03).
1. In the fly room, 
    - Film: 
        - Remove films from the vials.
        - Remove remaining fly food on the film using tissue paper.
        - Attach films on the bottom side of the recording plate using transparent tapes
    - 96-well plate
        - Write the sample info with a red marker on transparent tape and put it next to the 96-well plate on the recording plate
1. Transfer the recording plate with samples to the incubating chamber.^[Use trays to avoid pupae falling on the floor]
1. Place the recording plate with the sample in the box.


## Log in {#sec:login}

![Computers and commands](images/comps.jpg){#fig:comps width=75%}

Inside the incubating chamber, we have a screen, a keyboard, and a mouse.
They are connected to `rpi0`.
The computers are always on, so you do not have to boot it.
 
1. Turn on the screen. The switch is behind the screen at the bottom right corner.
1. Open a terminal by pressing `Ctrl`+`Alt`+`T`.
1. In terminal, log in to the focal Raspberry Pi (e.g. box 1 -> rpi1, box4 -> rpi2 etc) by entering the following command. Change `rpi1` to one of `rpi1`, `rpi2`, `rpi3`, `rpi4`.

    ```bash
    ssh junishigohoka@rpi2
    ```

1. You will be asked for password. Type `pi` and press Enter.
1. Confirm that you see something like the following in terminal.
This means that any command you run in this terminal will be run not in `rpi0` but in `rpi2`.

   ```
   junishigohoka@rpi2:~ $
   ```
This tells you that you have logged in as user `junishigohoka` to computer `rpi2`.

1. In terminal type the following and enter

    ```bash
    tmux a
    ```
`tmux` is a program to manage multiple sessions and windows inside the terminal. `a` stands for "attach". The entire command re-attaches you to pre-existing TMUX session that I made before.
1. You will see a green bar at the bottom of the window ([@fig:tmux])with

    ```
    [boxes] 0:box3*  1:box4-
    ```

    ![Green bar indicating the TMUX session](images/tmux_bar.jpg){#fig:tmux width=75%}  

    The presence of the green bar indicates that you are in a TMUX session that I set up on the `rpi`.
    `[boxes]` means that you are in a session called "boxes".^[If you see something else like `[seadrive]` let me know].
    `0:box3* 1:box4-` means that within this session, there are two windows called `box1` and `box2`.
    The asterisk after `box3` means that you are viewing the window `box3` of this session.
    You can change the window between the two by pressing `Ctrl`+`B` then `N`.
    Confirm that the asterisk moves between the two window names.




Now you are ready to start or stop recording of the box you are focusing in the window.


## Log out {#sec:logout}


Let's assume we are in window `box3` of session `boxes` in computer `rpi2`, and we want to log out.

1. Confirm that you stil see the green bar at the bottom (i.e. You are in a TMUX session).
1. Dettach from the session by `Ctrl`+`B` then `D`.
1. Confirm that you do not see the green bar at the bottom, and the last line of termianl says `junishigohoka@rpi2`.
1. Log out from `rpi2` by `Ctrl`+`D`.
1. Confirm that the last line of the terminal is `jun@rpi0` (You are in `rpi0`).


## Start recording

Let's say we want to start recording of `box3`.
We will use a custom script `eclosion_monitor.sh` to start recording.

1. Log in to `rpi-2`, then attach the `boxes` session, and move to window `box3`. See [@sec:login] for details.
1. To see how to use `eclosion_monitor.sh`, type the following.

    ```bash
    eclosion_monitor.sh -h
    ```
It will show the following.

    ```
    Usage: eclosion_monitor.sh [OPTIONS]
        
    Options:
      -b, --box        Select camera (3 or 4)
      -s, --starttime  Start time in "YYYY-MM-DD HH:mm"
      -d, --dirout     Path to output directory
      -i, --interval   Interval of recording in second
      -r, --recid      Recording ID
      -h, --help       Show this help message

    ```

1. To start recording in `box3`, make sure that you are in window `box3` (i.e. `box3*` in the green bar at the bottom), then type the following command

    ```bash
    eclosion_monitor.sh -b 3 -s "2026-02-04 11:30" \
                        -i 600 -r rec_044 \
                        -d ~/seadrive/My\ Libraries/my_projects/fly/eclosion_monitors 
    ```

    ![`eclosion_monitor.sh` command to start recording](images/command.jpg)  

    This will start recording in `box3` (`-b`) from 2026-02-04 11:30 (`-s`).
    An image will be taken every 600 seconds (`-i`).
    All images will be stored in Jun's Keeper: a new folder starting with recording  ID "`rec_044`" (`-r`) will be created inside `/My\ Libraries/my_projects/fly/eclosion_monitors` [TODO: link], and pictures will be transferred to the folder.
    Change the options `-b -s -i -r` according to your recording.
    Do not change the `-d` option.

1. Confirm that the recording is running ([@fig:running])

    ![Screen when recording is running.](images/running_monitor.jpg){#fig:running}

1. The above command will first take an image `rec_044_init.jpeg`.
Access the file in Keeper and check whether the focus is correct.
If not, stop the recording (see [@sec:stop]), and re-run the command.
1. Dettach from the TMUX session and log out from `rpi2` following [@sec:logout].
1. Close the terminal
1. Turn off the display




## Stop recording {#sec:stop}

Let's say we want to stop a recording that is running in `box5`, which is controlled by `rpi3`.

1. Log in to `rpi3`, attach to the TMUX session `boxes`, and move to window `box5`. See [@sec:login] for details.
1. Confirm that the recording is still running ([@fig:running]). 
1. Stop `eclosion_monitor.sh` by pressing `Ctrl`+`C`.
1. Confirm that it has stopped. The last line of the window should be

    ```
    junishigohoka@rpi3:~$
    ```

1. Dettach from the TMUX session and log out from `rpi3` following [@sec:logout].
1. Eclose the terminal
1. Turn off the display
1. Take out the plate and sample from the box.


# What's next?

- `image_analysis.pdf`
