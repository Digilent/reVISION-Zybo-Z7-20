# Zybo Z7-20 reVISION Platform
Created for SDx 2017.4, Vivado 2017.4, and Petalinux 2017.4

## Downloading and Using the Platform

Please click on the releases tab in github to download the latest release for 
your version of SDx. A README.txt is included with the release that describes 
how to use the SDSoC platform.

## Platform Sources

This repository is used by Digilent to version control all the sources used to 
create the platform. It contains the Vivado IPI project, an SDx platform 
generator project and a Petalinux project. The SDSoC platform generator project 
also contains a submodule with a port of the Xilinx xfopencv libraries and a 
submodule with the Digilent prepared xfopencv samples. These parts all come 
together to form the reVISION Platform.

Advanced users who wish to make modifications to this platform or use it as a
reference are welcome to. This may be a challenging task for beginners, If you 
need help please feel free to reach out on https://forum.digilentinc.com.

## Included Documentation

This document contains a procedure for building all the sources and generating 
the output platform, however there are several other useful documents in this 
repo.
       
##### petalinux_notes.txt
   
   This document describes the modifications that needed to be made to the 
   standard Petalinux project for this board in order to work with SDSoC and 
   xfopencv.

##### linux/README.md
   
   The standard README that ships with Digilent Petalinux projects. It contains 
   useful information for using and building the included Petalinux project.

##### sdsoc/README.txt
   
   The README.txt that is included with the platfrom release. It contains
   instructions for how to use the built platform in SDx to design SDx 
   applications. It should be referred to by those interested in only using the
   platform.
  
## Known Issues

1. In the Vivado block diagram, typically the processing system IP core will 
   infer a BUFG on the FCLK signals. For some reason, this is occuring for 
   FCLK0 only. FCLK2 seems to be getting a BUFG added during implementation, so 
   it doesn't cause any issues for that net, but FCLK 1 was being
   routed as a normal signal (not on the global clock network). This caused 
   insanely long build times and failure to meet timing. The current work around
   is to manually insert a BUFG on FCLK1 using a util_ds_buf IP core.

2. Audio is not functional


3. The included vivado project has several critical warnings that complain about
   negative values in the DDR parameters. These can be safely ignored. The 
   warnings look similar to:

```
PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_* has negative value...
```

4. Board files and IP repo are forked and locally included with the Vivado 
   project. It should be possible to reduce redundancy by including them both as
   submodules.

5. Currently we have not been able to get the Zybo Z7-20 to boot with a rootfs 
   this large in initramfs mode. Our work around is to use an SD rootfs loaded 
   on the second partition of the SD card. This allows for larger file system 
   space, persistent changes, and more available system memory, but requires 
   additional steps to prepare the SD card. Since the rootfs is not altered by 
   SDx, a user of this platform should only have to flash the SD card once. 

# Building the Platform

        WARNING*** You must have obtained this package using "git clone --recursive 
        https://github.com/Digilent/reVISION-Zybo-Z7-20.git" or else these instructions 
        will not work.

## Prerequisites

1. Host computer running Ubuntu 16.04.3 LTS 

2. Xilinx SDx 2017.4 installed to /opt/Xilinx/SDx/

3. Petalinux 2017.4 installed to /opt/pkg/petalinux/

4. Package must have been obtained using 
   "git clone --recursive https://github.com/Digilent/reVISION-Zybo-Z7-20.git" or 
   else these instructions will not work.

        NOTE*** This procedure assumes some basic experience with Vivado IP Integrator 
        and PetaLinux.

## Procedure     

1. If you have built the Vivado IPI project at least once and it has not changed
   since the last build you can skip this step. Otherwise do the following:
    
    1. Open a terminal and run "source /opt/Xilinx/SDx/2017.4/settings64.sh"

    2. cd into the vivado/zybo_z7_20/ folder

    3. Run "./cleanup.sh" at the terminal if you have pulled remote changes 
       since the last time you have built the project. If you have not pulled 
       any changes to the vivado project from git or it is your first time 
       building the project then you do not need to run the script.

    4. run "vivado" at the terminal to open Vivado. 

    5. Click Open Block Design in the flow navigator. You can modify the design 
       if you like at this point. 
  
    6. Generate the bitstream, relaunching synthesis and implementation.
    
    7. Open the Implemented Design and then click File->Export->Hardware. 
       Include the bitstream and save it to the hw_handoff folder. Overwrite
       the existing file.

    8. At the tcl console in vivado, run "source ./create_dsa.tcl". Ignore 
       warnings that say that the design has changed since last build.
   
    9. Close Vivado and the terminal. You don't have to save the block diagram 
       if asked, the create_dsa.tcl script needlessly makes it dirty.

2. If changes have been made to the petalinux project or it has not been built 
   yet since cloning this repo, the following must be done:

    1. Open a new terminal and run "source /opt/pkg/petalinux/settings.sh".

    2. cd into the linux/Zybo-Z7-20/ directory of this repo. Run 
       "petalinux-config --get-hw-description=../../hw_handoff" and exit the
       menu that opens.
   
    3. Additional changes to the petalinux project can be made at this time, as 
       needed.

    4. Build the project using petalinux-build.

    5. Close the terminal 

3. Open a terminal and cd into the sdsoc/zybo_z7_20/resources/ folder.

4. Run "./copy_files.sh". If errors are reported that files do not exist, then 
   step 1 or 2 likely needs to be rerun.

5. cd to your home directory and run 
   "source /opt/Xilinx/SDx/2017.4/settings64.sh"

6. run "sdx" to open SDx

7. Choose the sdsoc folder of this repo as your workspace.

8. Click Import Project on the Welcome screen. In the window that opens, select
   the sdsoc folder as the root directory and click finish to import the 
   zybo_z7_20 platform project.

9. In the Project Explorer pane, double click platform.spr in the zybo_z7_20
   project. Changes, such as adding library and include paths, can be made to
   the platform at this point. See UG1146 from Xilinx for information on using
   this tool to define the SDSoC platform.

10. Click the hammer in the zybo_z7_20 pane to generate the platform.

11. Open a new terminal (outside SDx) and cd into the sdsoc folder. Run the 
    following:

        sudo ./finalize_platform.sh

    If you will be doing a release (see the next section) then you should run 
    the script with a single argument that indicates the release number to also
    generate a release package in sdsoc/zybo_z7_20/export/. For example:

        sudo ./finalize_platform.sh 1
  
    
12. The platform is now ready to use! It can be found in sdsoc/zybo_z7_20/export/.
    In order to use it, you must exit SDx and create a new, empty workspace. 
    Then follow the steps included in the platform's README.txt to create and 
    run a sample program.

        WARNING*** Make sure you use a new, empty workspace, not the workspace 
                   with the platform generator project. SDx currently has a bug 
                   that breaks the ability to hardware accelerate functions in a
                   platform's include path when that platform's project is also 
                   in the workspace.
    
## Platform Release Procedure  

The following procedure describes how to push your modifications back to the 
Digilent github (or a fork hosted elsewhere) and generate a release package.

1. cd to the root folder of this repo (reVISION-Zybo-Z7-20). Run git status to
   see if any changes have been made to the project. If it appears generated 
   files, logs, or other unneeded files are seen in the git status output,
   then .gitignore should be modified to exclude them. Do not check in 
   unneeded files. 

2. Use "git add ." and "git commit" to commit the changes

3. Run git status again. If it reports that the linux submodule has changes
   then run the following:
       
        cd linux
        git checkout -b revision <skip this step if already done since cloning the repo>
        git status <check to make sure that only needed files will be commited, change .gitignore if not>
        git add . 
        git commit <write a commit message for the Petalinux submodule>
        git push -u origin revision
        cd ..
        git add linux
        git commit <write commit message that indicates "updated linux submodule">

4. If git status indicates there are changes to another submodule, then 
   rerun step 3 for it to push the changes. It is likely that the branch
   name in the checkout and several other steps will need to change.
   
5. cd back to the repo's root directory, ensure that all changes are commited, 
   and push the commits to github.

6. Create a github release that targets the most recent commit and attach 
   the sdsoc/zybo_z7_20/export/reVISION-Zybo-Z7-20-20XX.X-Y.zip file to it
   (see step 12 of previous section if it doesn't exist).


