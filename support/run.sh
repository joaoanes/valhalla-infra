#!/bin/bash

export TEMP_PATH=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
# without this, steam loads the wrong ELF file,
# resulting in a server not being discoverable
export SteamAppId=892970
# shellcheck disable=SC2154
# shellcheck disable=SC2086
{
    ./valheim_server.x86_64 -name "${server_name}" -port 2456 -nographics \
        -batchmode -world "${world_name}" -password "${server_password}"
}
export LD_LIBRARY_PATH=$TEMP_PATH
