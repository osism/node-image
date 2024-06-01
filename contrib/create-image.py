# SPDX-License-Identifier: Apache-2.0

import glob
import os
import re
import shutil
import subprocess
import sys
from print_color import print
from prettytable import PrettyTable
from typing import Any
from jinja2 import Environment, FileSystemLoader, StrictUndefined
import yaml
import argparse


def get_current_git_branch_name() -> str:
    result = subprocess.run(
        ["git", "rev-parse", "--abbrev-ref", "HEAD"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout.strip()


def get_variants_data() -> dict[str, Any]:
    def ignore_tags_constructor(loader, node):
        # This function will be called whenever PyYAML encounters a tag
        # It just returns None, effectively ignoring the tag
        return None

    yaml.SafeLoader.add_constructor(None, ignore_tags_constructor)
    variant_data = dict()

    with open(f"{run_dir}/.zuul.yaml", "r") as file:
        zuul_config = yaml.safe_load(file)
        for element in zuul_config:
            for elem_name, elem_data in element.items():
                if elem_name != "job" or not re.fullmatch(
                    r"node-image-build-.+", elem_data["name"]
                ):
                    continue
                variant_data[elem_data["name"]] = elem_data["vars"]
    return variant_data


def build_template(context: dict[str, Any]) -> str:
    results_filename = f"{build_dir}/user-data-{context['variant']}.yaml"
    template_loader = FileSystemLoader(searchpath=f"{run_dir}/templates/")
    template_env = Environment(loader=template_loader, undefined=StrictUndefined)
    results_template = template_env.get_template("user-data.yml.j2")
    with open(results_filename, mode="w", encoding="utf-8") as results:
        print(f"rendering file : {results_filename}", color="magenta")
        templated_string = results_template.render(context)
        yaml_loaded = yaml.load(templated_string, Loader=yaml.FullLoader)
        results.write("#cloud-config\n")
        results.write(yaml.dump(yaml_loaded, width=300))
    return results_filename


def docker_run(cmd: str, working_dir: str, chown_glob="*.iso"):
    print()
    os.chdir(run_dir)
    subprocess.run(
        f"docker build --network=host -t {DOCKER_BUILD_IMAGE} "
        + f"--build-arg BASE_IMAGE=ubuntu:{DISTRIBUTION} -f Dockerfile .",
        check=True,
        shell=True,
    )
    print("DOCKER:", color="green")
    print(f"+ {cmd}")

    chown_command = ""
    if chown_glob and chown_glob != "":
        chown_command = f"&& chown -vR {os.getuid()}:{os.getgid()} {chown_glob}"

    cmd_docker = (
        f"docker run --rm --net=host -v {working_dir}:/work "
        + f"docker.io/library/{DOCKER_BUILD_IMAGE} "
        + f'bash -c "{cmd} {chown_command}"'
    )
    subprocess.run(cmd_docker, check=True, shell=True)


def package_ffr_files(context: dict) -> str:
    frr_dir = f"{build_dir}/media/frr"
    os.makedirs(frr_dir, exist_ok=True)

    packages = [
        "freeipmi-common",
        "frr",
        "frr-pythontools",
        "ipmitool",
        "libc-ares2",
        "libfreeipmi17",
        "libopenipmi0",
        "libsensors-config",
        "libsensors5",
        "libsnmp-base",
        "libsnmp-base",
        "libsnmp40",
        "libyang2",
        "openipmi",
    ]

    os.chdir(frr_dir)

    download_command = f"apt-get update && apt-get download {' '.join(packages)}"
    download_ready = f"{frr_dir}/.download_ready"
    if not os.path.exists(download_ready):
        docker_run(download_command, frr_dir, ".")
        with open(f"{frr_dir}/.download_ready", "w"):
            pass  # do nothing, just create an empty file

    env = Environment(loader=FileSystemLoader("/"))
    for file_name in glob.glob(f"{run_dir}/templates/frr/*"):
        if file_name.endswith(".j2"):
            target_filename = (
                frr_dir + "/" + os.path.basename(file_name.removesuffix(".j2"))
            )
            print(f"rendering file : {target_filename}", color="magenta")
            template = env.get_template(file_name)
            with open(target_filename, mode="w", encoding="utf-8") as results:
                results.write(template.render(context))
        else:
            target_filename = frr_dir + "/" + os.path.basename(file_name)
            shutil.copyfile(file_name, target_filename)
        if target_filename.endswith(".sh"):
            os.chmod(target_filename, 0o755)
    return "-x /work/build/media"


def build_image(
    name: str, context_data: dict, template_only: bool = False
) -> str | None:
    print(f"build image >>>{name}<<<", color="magenta")
    user_data_file = build_template(context_data)

    add_dir = ""
    if context_data.get("layer3_underlay") == "true":
        add_dir = package_ffr_files(context_data)

    iso_file = None

    if not template_only:
        iso_file = f"ubuntu-autoinstall-{context_data['variant']}.iso"

        print(f"image {iso_file}", color="magenta")
        os.chdir(run_dir)

        build_command = (
            "/work/contrib/image-create.sh -r -a -k "
            + f"-u /work/build/{os.path.basename(user_data_file)} -n {DISTRIBUTION}"
            + f" --destination {iso_file} {add_dir}"
        )
        docker_run(build_command, run_dir)
        iso_file_checksum = f"{iso_file}.CHECKSUM"
        print(f"Creating checksum file {iso_file_checksum}", color="magenta")
        subprocess.run(
            f"shasum -a 256 {iso_file} > {iso_file_checksum}", check=True, shell=True
        )
    return iso_file


def create_context(
    image_name: str, commandline_args: argparse.Namespace
) -> dict[str, str]:
    context_data_default = {
        "layer3_underlay": "false",
        "asn_node_base": "42100210",
        "ipv4_base": "10.10.21.",
        "ipv6_base": "fd0c:cc24:75a0:1:10:10:21:",
        "interface1_name": "enp2s0f0np0",
        "interface2_name": "enp2s0f1np1",
        "interface1_asn": "65405",
        "interface2_asn": "65404",
        "password_hash": "$5$H2wkOHUVMIm2Yl2n$2AR/A2ILtgZcWx5UXL6N56Ha/wkdGvs0w5sFUMQ3iaB",
        "ssh_public_key_user_osism": "# no key specified",
    }
    context_data = {**context_data_default, **variants[image_name]}

    if commandline_args.config:
        with open(commandline_args.config, "r") as file:
            config_data = {
                key: str(value) for key, value in yaml.safe_load(file).items()
            }
        context_data = {**context_data, **config_data}

    for extra_arg in commandline_args.arg:
        arg_arr = extra_arg.split("=")
        context_data[arg_arr[0]] = "=".join(arg_arr[1:])
    if commandline_args.layer3_underlay:
        context_data["layer3_underlay"] = "true"

    # convert everything to strings
    context_data = {k: str(v) for k, v in context_data.items()}

    print("Created context (yaml):", color="green")
    print("---")
    print(yaml.dump(context_data, default_flow_style=False))
    print(
        "You can adapt the context by submitting other values with >>--arg KEY=VALUE<< or by specifying a yaml "
        "config file with --config",
        color="magenta",
    )

    return context_data


def build_images(commandline_args: argparse.Namespace):
    os.makedirs(build_dir, exist_ok=True)
    images = set()
    for image in commandline_args.build:
        if image == "all":
            images = images.union(set(variants.keys()))
        else:
            if image not in variants:
                print(f"ERROR: {image} not defined", color="red")
                sys.exit(1)
            images.add(image)

    for image in images:
        build_image(
            image,
            create_context(image, commandline_args),
            commandline_args.template_only,
        )


def wrap_text_by_words(text: str, words_per_line: int):
    words = text.split(" ")
    lines = []
    for i in range(0, len(words), words_per_line):
        line = " ".join(words[i : i + words_per_line]).strip()
        lines.append(line)

    return "\n".join(lines)


def show_variants():
    print("The available images:", color="green")
    print()
    table = PrettyTable()
    table.align = "l"
    table.field_names = ["Image Name", "Description", "Layout"]
    for image_name, data in variants.items():
        table.add_row(
            [
                image_name,
                wrap_text_by_words(data.get("description", "-"), 5),
                f"assets/disklayout-{data['variant']}.drawio.png",
            ],
            divider=True,
        )
    print(table)
    print()
    print(
        f"A overview: https://github.com/osism/node-image/tree/{BRANCH}", color="green"
    )
    sys.exit(0)


DISTRIBUTION = "jammy"
DOCKER_WORKDIR = "/work"
BRANCH = get_current_git_branch_name()
DOCKER_BUILD_IMAGE = f"osism-node-image-builder:latest-{BRANCH}"

if __name__ == "__main__":
    run_dir = os.path.realpath(os.path.dirname(os.path.realpath(__file__)) + "/../")

    parser = argparse.ArgumentParser(prog=f"{run_dir}/create-image.sh")

    exclusive_group = parser.add_mutually_exclusive_group(required=True)
    exclusive_group.add_argument(
        "--show", "-s", action="store_true", help="Show possible images"
    )
    exclusive_group.add_argument(
        "--build", "-b", type=str, nargs="+", help="Build images"
    )
    exclusive_group.add_argument(
        "--env", "-e", action="store_true", help="Create build environment"
    )
    exclusive_group.add_argument(
        "--clean", "-r", action="store_true", help="Drop cached build data"
    )

    parser.add_argument(
        "--arg",
        "-a",
        nargs="+",
        help="Extra values, see template",
        metavar="KEY=VALUE",
        default=[],
    )
    parser.add_argument("--config", "-c", type=str, help="A config as yaml file")
    parser.add_argument(
        "--build-directory", type=str, help="Overwrite the default build directory"
    )

    parser.add_argument(
        "--template-only", "-t", action="store_true", help="Do only templating"
    )
    parser.add_argument(
        "--layer3-underlay", "-l", action="store_true", help="Use layer 3 underlay"
    )
    args = parser.parse_args()

    build_dir = f"{run_dir}/build"

    os.chdir(run_dir)
    os.umask(0o022)

    variants = get_variants_data()

    if args.show:
        show_variants()

    if args.clean:
        print("Cleaning up cached build data", color="green")
        if os.path.exists(build_dir):
            shutil.rmtree(build_dir)
            os.makedirs(build_dir)
        if (
            len(
                subprocess.check_output(
                    f"docker images {DOCKER_BUILD_IMAGE} -q ", shell=True
                )
            )
            > 0
        ):
            subprocess.run(f"docker rmi {DOCKER_BUILD_IMAGE}", check=True, shell=True)
        sys.exit(0)

    if args.build:
        build_images(args)
        sys.exit(0)

    if args.env:
        docker_run("cat /etc/lsb-release", run_dir, chown_glob="")
