#==============================================================================
# ** TDD Plugins Module - Blank Setup File
#------------------------------------------------------------------------------
# Description
# ===========
# This is a minified setup file without all the comments and descriptions. If
# you want to use it in your project instead of the inflated default setup.rb
# file, just delete setup.rb and rename this file into setup.rb
#==============================================================================
plugins = {
    "src" => {order: ["IB_BOSS_module",
                      "IB_BOSS_game"  ]
    }

}

ROOT_PATH = "ignitionBoost"
load_script "Data/#{ROOT_PATH}/plugins_module.rb" # Do not edit


Plugins.root_path = ROOT_PATH
Plugins.load_recursive(plugins)
Plugins.package
load_script("Data/#{ROOT_PATH}/target.rb")