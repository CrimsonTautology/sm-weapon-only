# sm-weapon-only

![Build Status](https://github.com/CrimsonTautology/sm-weapon-only/workflows/Build%20plugins/badge.svg?style=flat-square)
[![GitHub stars](https://img.shields.io/github/stars/CrimsonTautology/sm-weapon-only?style=flat-square)](https://github.com/CrimsonTautology/sm-weapon-only/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/CrimsonTautology/sm-weapon-only.svg?style=flat-square&logo=github&logoColor=white)](https://github.com/CrimsonTautology/sm-weapon-only/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/CrimsonTautology/sm-weapon-only.svg?style=flat-square&logo=github&logoColor=white)](https://github.com/CrimsonTautology/sm-weapon-only/pulls)
[![GitHub All Releases](https://img.shields.io/github/downloads/CrimsonTautology/sm-weapon-only/total.svg?style=flat-square&logo=github&logoColor=white)](https://github.com/CrimsonTautology/sm-weapon-only/releases)

Fistful of Frags plugin to force players to use one type of weapon only.  Allows for dual wielding the same type of weapon.


## Requirements
* [SourceMod](https://www.sourcemod.net/) 1.10 or later


## Installation
Make sure your server has SourceMod installed.  See [Installing SourceMod](https://wiki.alliedmods.net/Installing_SourceMod).  If you are new to managing SourceMod on a server be sure to read the '[Installing Plugins](https://wiki.alliedmods.net/Managing_your_sourcemod_installation#Installing_Plugins)' section from the official SourceMod Wiki.

Download the latest [release](https://github.com/CrimsonTautology/sm-weapon-only/releases/latest) and copy the contents of `addons` to your server's `addons` directory.  It is recommended to restart your server after installing.

To confirm the plugin is installed correctly, on your server's console type:
```
sm plugins list
```

**Optional:** Make a new directory on your server `custom/hl2weapons` and the copy the contents of `scripts` to it to enable Half Life 2 weapons.  These weapons are extremly buggy so do this at your own risk.

## Usage


### Commands
NOTE: All commands can be run from the in-game chat by replacing `sm_` with `!` or `/`.  For example `sm_rtv` can be called with `!rtv`.

| Command | Accepts | Values | SM Admin Flag | Description |
| --- | --- | --- | --- | --- |
| sm_only | None | None | Slay | Set to one type of weapon only. |
| sm_give | None | None | Slay | Give yourself a weapon |


### Console Variables

| Command | Accepts | Values | Description |
| --- | --- | --- | --- |
| sm_weapon_only | boolean | 0-1 |  Set to 1 to enable the weapon only plugin |
| sm_weapon_only_weapon | string | `weapon_*` |  The class name of the weapon (e.g. `weapon_remington_army`) |


## Compiling
If you are new to SourceMod development be sure to read the '[Compiling SourceMod Plugins](https://wiki.alliedmods.net/Compiling_SourceMod_Plugins)' page from the official SourceMod Wiki.

You will need the `spcomp` compiler from the latest stable release of SourceMod.  Download it from [here](https://www.sourcemod.net/downloads.php?branch=stable) and uncompress it to a folder.  The compiler `spcomp` is located in `addons/sourcemod/scripting/`;  you may wish to add this folder to your path.

Once you have SourceMod downloaded you can then compile using the included [Makefile](Makefile).

```sh
cd sm-weapon-only
make SPCOMP=/path/to/addons/sourcemod/scripting/spcomp
```

Other included Makefile targets that you may find useful for development:

```sh
# compile plugin with DEBUG enabled
make DEBUG=1

# pass additonal flags to spcomp
make SPFLAGS="-E -w207"

# install plugins and required files to local srcds install
make install SRCDS=/path/to/srcds

# uninstall plugins and required files from local srcds install
make uninstall SRCDS=/path/to/srcds
```


## Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


## License
[GNU General Public License v3.0](https://choosealicense.com/licenses/gpl-3.0/)
