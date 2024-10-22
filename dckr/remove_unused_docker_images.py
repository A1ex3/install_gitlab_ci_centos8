import argparse
import json
import logging
import sys
import time
from typing import Any
from docker import DockerClient, from_env
from docker.models.images import Image
from docker.errors import APIError

def read_config_json(path: str) -> dict[str, Any]:
    with open(path, "r", encoding='utf-8') as file:
        data = json.load(file)
    return data

def log_level_by_str(level: str) -> int:
    ll = level.upper()

    if ll == "DEBUG":
        return logging.DEBUG
    elif ll == "INFO":
        return logging.INFO
    elif ll == "WARNING":
        return logging.WARNING
    elif ll == "ERROR":
        return logging.ERROR
    elif ll == "FATAL":
        return logging.FATAL
    else:
        raise Exception(f"Unknown log level '{level}'")

class __DockerContainers:
    def __init__(self, client: DockerClient) -> None:
        self.__client: DockerClient = client
    
    def get_list(self):
        return self.__client.containers.list()

class __DockerImages:
    def __init__(self, client: DockerClient) -> None:
        self.__client: DockerClient = client

    def get_image_info(self, image: Image) -> dict[str, str]:
        return {
            "label": image.tags[0],
            "id": str(image.id).replace("sha256:", "", 1),
            "short_id": image.short_id.replace("sha256:", "", 1)
        }

    def get_list(
        self,
        name: str | None = None,
        all: bool = False,
        filters: dict[str, Any] | None = None
    ):
        return self.__client.images.list(name=name, all=all, filters=filters)

    def remove(
        self,
        images: list[Image],
        containers: list,
        white_list: list[str] = [],
        force: bool = False,
        noprune: bool = False
    ) -> list[Image]:
        deleted_images: list[Image] = []
        used_images = {container.image.id for container in containers}

        for img in images:
            img_info = self.get_image_info(img)

            if (
                img.id in used_images 
                or img_info["id"] in white_list
                or img_info["short_id"] in white_list 
                or img_info["label"] in white_list
            ):
                continue

            try:
                self.__client.images.remove(
                    image=img_info["id"],
                    force=force,
                    noprune=noprune
                )
                deleted_images.append(img)
            except APIError:  # Triggers when the image is in use.
                pass
            except Exception as e:
                logging.error(f"An error occurred while removing image '{img}': {e}")

        return deleted_images

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', type=str, required=True, help='Path to configuration')
    args = parser.parse_args()

    cfg = read_config_json(args.config)
    cfg_this = cfg["remove_unused_images"]

    logging.basicConfig(
        stream=sys.stderr,
        level=log_level_by_str(cfg["log_level"]),
        datefmt='%Y-%m-%dT%H:%M:%S%z',
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

    client = from_env()

    while True:
        images = __DockerImages(client)
        containers = __DockerContainers(client)

        for i in images.remove(images=images.get_list(all=True), containers=containers.get_list(), white_list=cfg_this["white_list"]):
            logging.info(f"Deleted images: {images.get_image_info(i)}")

        time.sleep(cfg_this["per_seconds"])