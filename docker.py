#!/usr/bin/python
# -*- encoding: utf-8 -*-

import json
import subprocess
import argparse

def RunCommand(command):
    result = subprocess.run(command, stdout=subprocess.PIPE)
    return result.returncode, result.stdout

class Container:

    def __init__(self, container_id):
        self.id = container_id

    def GetNetworks(self):
        """
        List all networks this container connects
        """

        cmd = ["docker", "container", "inspect", self.id]
        code, stdout = RunCommand(cmd)

        if code != 0: return
        if not stdout: return

        j = json.loads(stdout)
        container = j[0]
        network_settings = container["NetworkSettings"]
        networks = network_settings["Networks"]

        for network_name, network_config in networks.items():
            network_id = network_config["NetworkID"]
            network_short_id = network_id[:12]
            iface_name = "br-{}".format(network_short_id)
            gateway_ip = network_config["Gateway"]
            container_ip = network_config["IPAddress"]

            print(network_name,
                iface_name,
                gateway_ip,
                container_ip)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Docker info toolset.")
    subparsers = parser.add_subparsers(dest="subcmd1")

    subparser_container = subparsers.add_parser("container")

    subsubparsers = subparser_container.add_subparsers(dest="subcmd2")
    subsubparser_container_networks = subsubparsers.add_parser("networks")

    subsubparser_container_networks.add_argument("CONTAINER")

    args = parser.parse_args()

    if args and args.subcmd1 == "container":
        container_id = args.CONTAINER

        container = Container(container_id)

        if args.subcmd2 == "networks":
            container.GetNetworks()

