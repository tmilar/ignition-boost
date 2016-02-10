#==============================================================================
# ** TDD Plugins Module -  Setup File
#------------------------------------------------------------------------------
# Description
# ===========
# This file holds references to other scripts to be loaded, including
# order information, etc.
#==============================================================================
#==================+
# Folder structure |
#==================+
# The first thing we want to do is set up our folder structure. We do this by
# creating a hash. An explanation can be found below this structure
#------------------------------------------------------------------------------


plugins = {
    "lib" => {
        "misc" => {},
        "util" => {
            exclude: ["print_backtrace"]
        },
    },
    "config" => {
        order: ["module_IB", :rest],
        exclude: ["original_levels", "original_levels_clean", "original_levels_new", "ib_config_original"]
    },
    "src" => {
        exclude: ["old"],
        "screen" => {},
        "movement" => {
            order: ["movement", "keyboard_movement", "zig_zag_movement", :rest]
        },
        "ship" => {
            order: ["ship", :rest]
        },
        "enemy" => {},
        "player" => {},
        "weapon" => {
            order: ["weapon", :rest]
        },
        "bullet" => {},
        "spawner" => {
            "phase" => {},
            order: ["spawner", :rest]
        },
        "powerup"=> {
            order: ["power_up", :rest]
        }
    }
}

# Folder structure explanation |
#==============================+
# Hashes are key/value pairs of data. The way this is used for the Plugin
# Framework is relatively simple. A string ("string text") denotes a subfolder
# in the Plugin Framework root folder. This is a folder that resides in
# <Your Project/Data>. In the demo project, this folder is
# <Plugin Test/Data/Plugins>
#
# If you look at the first line within the plugins hash, it looks like this:
#
# "Global Settings" => {},
# "Global Settings" refers to the folder with the same name within the
# Plugins folder. The arrow (=>) sets the value to an empty hash ({}) in this
# example. We do this because folders can have options applied to them, like
# ordering the scripts files within them, and nested folders. Let's look at the
# next folder definition for an example.
#
# ------------------------------.
# "Example 1" => {              |
#   "classes" => {},            |
#   "modules" => {              |
#     exclude: ["exclude me"]   |
#   }                           |
# },                            |
# ------------------------------'
#
# Here we see that within the folder "Example 1", we nest two sub-folders:
# "classes" and "modules". "classes" is the defined as earlier with no options,
# while "smodules" has an option called exclude:
# exclude: is a symbol; it could also be written as :exclude =>
# in the example above, but exclude: is simply shorthand for that.
# The exclude: option takes an array (a comma separated list of values inside
# [] brackets) of file which you do not wish to load. This can be very useful
# if you're debugging your game, so that you don't have to go in and delete the
# script file, or comment it out in any way.
#
# ------------------------------.
# "Example 2" => {              |
#   order: [                    |
#   "data",                     |
#   :rest,                      |
#   "insert last"               |
#   ]                           |
# },                            |
# ------------------------------'
#
# In this third example, we introduce a new option called order:
# Similar to exclude:, this is an array that can hold a list of files within
# that given folder which you prefer to load in a set order; all files not
# listed will be loaded alphabetically after the listed files.
# However, for added configurability, you can use a symbol titled :rest within
# this list of files, and what this will do is make sure that all files listed
# above it are loaded in the given order first, then all files listed below it
# listed in the given order, and remaining files loaded alphabetically in
# between (the "rest" of the files, hence :rest).
# This might seem very complicated, but it's a useful feature. Often there are
# scripts that must be loaded after all other scripts that affect the same
# functionality. The same goes for scripts needed to be loaded before all other
# scripts. This way, you can make sure that order is retained for such scripts,
# but without having to type all the files in between that are inconsequential
# to ordering. This is one of the headaches of the built-in script editor that
# spurred me to create this framework.
#
# ------------------------------.
# "Example 3" => {              |
#   "sub 1" => {                |
#     "sub 2" => {}             |
#   }                           |
# }                             |
# ------------------------------'
#
# In the last example, we nest a subfolder ("sub 2") within another subfolder
# ("sub 1") beneath the "Example 3" folder, this time with no options.
#==============================================================================
#=======================+
# Configuration of path |
#=======================+
# The following should be set to the folder within your project's Data folder
# where the plugin folders and plugin framework resides. The below value is
# default and where it's placed in the Plugins Framework demo project.
# You don't specify your project's folder name nor the data folder; only the
# subfolder. "Plugins" is therefore actually "Your Project/Data/Plugins".
ROOT_PATH = "ignition-boost"

#======================================+
# Loading the Plugins Framework module |
#======================================+
# We then load the plugins module file so that we can use the Plugins module.
# This should not be changed.
load_script "Data/#{ROOT_PATH}/plugins_module.rb" # Do not edit


#============================================+
# Setting up and starting the Plugins module |
#============================================+
# We tell the plugins module where the root path is (the folder where these
# files resist within your project's Data folder, specified earlier). This is
# necessary because we need absolute paths if we encrypt our game later on.
Plugins.root_path = ROOT_PATH

# We then load the folder structure we made earlier using the
# load_recursive method
Plugins.load_recursive(plugins)

# Then we package all plugin scripts into a single scripts.rb file. This is
# also necessary for this to work when we encrypt our game.
Plugins.package

# Finally we load the packaged scripts.rb file into Ace.
load_script("Data/#{ROOT_PATH}/target/target.rb")